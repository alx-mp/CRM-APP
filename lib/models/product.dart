// lib/models/product.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool hasIva;
  final int stockAvailable;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.hasIva,
    required this.stockAvailable,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['producto_id'],
      name: json['nombre'],
      description: json['descripcion'],
      price: double.parse(json['precio_unitario']),
      hasIva: json['iva'],
      stockAvailable: json['stock_disponible'],
      imageUrl: json['imagen_url'],
    );
  }
}
