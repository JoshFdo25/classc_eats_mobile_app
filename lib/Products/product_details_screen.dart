import 'dart:convert';
import 'package:classc_eats/Cart/cart_screen.dart';
import 'package:classc_eats/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final Map product;

  const ProductDetailScreen({super.key, required this.product});

  void _handleAddToCart(BuildContext context) async {
    final productId = product['id'];
    if (kDebugMode) {
      print("Adding product with id: $productId");
    }
    final response = await ApiService().addToCart(productId.toString());
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added to cart.')),
      );
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error'] ?? 'Error adding to cart.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          product['name'],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          bool isLandscape = orientation == Orientation.landscape;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLandscape
                  ? _buildLandscapeLayout(context)
                  : _buildPortraitLayout(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.network(
            product['image'],
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          product['name'],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Rs. ${product['price']}",
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              product['status'] ? Icons.check_circle : Icons.cancel,
              color: product['status'] ? Colors.green : Colors.red,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              product['status'] ? "Available" : "Not available",
              style: TextStyle(
                color: product['status'] ? Colors.green : Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          product['description'],
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        const Text(
          "Ingredients",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product['ingredients'],
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 30),
        Center(
          child: ElevatedButton(
            onPressed: product['status']
                ? () {
                    _handleAddToCart(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              backgroundColor:
                  product['status'] ? Colors.indigo[900] : Colors.grey,
            ),
            child: const Text(
              "Add to Cart",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Landscape layout
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Image.network(
              product['image'],
              height: 300,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Rs. ${product['price']}",
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    product['status'] ? Icons.check_circle : Icons.cancel,
                    color: product['status'] ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product['status'] ? "Available" : "Not available",
                    style: TextStyle(
                      color: product['status'] ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product['description'],
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Text(
                "Ingredients",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product['ingredients'],
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: product['status']
                      ? () {
                          _handleAddToCart(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    backgroundColor:
                        product['status'] ? Colors.blue : Colors.grey,
                  ),
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
