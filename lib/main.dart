// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crm_app/theme/custom_theme.dart';
import 'screens/account_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/orders_screen.dart'; // Importar la pantalla de órdenes
import 'screens/product_catalog.dart';
import 'screens/product_detail.dart';
import 'widgets/auth_wrapper.dart';

Future<void> main() async {
  // Asegurarse de que los widgets están inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar las variables de entorno
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MStore',
      debugShowCheckedModeBanner: false,
      theme: CustomTheme.darkTheme(),
      // Usar AuthWrapper como home
      home: const AuthWrapper(),
      // Definir rutas para navegación
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/cart': (context) => const CartScreen(),
        '/orders': (context) => const OrdersScreen(), // Agregar ruta de órdenes
        '/account': (context) => const AccountScreen(),
        '/product-catalog': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ProductCatalogScreen(category: args['category']);
        },
        '/product-detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ProductDetailScreen(
            name: args['name'],
            price: args['price'],
            isAvailable: args['isAvailable'],
            icon: args['icon'],
          );
        },
      },
    );
  }
}
