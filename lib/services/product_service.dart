// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/product.dart';

class ProductService {
  static Future<List<Product>> getProducts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/productos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load products');
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  static Future<void> updateProductStock(
    int productId,
    int newStock,
    String token,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('${Env.apiUrl}/productos/$productId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'stock_disponible': newStock,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update product stock');
      }
    } catch (e) {
      throw Exception('Error updating product stock: $e');
    }
  }
}
