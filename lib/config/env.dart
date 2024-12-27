import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiUrl => dotenv.get('API_URL');

  // Puedes agregar más getters para otras variables de entorno aquí
  // Por ejemplo:
  // static String get apiKey => dotenv.get('API_KEY');
}
