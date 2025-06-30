import 'package:flutter/material.dart';

class AbonnementModel {
  final int id;
  final String name;
  final String price;
  final int daysDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  AbonnementModel({
    required this.id,
    required this.name,
    required this.price,
    required this.daysDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AbonnementModel.fromJson(Map<String, dynamic> json) {
    return AbonnementModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      daysDuration: json['daysDuration'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  String get formattedPrice {
    final double priceValue = double.parse(price);
    return '${priceValue.toStringAsFixed(0)} Ar';
  }

  String get durationText {
    if (daysDuration >= 365) {
      final years = (daysDuration / 365).round();
      return years == 1 ? '1 an' : '$years ans';
    } else if (daysDuration >= 30) {
      final months = (daysDuration / 30).round();
      return months == 1 ? '1 mois' : '$months mois';
    } else if (daysDuration >= 7) {
      final weeks = (daysDuration / 7).round();
      return weeks == 1 ? '1 semaine' : '$weeks semaines';
    } else {
      return daysDuration == 1 ? '1 jour' : '$daysDuration jours';
    }
  }

  IconData get iconData {
    if (name.toLowerCase().contains('premium') ||
        name.toLowerCase().contains('annuel')) {
      return Icons.diamond;
    } else if (name.toLowerCase().contains('événementiel') ||
        name.toLowerCase().contains('evenementiel')) {
      return Icons.event;
    } else {
      return Icons.star;
    }
  }

  Color get gradientStartColor {
    if (name.toLowerCase().contains('premium') ||
        name.toLowerCase().contains('annuel')) {
      return const Color(0xFF8B5CF6);
    } else if (name.toLowerCase().contains('événementiel') ||
        name.toLowerCase().contains('evenementiel')) {
      return const Color(0xFF10B981);
    } else {
      return const Color(0xFF3B82F6);
    }
  }

  Color get gradientEndColor {
    if (name.toLowerCase().contains('premium') ||
        name.toLowerCase().contains('annuel')) {
      return const Color(0xFF6366F1);
    } else if (name.toLowerCase().contains('événementiel') ||
        name.toLowerCase().contains('evenementiel')) {
      return const Color(0xFF059669);
    } else {
      return const Color(0xFF1E40AF);
    }
  }

  bool get isPopular {
    return name.toLowerCase().contains('premium') ||
        name.toLowerCase().contains('annuel');
  }

  /// Calcule la date de fin d'abonnement à partir d'une date de début donnée
  /// Si aucune date de début n'est fournie, utilise la date actuelle
  DateTime getEndDate([DateTime? startDate]) {
    final start = startDate ?? DateTime.now();
    return start.add(Duration(days: daysDuration));
  }

  /// Calcule la date de fin d'abonnement formatée
  /// Si aucune date de début n'est fournie, utilise la date actuelle
  String getFormattedEndDate([DateTime? startDate]) {
    final endDate = getEndDate(startDate);
    return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
  }

  /// Vérifie si l'abonnement est encore actif à une date donnée
  /// Si aucune date de début n'est fournie, utilise la date de création
  bool isActiveAt(DateTime checkDate, [DateTime? startDate]) {
    final start = startDate ?? createdAt;
    final end = getEndDate(start);
    return checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end);
  }

  /// Calcule le nombre de jours restants depuis une date de début donnée
  /// Retourne 0 si l'abonnement est expiré
  int getRemainingDays([DateTime? startDate]) {
    final start = startDate ?? DateTime.now();
    final end = getEndDate(start);
    final now = DateTime.now();

    if (now.isAfter(end)) {
      return 0; // Abonnement expiré
    }

    return end.difference(now).inDays + 1;
  }
}
