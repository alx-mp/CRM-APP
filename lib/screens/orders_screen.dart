// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../models/order.dart';
import '../services/pdf_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Map<String, String> pdfPaths = {};

  Future<void> _generateInvoice(Order order) async {
    try {
      final filePath = await PdfService.generateInvoice(order, context);
      setState(() {
        pdfPaths[order.id] = filePath;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice saved to Documents')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openInvoice(String orderId) async {
    try {
      final filePath = pdfPaths[orderId];
      if (filePath == null) {
        throw Exception('PDF not generated yet');
      }
      await PdfService.openPdfFile(filePath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Demo orders - replace with actual data from your backend
    final orders = [
      Order(
        id: '1234',
        items: [OrderItem('MacBook Air', 999.0, 1)],
        total: 999.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: '1235',
        items: [OrderItem('iPad Pro', 799.0, 1)],
        total: 799.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text('Order #${order.id}'),
                      subtitle: Text(
                        'Date: ${order.date.toString().substring(0, 16)}\n'
                        'Total: \$${order.total}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => _generateInvoice(order),
                          ),
                          if (pdfPaths.containsKey(order.id))
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => _openInvoice(order.id),
                            ),
                        ],
                      ),
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          itemBuilder: (context, itemIndex) {
                            final item = order.items[itemIndex];
                            return ListTile(
                              title: Text(item.name),
                              subtitle: Text('Quantity: ${item.quantity}'),
                              trailing: Text('\$${item.price}'),
                            );
                          },
                        ),
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
    );
  }
}
