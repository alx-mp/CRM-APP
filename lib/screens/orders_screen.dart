// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../widgets/bottom_navigation.dart';
import '../models/order.dart';
import '../services/pdf_service.dart';
import '../services/token_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  Map<String, String> pdfPaths = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        _redirectToLogin();
        return;
      }

      final orders = await OrderService.getOrders(token);
      if (!mounted) return;

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error cargando órdenes: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _redirectToLogin() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _generateInvoice(Order order) async {
    try {
      final filePath = await PdfService.generateInvoice(order, context);
      setState(() {
        pdfPaths[order.id] = filePath;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Factura guardada en Documentos')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generando factura: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openInvoice(String orderId) async {
    try {
      final filePath = pdfPaths[orderId];
      if (filePath == null) {
        throw Exception('PDF no generado aún');
      }
      await PdfService.openPdfFile(filePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error abriendo factura: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
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
          title: const Text('Mis Órdenes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              try {
                await Navigator.of(context).pushReplacementNamed('/home');
              } catch (e) {
                //print('Error durante la navegación: $e');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadOrders,
              tooltip: 'Actualizar órdenes',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: _orders.isEmpty
                          ? const Center(
                              child: Text('No tienes órdenes realizadas'),
                            )
                          : ListView.builder(
                              itemCount: _orders.length,
                              itemBuilder: (context, index) {
                                final order = _orders[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ExpansionTile(
                                    title: Text('Orden #${order.id}'),
                                    subtitle: Text(
                                      'Fecha: ${order.date.toString().substring(0, 16)}\n'
                                      'Total: \$${order.total.toStringAsFixed(2)}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.download),
                                          onPressed: () =>
                                              _generateInvoice(order),
                                          tooltip: 'Generar factura',
                                        ),
                                        if (pdfPaths.containsKey(order.id))
                                          IconButton(
                                            icon: const Icon(Icons.open_in_new),
                                            onPressed: () =>
                                                _openInvoice(order.id),
                                            tooltip: 'Abrir factura',
                                          ),
                                      ],
                                    ),
                                    children: [
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: order.items.length,
                                        itemBuilder: (context, itemIndex) {
                                          final item = order.items[itemIndex];
                                          return ListTile(
                                            title: Text(item.name),
                                            subtitle: Text(
                                                'Cantidad: ${item.quantity}'),
                                            trailing: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                    '\$${item.price.toStringAsFixed(2)}'),
                                                Text(
                                                  'Total: \$${(item.price * item.quantity).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Subtotal: \$${(order.total / 1.15).toStringAsFixed(2)}',
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'IVA (15%): \$${(order.total - (order.total / 1.15)).toStringAsFixed(2)}',
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Total: \$${order.total.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 16),
                    const BottomNavigation(currentIndex: 2),
                  ],
                ),
              ),
      ),
    );
  }
}
