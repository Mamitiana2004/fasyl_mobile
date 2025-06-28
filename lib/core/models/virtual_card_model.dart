class VirtualCard {
  final int id;
  final int userId;
  final String qrCodeUrl;
  final String cardNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  VirtualCard({
    required this.id,
    required this.userId,
    required this.qrCodeUrl,
    required this.cardNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VirtualCard.fromJson(Map<String, dynamic> json) {
    return VirtualCard(
      id: json['id'],
      userId: json['userId'],
      qrCodeUrl: json['qrCodeUrl'],
      cardNumber: json['cardNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
