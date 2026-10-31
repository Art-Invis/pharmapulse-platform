import 'order.dart';

class Prescription {
  final int id;
  final String code;
  final String doctorFullName;
  final String expiryDate;
  final bool isVerified;

  Prescription({
    required this.id,
    required this.code,
    required this.doctorFullName,
    required this.expiryDate,
    required this.isVerified,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'],
      code: json['code'],
      doctorFullName: json['doctor_full_name'],
      expiryDate: json['expiry_date'],
      isVerified: json['is_verified'],
    );
  }
}

class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String loyaltyTier;
  final List<Prescription> prescriptions;
  final List<Order> orders;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.loyaltyTier,
    required this.prescriptions,
    required this.orders,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      phone: json['phone'],
      loyaltyTier: json['loyalty_tier'],
      prescriptions: (json['prescriptions'] as List)
          .map((p) => Prescription.fromJson(p))
          .toList(),
      orders: (json['orders'] as List)
          .map((o) => Order.fromJson(o))
          .toList(),
    );
  }
}