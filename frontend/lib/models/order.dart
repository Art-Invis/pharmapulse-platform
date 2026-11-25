class Order {
  final int id;
  final int userId;
  final String deliveryType;
  final String status;
  final double rawTotal;
  final double finalPrice;
  final String createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.deliveryType,
    required this.status,
    required this.rawTotal,
    required this.finalPrice,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      deliveryType: json['delivery_type'],
      status: json['status'],
      rawTotal: (json['raw_total'] as num).toDouble(),
      finalPrice: (json['final_price'] as num).toDouble(),
      createdAt: json['created_at'],
    );
  }
}