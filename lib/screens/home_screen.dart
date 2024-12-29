// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/profile_image.dart';
import 'product_catalog.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  bool _isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String userId = '';

  Future<void> _loadUserData() async {
    try {
      final profileData = await ProfileService.getUserProfile();
      if (!mounted) return;

      if (profileData != null) {
        setState(() {
          userId = profileData['id'];
          userName = profileData['first_name'];
          _isLoading = false;
        });
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _navigateToProductCatalog(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductCatalogScreen(category: category),
      ),
    );
  }

  void _navigateToProductDetail(
    String name,
    double price,
    bool isAvailable,
    IconData icon,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          name: name,
          price: price,
          isAvailable: isAvailable,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchField(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCategorySection('Mac', '2'),
                            _buildProductGrid(),
                            _buildCategorySection('iPad', '2'),
                            _buildProductGrid(),
                          ],
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Lo que mas te gusta te espera',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        ProfileImage(
          radius: 20,
          userId: userId,
          onTap: null, // Para deshabilitar la edición en el HomeScreen
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        hintText: 'Search gadgets',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: (value) {
        // Implement search functionality
      },
    );
  }

  Widget _buildCategorySection(String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title $count',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () => _navigateToProductCatalog(title),
            child: const Text('See all'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildProductCard(
          'MacBook Air 13" M1',
          999.0,
          true,
          Icons.laptop_mac,
        ),
        _buildProductCard(
          'MacBook Pro 13" M2',
          1299.0,
          false,
          Icons.laptop,
        ),
      ],
    );
  }

  Widget _buildProductCard(
    String name,
    double price,
    bool isAvailable,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () => _navigateToProductDetail(name, price, isAvailable, icon),
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
                ),
              ),
              Text(
                '\$${price.toString()}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
