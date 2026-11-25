class User {
  final int id;
  final String fullName;
  final String loyaltyTier;

  User({required this.id, required this.fullName, required this.loyaltyTier});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullName: json['full_name'],
      loyaltyTier: json['loyalty_tier'],
    );
  }
}