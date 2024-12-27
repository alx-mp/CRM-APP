// lib/screens/product_catalog_screen.dart
import 'package:flutter/material.dart';
import 'product_detail.dart';

class ProductCatalogScreen extends StatelessWidget {
  final String category;

  const ProductCatalogScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 10, // Replace with actual data length
        itemBuilder: (context, index) => _buildProductCard(
          context,
          'Product ${index + 1}',
          999.0 + (index * 100),
          index % 2 == 0,
          Icons.laptop_mac,
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String name,
    double price,
    bool isAvailable,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              name: name,
              price: price,
              isAvailable: isAvailable,
              icon: icon,
            ),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    icon,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                isAvailable ? 'Available' : 'Not Available',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
              Text(
                '\$${price.toString()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
