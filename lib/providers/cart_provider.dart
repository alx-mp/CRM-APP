import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/order_service.dart';
import '../services/token_service.dart';

class CartItem {
  final Product product;
  int quantity;
  final double ivaAmount;

  CartItem({
    required this.product,
    required this.quantity,
    required this.ivaAmount,
  });

  double get total => product.price * quantity;
  double get totalWithIva => total + (ivaAmount * quantity);

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? ivaAmount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      ivaAmount: ivaAmount ?? this.ivaAmount,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  double get totalAmount {
    return _items.values.fold(
      0.0,
      (total, item) => total + item.totalWithIva,
    );
  }

  double get subtotal {
    return _items.values.fold(
      0.0,
      (total, item) => total + item.total,
    );
  }

  double get totalIva {
    return _items.values.fold(
      0.0,
      (total, item) => total + (item.ivaAmount * item.quantity),
    );
  }

  CartItem? getItem(int productId) => _items[productId];

  bool hasItem(int productId) => _items.containsKey(productId);

  Future<void> addItem(Product product, int quantity) async {
    if (hasItem(product.id)) {
      throw Exception('El producto ya está en el carrito');
    }

    if (quantity > product.stockAvailable) {
      throw Exception(
        'La cantidad solicitada ($quantity) excede el stock disponible (${product.stockAvailable})',
      );
    }

    if (quantity < 1) {
      throw Exception('La cantidad debe ser mayor a 0');
    }

    final ivaAmount = product.hasIva ? (product.price * 0.15) : 0.0;

    _items.putIfAbsent(
      product.id,
      () => CartItem(
        product: product,
        quantity: quantity,
        ivaAmount: ivaAmount,
      ),
    );

    notifyListeners();
  }

  Future<void> removeItem(int productId) async {
    if (!hasItem(productId)) return;

    _items.remove(productId);
    notifyListeners();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    final item = getItem(productId);
    if (item == null) {
      throw Exception('Producto no encontrado en el carrito');
    }

    if (quantity > item.product.stockAvailable) {
      throw Exception(
        'La cantidad solicitada ($quantity) excede el stock disponible (${item.product.stockAvailable})',
      );
    }

    if (quantity < 1) {
      await removeItem(productId);
      return;
    }

    _items.update(
      productId,
      (existingItem) => existingItem.copyWith(quantity: quantity),
    );

    notifyListeners();
  }

  Future<void> checkout() async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Debes iniciar sesión para realizar la compra');
    }

    if (isEmpty) {
      throw Exception('El carrito está vacío');
    }

    try {
      final user = await TokenService.getUser();
      if (user == null) {
        throw Exception('No se encontró información del usuario');
      }

      final orderData = {
        'id': user.id,
        'items': _items.values
            .map((item) => {
                  'producto_id': item.product.id,
                  'cantidad': item.quantity,
                  'precio_unitario': item.product.price,
                })
            .toList(),
      };

      await OrderService.createOrder(token, orderData);

      clear();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  bool isProductInCart(int productId) => _items.containsKey(productId);

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
