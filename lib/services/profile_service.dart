import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'token_service.dart';

class ProfileService {
  static const String baseUrl = 'https://crm-back-t2tt.onrender.com';

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/perfil'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      }
      return null;
    } catch (e) {
      //print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<String?> getProfileImage(String userId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/imagen-perfil/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String? imageData;

        if (responseData is Map) {
          imageData = responseData['data'] ??
              responseData['imageData'] ??
              responseData['imagen'] ??
              responseData['image'];
        } else if (responseData is String) {
          imageData = responseData;
        }

        if (imageData != null && imageData.isNotEmpty) {
          if (!imageData.contains('data:image')) {
            imageData = 'data:image/jpeg;base64,$imageData';
          }
          return imageData;
        }
      }
      return null;
    } catch (e) {
      //print('Error getting profile image: $e');
      return null;
    }
  }

  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'image/jpeg';
    }
  }

  static Future<bool> updateProfileImage(File imageFile) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) return false;

      // Get and clean file extension
      String originalExtension = path.extension(imageFile.path).toLowerCase();
      String cleanExtension = originalExtension.replaceAll(
          RegExp(r'\..*\.(jpg|jpeg|png)$'), '.\$1');

      final validExtension =
          RegExp(r'\.(jpg|jpeg|png)$').hasMatch(cleanExtension);
      if (!validExtension) {
        //print('Invalid file type. Only jpg, jpeg, and png are allowed.');
        return false;
      }

      // Log file information
      //print('Original file path: ${imageFile.path}');
      //print('Original extension: $originalExtension');
      //print('Cleaned extension: $cleanExtension');
      //print('File size: ${await imageFile.length()} bytes');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/usuarios/imagen-perfil'),
      );

      // Add file with proper content type
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: 'profile_image$cleanExtension',
        contentType: MediaType.parse(_getMimeType(cleanExtension)),
      );
      request.files.add(multipartFile);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Log request details
      //print('Request URL: ${request.url}');
      //print('File field name: ${multipartFile.field}');
      //print('File filename: ${multipartFile.filename}');
      //print('Content type: ${multipartFile.contentType}');
      //print('File length: ${multipartFile.length} bytes');
      //print('Request headers: ${request.headers}');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      //print('Error updating profile image: $e');
      return false;
    }
  }
}
