import 'dart:convert';

import 'package:fasyl/core/config/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CategorieService {
  String baseUrl = AppString.api_url;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  final logger = Logger();

  Future<dynamic> getAllCategorie() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/category/'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      logger.i(e);
      return {'error': 'Erreur de connexion:'};
    }
  }
}
