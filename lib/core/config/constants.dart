import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFFEBE325); // Jaune vif
  static const Color secondary = Color(0xFF1D1D1D); // Noir profond

  // Palette pour primary (noms génériques)
  static const Color primaryLight = Color(0xFFF9F7B2);
  static const Color primaryLighter = Color(0xFFF5F38E);
  static const Color primaryMedium = Color(0xFFEFEC5A);
  static const Color primaryDark = Color(0xFFD9D61D);
  static const Color primaryDarker = Color(0xFFC2BF0F);

  // Palette pour secondary (noms génériques)
  static const Color secondaryLight = Color(0xFF3A3A3A);
  static const Color secondaryLighter = Color(0xFF2D2D2D);
  static const Color secondaryMedium = Color(0xFF1D1D1D);
  static const Color secondaryDark = Color(0xFF121212);
  static const Color secondaryDarker = Color(0xFF000000);

  // Autres couleurs communes
  static const Color background = Color(0xFFF5F5F5); // Fond clair
  static const Color surface = Color(0xFFFFFFFF); // Surface blanche
  static const Color error = Color(0xFFD32F2F); // Rouge d'erreur
  static const Color success = Color(0xFF388E3C); // Vert de succès
  static const Color warning = Color(0xFFFFA000); // Orange d'avertissement
  static const Color info = Color(0xFF1976D2); // Bleu d'information

  // Textes
  static const Color textPrimary = Color(0xFF212121); // Texte principal
  static const Color textSecondary = Color(0xFF757575); // Texte secondaire
  static const Color textOnPrimary = Colors.black; // Texte sur fond primary
  static const Color textOnSecondary = Colors.white; // Texte sur fond secondary

  // Désactivé
  static const Color disabled = Color(
      0xFFBDBDBD); // État static const String api_url =  "https://mon-api.com";désactivé
  static const Color disabledText = Color(0xFF9E9E9E); // Texte désactivé

  // Nouveaux fonds proposés
  static const Color lightBackground =
      Color(0xFFF8F9FA); // Gris très léger bleuté
  static const Color lightSurface =
      Color(0xFFFFFFFF); // Blanc pur pour les surfaces

  // Alternative plus chaude
  static const Color warmLightBackground =
      Color(0xFFFDFDF6); // Blanc cassé très légèrement jaunâtre
  static const Color warmLightSurface =
      Color(0xFFFEFEF9); // Surface encore plus légère
}

class AppString {
  static const String appName = "Fasyl";
  static const String api_url =
      "http://backend.groupe-syl.com/backend-preprod/";
}
