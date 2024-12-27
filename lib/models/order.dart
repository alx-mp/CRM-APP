// lib/models/order.dart
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
}

class OrderItem {
  final String name;
  final double price;
  final int quantity;

  OrderItem(this.name, this.price, this.quantity);
}
