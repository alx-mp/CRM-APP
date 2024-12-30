// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:crm_app/theme/custom_theme.dart';
import 'providers/cart_provider.dart';
import 'screens/account_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/product_catalog.dart';
import 'screens/product_detail.dart';
import 'widgets/auth_wrapper.dart';
import 'models/product.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MStore',
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.darkTheme(),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(),
        '/account': (context) => const AccountScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-catalog') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ProductCatalogScreen(
              category: args['category'] as String,
              products: args['products'] as List<Product>,
            ),
          );
        }

        if (settings.name == '/product-detail') {
          final args = settings.arguments as Map<String, dynamic>;
          final product = Product(
            id: args['id'] as int,
            name: args['name'] as String,
            description: args['description'] as String,
            price: args['price'] as double,
            hasIva: args['hasIva'] as bool,
            stockAvailable: args['stockAvailable'] as int,
            imageUrl: args['imageUrl'] as String,
          );

          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: product,
            ),
          );
        }

        // Ruta por defecto o manejo de error
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}
