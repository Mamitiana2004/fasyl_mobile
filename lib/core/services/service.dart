import 'dart:convert';

import 'package:fasyl/core/config/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Service {
  String baseUrl = AppString.api_url;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final logger = Logger();

  Future<dynamic> getAllPopular() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/service/popular'),
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
  
  Future<dynamic> getAll() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/service'),
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
  
  Future<dynamic> getById(id) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}api/service/$id'),
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
