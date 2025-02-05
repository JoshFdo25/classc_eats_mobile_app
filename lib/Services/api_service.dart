import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "https://classiceats.online/api";
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: "AuthToken");
  }

  Future<http.Response> register(String name, String email, String password,
      String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await storage.write(key: "AuthToken", value: data['token']);
    }

    return response;
  }

  Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await storage.write(key: "AuthToken", value: data['token']);
    }

    return response;
  }

  Future<http.Response> fetchProfile() async {
    String? token = await getToken();
    return await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> updateProfile(Map<String, dynamic> profileData) async {
    String? token = await getToken();
    return await http.post(
      Uri.parse('$baseUrl/profile/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(profileData),
    );
  }

  Future<http.Response> deleteAccount() async {
    String? token = await getToken();
    return await http.delete(
      Uri.parse('$baseUrl/profile/delete'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> fetchProducts() async {
    return await http.get(
      Uri.parse('$baseUrl/products'),
    );
  }

  Future<http.Response> fetchCategories() async {
    return await http.get(
      Uri.parse('$baseUrl/categories'),
    );
  }

  Future<http.Response> addToCart(String productId) async {
    String? token = await getToken();
    return await http.post(
      Uri.parse('$baseUrl/cart/add/$productId'),
      headers: {
        'content-type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
  }

  Future<http.Response> fetchCart() async {
    String? token = await getToken();
    return await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> removeFromCart(String cartItemId) async {
    String? token = await getToken();
    return await http.delete(
      Uri.parse('$baseUrl/cart/remove/$cartItemId'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<http.Response> updateCartQuantity(
      String cartItemId, int quantity) async {
    String? token = await getToken();
    return await http.patch(
      Uri.parse('$baseUrl/cart/update/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'quantity': quantity}),
    );
  }

  Future<http.Response> checkout() async {
    String? token = await getToken();
    // Assuming you add a checkout endpoint for the API.
    return await http.post(
      Uri.parse('$baseUrl/checkout'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<void> logout() async {
    String? token = await getToken();
    await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await storage.delete(key: "auth_token");
  }
}
