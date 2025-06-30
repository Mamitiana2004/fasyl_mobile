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
        Uri.parse('${baseUrl}api/v2/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Stocker le token et les infos utilisateur
        await storage.write(key: 'token', value: data['token']);
        await storage.write(key: 'user', value: jsonEncode(data['user']));

        // Gestion des rôles avec vérification
        String? role;
        if (data['user']['roles'] != null && data['user']['roles'].isNotEmpty) {
          role = data['user']['roles'][0]['roleName'] as String;
          await storage.write(key: 'role', value: role);
        } else {
          await storage.write(
            key: 'role',
            value: 'aucun',
          ); // Ou null si vous préférez
        }

        return {
          'token': data['token'],
          'user': data['user'],
          'role': role ?? 'aucun', // Valeur par défaut si null
          'message': data['message'],
        };
      } else {
        throw Exception(data['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String?> getStoredUserRole() async {
    try {
      // Récupérer le rôle depuis le stockage
      final role = await storage.read(key: 'role');
      return role;
    } catch (e) {
      print('Erreur lors de la récupération du rôle: $e');
      return null;
    }
  }

  bool isClient(String? role) {
    return role?.toLowerCase() == 'client';
  }

  bool isAnnonceur(String? role) {
    return role?.toLowerCase() == 'annonceur';
  }

  Future<int?> checkUserRole() async {
    final role = await getStoredUserRole();

    if (role == null) {
      print('Aucun rôle trouvé');
      return null;
    }

    if (isClient(role)) {
      print('Utilisateur est un client');
      return 1;
    } else if (isAnnonceur(role)) {
      print('Utilisateur est un annonceur');
      return 0;
    } else {
      print('Rôle inconnu: $role');
      return null;
    }
  }

  Future<String?> forgot_password(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}api/v2/auth/users/forgot-password'),
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
        Uri.parse('${baseUrl}api/v2/auth/users/verify-otp'),
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
