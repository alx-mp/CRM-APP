// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/bottom_navigation.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final Map<int, bool> _hasShownStockWarning = {};
  bool _isProcessingCheckout = false;

  void _showStockWarning(BuildContext context, int productId, int maxStock) {
    if (!_hasShownStockWarning[productId]!) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock máximo disponible: $maxStock'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _hasShownStockWarning[productId] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        try {
          await Navigator.of(context).pushReplacementNamed('/home');
        } catch (e) {
          //print('Error durante la navegación: $e');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carrito de Compras'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              try {
                await Navigator.of(context).pushReplacementNamed('/home');
              } catch (e) {
                // print('Error durante la navegación: $e');
              }
            },
          ),
        ),
        body: SafeArea(
          child: Consumer<CartProvider>(
            builder: (ctx, cart, child) {
              if (cart.items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Text('Tu carrito está vacío'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const BottomNavigation(currentIndex: 1),
                    ],
                  ),
                );
              }

              for (var item in cart.items.values) {
                _hasShownStockWarning.putIfAbsent(item.product.id, () => false);
              }

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          final item = cart.items.values.toList()[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.network(
                                      item.product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.image_not_supported,
                                          size: 50,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${item.product.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        if (item.product.hasIva)
                                          Text(
                                            'IVA: \$${(item.product.price * 0.15).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: _isProcessingCheckout
                                                ? null
                                                : () async {
                                                    try {
                                                      await cart.updateQuantity(
                                                        item.product.id,
                                                        item.quantity - 1,
                                                      );
                                                      setState(() {
                                                        _hasShownStockWarning[
                                                            item.product
                                                                .id] = false;
                                                      });
                                                    } catch (e) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              e.toString()),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                          ),
                                          Text(
                                            item.quantity.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: _isProcessingCheckout
                                                ? null
                                                : () async {
                                                    if (item.quantity >=
                                                        item.product
                                                            .stockAvailable) {
                                                      _showStockWarning(
                                                        context,
                                                        item.product.id,
                                                        item.product
                                                            .stockAvailable,
                                                      );
                                                      return;
                                                    }
                                                    try {
                                                      await cart.updateQuantity(
                                                        item.product.id,
                                                        item.quantity + 1,
                                                      );
                                                      setState(() {
                                                        _hasShownStockWarning[
                                                            item.product
                                                                .id] = false;
                                                      });
                                                    } catch (e) {
                                                      if (!context.mounted) {
                                                        return;
                                                      }
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              e.toString()),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  },
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: _isProcessingCheckout
                                            ? null
                                            : () {
                                                cart.removeItem(
                                                    item.product.id);
                                                setState(() {
                                                  _hasShownStockWarning
                                                      .remove(item.product.id);
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', cart.subtotal),
                          const SizedBox(height: 8),
                          _buildSummaryRow('IVA (15%)', cart.totalIva),
                          const Divider(height: 24),
                          _buildSummaryRow('Total', cart.totalAmount,
                              isTotal: true),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_isProcessingCheckout || cart.items.isEmpty)
                                      ? null
                                      : () async {
                                          if (_isProcessingCheckout) return;

                                          setState(() {
                                            _isProcessingCheckout = true;
                                          });

                                          try {
                                            await cart.checkout();
                                            if (!context.mounted) return;

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    '¡Orden completada exitosamente!'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );

                                            Navigator.pushReplacementNamed(
                                                context, '/orders');
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() {
                                                _isProcessingCheckout = false;
                                              });
                                            }
                                          }
                                        },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isProcessingCheckout
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Finalizar Compra',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const BottomNavigation(currentIndex: 1),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.blue : null,
          ),
        ),
      ],
    );
  }
}
