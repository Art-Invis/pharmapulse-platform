class Promotion {
  final int id;
  final String title;
  final String description;
  final double discountPercent;
  final int? medicineId;
  final DateTime createdAt;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercent,
    this.medicineId,
    required this.createdAt,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      discountPercent: (json['discount_percent'] ?? 0).toDouble(),
      medicineId: json['medicine_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}