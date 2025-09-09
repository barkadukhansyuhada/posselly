import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    String? phone,
    String? businessName,
    required DateTime createdAt,
    required DateTime lastActive,
  }) : super(
          id: id,
          email: email,
          phone: phone,
          businessName: businessName,
          createdAt: createdAt,
          lastActive: lastActive,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      businessName: json['business_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActive: DateTime.parse(json['last_active'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'business_name': businessName,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phone: user.phone,
      businessName: user.businessName,
      createdAt: user.createdAt,
      lastActive: user.lastActive,
    );
  }
}