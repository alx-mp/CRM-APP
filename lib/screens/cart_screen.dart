// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../services/pdf_service.dart';
import '../models/order.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool showOrders = false;
  List<Order> orders = [];

  Future<void> _handleCheckout() async {
    try {
      // Add current cart to orders
      final newOrder = Order(
        id: DateTime.now().toString(),
        items: [
          OrderItem('MacBook Air 13" M1', 999.0, 1),
          OrderItem('iPad (10th Gen)', 800.0, 1),
          OrderItem('iPhone 14 Pro Max', 999.0, 1),
        ],
        total: 3266.0,
        date: DateTime.now(),
      );

      setState(() {
        orders.add(newOrder);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order completed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error processing order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateInvoice(Order order) async {
    try {
      final filePath = await PdfService.generateInvoice(order, context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Invoice saved to Downloads: ${filePath.split('/').last}')),
      );
    } catch (e) {
      if (!mounted) return;
      if (e.toString() != 'Exception: Storage permission required') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showOrders ? 'My Orders' : 'Order Details'),
        actions: [
          IconButton(
            icon: Icon(showOrders ? Icons.shopping_cart : Icons.receipt_long),
            onPressed: () => setState(() => showOrders = !showOrders),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: showOrders ? _buildOrdersList() : _buildCart(),
      ),
    );
  }

  Widget _buildOrdersList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orders History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: orders.isEmpty
              ? const Center(child: Text('No orders yet'))
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      child: ListTile(
                        title: Text('Order #${order.id.substring(0, 8)}'),
                        subtitle: Text(
                          'Date: ${order.date.toString().substring(0, 16)}\n'
                          'Total: \$${order.total}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _generateInvoice(order),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        const BottomNavigation(currentIndex: 1),
      ],
    );
  }

  Widget _buildCart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Cart',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              _buildCartItem('MacBook Air 13" M1', 999.0),
              _buildCartItem('iPad (10th Gen)', 800.0),
              _buildCartItem('iPhone 14 Pro Max', 999.0),
            ],
          ),
        ),
        _buildOrderSummary(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleCheckout,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: const Text('Checkout (\$3266.0)'),
          ),
        ),
        const SizedBox(height: 16),
        const BottomNavigation(currentIndex: 1),
      ],
    );
  }

  Widget _buildCartItem(String name, double price) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.devices, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$$price',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {},
                ),
                const Text('1'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {},
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      children: [
        const Divider(),
        _buildSummaryRow('Sub Total', '\$3146.0'),
        _buildSummaryRow('Shipping', '\$120.0'),
        _buildSummaryRow('Total', '\$3266.0', isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
