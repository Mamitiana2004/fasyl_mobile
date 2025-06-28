import 'dart:convert';
import 'package:fasyl/core/config/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AbonnementService {
  String baseUrl = AppString.api_url;
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  Logger logger = Logger();

  Future<bool> have_abonnement() async {
    try {
      // Récupération du token depuis le stockage sécurisé
      String? token = await storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        print('Aucun token trouvé dans le storage');
        return false;
      }

      final response = await http.get(
        Uri.parse('${baseUrl}api/abonnement/user-abonnement'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        logger.log(Level.error, response.body);
        final responseData = json.decode(response.body);
        // Retourne true si la réponse n'est pas null et non vide

        return responseData != null && responseData.isNotEmpty;
      } else {
        print('Erreur API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur: $e');
      return false;
    }
  }

  Future<bool> updateAbonnement(int clientId, int abonnementId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/client/$clientId/abonnement/$abonnementId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      } else {
        try {
          final Map<String, dynamic> errorData = json.decode(response.body);
          throw Exception(
            'Failed to update abonnement: ${errorData['message'] ?? 'Unknown error'}',
          );
        } catch (e) {
          throw Exception('Failed to parse error response: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Failed to update abonnement: $e');
    }
  }
}
