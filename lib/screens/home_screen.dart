import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/token_service.dart';
import '../models/product.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/profile_image.dart';

// Widget separado para el encabezado
class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.userName,
    required this.userId,
  });

  final String userName;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, $userName!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'Lo que más te gusta te espera',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        if (userId.isNotEmpty) MemoizedProfileImage(userId: userId),
      ],
    );
  }
}

// Widget memoizado para el ProfileImage
class MemoizedProfileImage extends StatelessWidget {
  const MemoizedProfileImage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  Widget build(BuildContext context) {
    return ProfileImage(
      key: ValueKey('profile_$userId'),
      radius: 20,
      userId: userId,
      onTap: null,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String userId = '';
  bool _isLoading = true;
  bool _isLoadingProducts = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<Product> _products = [];
  final ValueNotifier<List<Product>> _filteredProductsNotifier =
      ValueNotifier([]);
  final TextEditingController searchController = TextEditingController();
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = '';
      });

      _token = await TokenService.getToken();
      if (_token == null) {
        _redirectToLogin();
        return;
      }

      await Future.wait<void>([
        _loadUserData(),
        _loadProducts(),
      ]).catchError((error) {
        debugPrint('Error initializing data: $error');
        if (!mounted) {
          // Agregamos llaves aquí
          return [];
        }
        setState(() {
          _hasError = true;
          _errorMessage = 'Error al cargar los datos';
        });
        _redirectToLogin();
        return [];
      });
    } catch (e) {
      debugPrint('Error in initialization: $e');
      if (!mounted) {
        // También agregamos llaves aquí para consistencia
        return;
      }
      setState(() {
        _hasError = true;
        _errorMessage = 'Error de inicialización';
      });
      _redirectToLogin();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    _filteredProductsNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await TokenService.getUser();
      if (!mounted) return;

      if (user != null) {
        setState(() {
          userId = user.id;
          userName = user.firstName;
          _isLoading = false;
        });
      } else {
        throw Exception('No user data found');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  Future<void> _loadProducts() async {
    try {
      if (_token == null) throw Exception('No token available');

      final products = await ProductService.getProducts(_token!);
      if (!mounted) return;

      _products = products;
      _filteredProductsNotifier.value = products;
      setState(() {
        _isLoadingProducts = false;
        _hasError = false;
        _errorMessage = '';
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().contains('401')
            ? 'Sesión expirada'
            : 'Error al cargar productos';
        _isLoadingProducts = false;
      });
      if (e.toString().contains('401')) {
        _redirectToLogin();
      }
      rethrow;
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      _filteredProductsNotifier.value = _products;
    } else {
      _filteredProductsNotifier.value = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingProducts = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      await _loadProducts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'Error al actualizar productos';
      });
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToProductCatalog(
      String category, List<Product> categoryProducts) {
    Navigator.pushNamed(
      context,
      '/product-catalog',
      arguments: {
        'category': category,
        'products': categoryProducts,
      },
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
    if (_hasError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    // Crear una única instancia del HeaderWidget
    final headerWidget = HeaderWidget(
      userName: userName,
      userId: userId,
    );

    return Scaffold(
      body: _isLoading || _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerWidget,
                    const SizedBox(height: 20),
                    _buildSearchField(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              _buildProductSections(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const BottomNavigation(currentIndex: 0),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Buscar productos',
        hintStyle: TextStyle(color: Colors.grey[600]),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.black,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: _filterProducts,
    );
  }

  Widget _buildProductSections() {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: _filteredProductsNotifier,
      builder: (context, filteredProducts, _) {
        if (filteredProducts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay productos disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final productsWithIva =
            filteredProducts.where((p) => p.hasIva).toList();
        final productsWithoutIva =
            filteredProducts.where((p) => !p.hasIva).toList();

        return Column(
          children: [
            if (productsWithIva.isNotEmpty) ...[
              _buildCategorySection(
                'Productos con IVA',
                productsWithIva.length.toString(),
                productsWithIva,
              ),
              _buildProductGrid(productsWithIva),
            ],
            if (productsWithoutIva.isNotEmpty) ...[
              _buildCategorySection(
                'Productos sin IVA',
                productsWithoutIva.length.toString(),
                productsWithoutIva,
              ),
              _buildProductGrid(productsWithoutIva),
            ],
          ],
        );
      },
    );
  }

  Widget _buildCategorySection(
    String title,
    String count,
    List<Product> products,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$title ($count)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            onPressed: () => _navigateToProductCatalog(title, products),
            icon: const Text('Ver todos'),
            label: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    final previewProducts = products.take(4).toList();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.75,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children:
          previewProducts.map((product) => _buildProductCard(product)).toList(),
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
                          )
                        : const Icon(
                            Icons.shopping_bag,
                            size: 80,
                            color: Colors.blue,
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
}
