// lib/screens/product_catalog_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCatalogScreen extends StatefulWidget {
  final String category;
  final List<Product> products;

  const ProductCatalogScreen({
    super.key,
    required this.category,
    required this.products,
  });

  @override
  State<ProductCatalogScreen> createState() => _ProductCatalogScreenState();
}

class _ProductCatalogScreenState extends State<ProductCatalogScreen> {
  List<Product> _filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  String _sortBy = 'name';
  bool _isReversed = false;

  @override
  void initState() {
    super.initState();
    _filteredProducts = List.from(widget.products);
    _sortProducts();
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(widget.products);
      } else {
        _filteredProducts = widget.products.where((product) {
          final searchLower = query.toLowerCase();
          final nameLower = product.name.toLowerCase();
          final descriptionLower = product.description.toLowerCase();
          return nameLower.contains(searchLower) ||
              descriptionLower.contains(searchLower);
        }).toList();
      }
      _sortProducts();
    });
  }

  void _sortProducts() {
    setState(() {
      switch (_sortBy) {
        case 'name':
          _filteredProducts.sort((a, b) => _isReversed
              ? b.name.compareTo(a.name)
              : a.name.compareTo(b.name));
          break;
        case 'price':
          _filteredProducts.sort((a, b) => _isReversed
              ? b.price.compareTo(a.price)
              : a.price.compareTo(b.price));
          break;
        case 'availability':
          _filteredProducts.sort((a, b) {
            final comparison = (b.stockAvailable > 0 ? 1 : 0)
                .compareTo(a.stockAvailable > 0 ? 1 : 0);
            return _isReversed ? -comparison : comparison;
          });
          break;
      }
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _filteredProducts = List.from(widget.products);
      _sortProducts();
    });
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Orden inverso'),
                subtitle: Text(_isReversed ? 'Descendente' : 'Ascendente'),
                value: _isReversed,
                onChanged: (value) {
                  setModalState(() => _isReversed = value);
                  setState(() {
                    _isReversed = value;
                    _sortProducts();
                  });
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Ordenar por nombre'),
                trailing: _sortBy == 'name'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'name');
                  _sortProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Ordenar por precio'),
                trailing: _sortBy == 'price'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'price');
                  _sortProducts();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Ordenar por disponibilidad'),
                trailing: _sortBy == 'availability'
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() => _sortBy = 'availability');
                  _sortProducts();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProductDetail(Product product) {
    Navigator.pushNamed(
      context,
      '/product-detail',
      arguments: {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'hasIva': product.hasIva,
        'stockAvailable': product.stockAvailable,
        'imageUrl': product.imageUrl,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortOptions,
            tooltip: 'Ordenar productos',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Buscar en ${widget.category}',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.black),
                        onPressed: () {
                          searchController.clear();
                          _filterProducts('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: _filterProducts,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshProducts,
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              searchController.text.isEmpty
                                  ? 'No hay productos disponibles'
                                  : 'No se encontraron productos para "${searchController.text}"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) =>
                          _buildProductCard(_filteredProducts[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final isAvailable = product.stockAvailable > 0;

    return GestureDetector(
      onTap: () => _navigateToProductDetail(product),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Hero(
                  tag: 'product-${product.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey,
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                            )
                          : const Icon(
                              Icons.shopping_bag,
                              size: 80,
                              color: Colors.blue,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAvailable ? 'Disponible' : 'Agotado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
