import 'dart:convert';
import 'package:fasyl/core/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class AuthService {
  String baseUrl = AppString.api_url;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final logger = Logger();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Stocker le token et les infos utilisateur
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'user', value: jsonEncode(data['user']));

        return {
          'token': data['token'],
          'user': data['user'],
          'message': data['message'],
        };
      } else {
        throw Exception(data['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String?> forgot_password(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/auth/users/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        await storage.write(key: 'email_verify', value: email);
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['details']['originalError'];
      }
    } catch (e) {
      logger.i(e);
      return "Erreur de connexion";
    }
  }

  Future<String?> verify_email(String code, String email) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/auth/users/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // await storage.write(key: 'token', value: data['token']);
        return null; // Pas d'erreur
      } else {
        final data = jsonDecode(response.body);
        return data['message']; // Retourne le message d'erreur
      }
    } catch (e) {
      logger.i(e);
      return 'Erreur de connexion ';
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}
