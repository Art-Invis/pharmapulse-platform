class PharmacyBranch {
  final int id;
  final String address;
  final String phone;

  PharmacyBranch({
    required this.id,
    required this.address,
    required this.phone,
  });

  factory PharmacyBranch.fromJson(Map<String, dynamic> json) {
    return PharmacyBranch(
      id: json['id'],
      address: json['address'],
      phone: json['phone'],
    );
  }
}