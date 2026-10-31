class OrderItem {
  final int medicineId;
  final int quantity;
  final double pricePerUnit;

  OrderItem({required this.medicineId, required this.quantity, required this.pricePerUnit});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      medicineId: json['medicine_id'],
      quantity: json['quantity'],
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
    );
  }
}

class Order {
  final int id;
  final int userId;
  final String deliveryType;
  final String status;
  final double rawTotal;
  final double finalPrice;
  final String createdAt;
  final List<OrderItem> items; // ДОДАНО

  Order({
    required this.id,
    required this.userId,
    required this.deliveryType,
    required this.status,
    required this.rawTotal,
    required this.finalPrice,
    required this.createdAt,
    required this.items, // ДОДАНО
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
      items: json['items'] != null 
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList()
          : [], // ДОДАНО
    );
  }
}

