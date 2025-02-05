import 'dart:convert';
import 'package:classc_eats/Services/api_service.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  Map? _cart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    final response = await ApiService().fetchCart();
    if (response.statusCode == 200) {
      setState(() {
        _cart = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching cart')),
        );
      }
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    final response = await ApiService().removeFromCart(cartItemId);
    if (response.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      }
      _fetchCart();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error removing item')),
        );
      }
    }
  }

  Future<void> _updateQuantity(String cartItemId, int newQuantity) async {
    final response =
        await ApiService().updateCartQuantity(cartItemId, newQuantity);
    if (response.statusCode == 200) {
      _fetchCart();
    } else {
      final data = jsonDecode(response.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Error updating quantity')),
        );
      }
    }
  }

  Widget _buildCartItem(Map item) {
    final product = item['product'];
    final cartItemId = item['id'];
    final int quantity = item['quantity'] is int
        ? item['quantity']
        : int.tryParse(item['quantity'].toString()) ?? 1;
    final double price = double.tryParse(product['price'].toString()) ?? 0.0;
    final double total = price * quantity;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            product['image'],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(product['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Price: Rs. ${product['price']}"),
            Text("Total: Rs. ${total.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: quantity > 1
                      ? () =>
                          _updateQuantity(cartItemId.toString(), quantity - 1)
                      : null, // Disable if quantity is 1
                ),
                Text("$quantity"),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: quantity < 6
                      ? () =>
                          _updateQuantity(cartItemId.toString(), quantity + 1)
                      : null, // Disable if quantity is 6
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeItem(cartItemId.toString()),
        ),
      ),
    );
  }

  double _calculateTotal() {
    if (_cart == null || _cart!['items'] == null) return 0.0;

    return (_cart!['items'] as List).fold(0.0, (sum, item) {
      final price = double.tryParse(item['product']['price'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (price * quantity);
    });
  }

  void _handleCheckout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: const Text('Checkout process initiated.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double grandTotal = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : (_cart == null ||
                      _cart!['items'] == null ||
                      (_cart!['items'] as List).isEmpty)
                  ? const Center(child: Text("Your cart is empty"))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: (_cart!['items'] as List).length,
                            itemBuilder: (context, index) {
                              final item = _cart!['items'][index];
                              return _buildCartItem(item);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: orientation == Orientation.portrait
                              ? Column(
                                  children: [
                                    Text(
                                      "Total: Rs. ${grandTotal.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _handleCheckout,
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 30),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                          ),
                                          backgroundColor: Colors.indigo[900]),
                                      child: const Text(
                                        "Proceed to Checkout",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Total: Rs. ${grandTotal.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ElevatedButton(
                                      onPressed: _handleCheckout,
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 30),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40.0),
                                          ),
                                          backgroundColor: Colors.indigo[900]),
                                      child: const Text(
                                        "Proceed to Checkout",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                        )
                      ],
                    );
        },
      ),
    );
  }
}
