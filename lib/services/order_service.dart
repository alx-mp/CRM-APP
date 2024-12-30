// lib/services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/order.dart';

class OrderService {
  static Future<List<Order>> getOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Env.apiUrl}/ordenes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      }

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al obtener las órdenes');
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar las órdenes: ${e.toString()}');
    }
  }

  static Future<Order> createOrder(
      String token, Map<String, dynamic> orderData) async {
    try {
      //print('Enviando orden: ${json.encode(orderData)}'); // Para debug

      final response = await http.post(
        Uri.parse('${Env.apiUrl}/ordenes'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(orderData),
      );

      //print('Respuesta del servidor: ${response.body}'); // Para debug

      if (response.statusCode == 401) {
        throw Exception(
            'Sesión expirada. Por favor, inicia sesión nuevamente.');
      }

      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Error al crear la orden');
      }

      final data = json.decode(response.body);
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Error al crear la orden: ${e.toString()}');
    }
  }
}
