import 'dart:convert';
import 'package:fasyl/core/config/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VirtualCardService {
  final String baseUrl = AppString.api_url;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> getVirtualCardDetails() async {
    try {
      // Récupération du token depuis le stockage sécurisé
      String? token = await storage.read(key: 'token');

      final response = await http.get(
        Uri.parse('$baseUrl/api/v2/virtual-card'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        try {
          final errorData = json.decode(response.body);
          throw Exception(
            'Failed to fetch virtual card: ${errorData['message'] ?? 'Unknown error'}',
          );
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Failed to get virtual card details: $e');
    }
  }
}
