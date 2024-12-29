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
}
