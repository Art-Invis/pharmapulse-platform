class Medicine {
  final int id;
  final String name;
  final String activeSubstance;
  final double price;
  final bool isPrescriptionRequired;
  final String manufacturer;
  final int stock; // НОВЕ ПОЛЕ

  Medicine({
    required this.id,
    required this.name,
    required this.activeSubstance,
    required this.price,
    required this.isPrescriptionRequired,
    required this.manufacturer,
    required this.stock, // НОВЕ ПОЛЕ
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      activeSubstance: json['active_substance'],
      price: (json['price'] as num).toDouble(),
      isPrescriptionRequired: json['is_prescription_required'],
      manufacturer: json['manufacturer'],
      stock: json['stock'] ?? 0, // НОВЕ ПОЛЕ (з підстраховкою)
    );
  }
}