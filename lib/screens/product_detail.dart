// lib/screens/product_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _hasShownStockWarning = false;

  void _showIvaInfo() {
    final ivaAmount =
        widget.product.hasIva ? (widget.product.price * 0.12) : 0.0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Información de IVA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Precio base: \$${widget.product.price.toStringAsFixed(2)}'),
            if (widget.product.hasIva) ...[
              Text('IVA (12%): \$${ivaAmount.toStringAsFixed(2)}'),
              Text(
                'Total con IVA: \$${(widget.product.price + ivaAmount).toStringAsFixed(2)}',
              ),
            ] else
              const Text('Este producto no incluye IVA'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int newQuantity) {
    if (newQuantity > widget.product.stockAvailable) {
      if (!_hasShownStockWarning) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stock máximo disponible: ${widget.product.stockAvailable}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _hasShownStockWarning = true;
        });
      }
      return;
    }

    if (newQuantity < 1) return;

    setState(() {
      _quantity = newQuantity;
      _hasShownStockWarning = false;
    });
  }

  Future<void> _addToCart() async {
    if (_quantity > widget.product.stockAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad seleccionada excede el stock disponible'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await Provider.of<CartProvider>(context, listen: false)
          .addItem(widget.product, _quantity);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.product.stockAvailable > 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showIvaInfo,
            tooltip: 'Información de IVA',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'product-${widget.product.id}',
              child: Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[200],
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            size: 150,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.shopping_bag,
                        size: 150,
                        color: Colors.blue,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      if (widget.product.hasIva)
                        Text(
                          ' + IVA',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isAvailable
                              ? 'Stock: ${widget.product.stockAvailable}'
                              : 'Agotado',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isAvailable) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Cantidad:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () => _updateQuantity(_quantity - 1)
                                    : null,
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  _quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed:
                                    _quantity < widget.product.stockAvailable
                                        ? () => _updateQuantity(_quantity + 1)
                                        : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<CartProvider>(
              builder: (ctx, cart, _) {
                final isInCart = cart.isProductInCart(widget.product.id);

                return Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isInCart || !isAvailable ? null : _addToCart,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isInCart
                              ? 'Producto en Carrito'
                              : 'Agregar al Carrito',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
