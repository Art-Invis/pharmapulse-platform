class Medicine {
  final int id;
  final String name;
  final String activeSubstance;
  final double price;
  final bool isPrescriptionRequired;
  final String manufacturer;

  Medicine({
    required this.id,
    required this.name,
    required this.activeSubstance,
    required this.price,
    required this.isPrescriptionRequired,
    required this.manufacturer,
  });

  // Фабричний метод для парсингу JSON від бекенду
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      activeSubstance: json['active_substance'],
      price: (json['price'] as num).toDouble(), // num.toDouble() захищає від помилок парсингу int/double
      isPrescriptionRequired: json['is_prescription_required'],
      manufacturer: json['manufacturer'],
    );
  }
}