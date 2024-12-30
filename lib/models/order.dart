// lib/models/order.dart
class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final int productId;
  final bool hasIva;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.productId,
    required this.hasIva,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final producto = json['producto'];
    return OrderItem(
      productId: producto['producto_id'] as int,
      name: producto['nombre'] as String,
      price: double.parse(json['precio_unitario'].toString()),
      quantity: json['cantidad'] as int,
      hasIva: producto['iva'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': productId,
      'cantidad': quantity,
      'precio_unitario': price,
    };
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['orden_id'].toString(),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: double.parse(json['total'].toString()),
      date: DateTime.parse(
          json['fecha_orden'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
