import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? phone;
  final String? businessName;
  final DateTime createdAt;
  final DateTime lastActive;
  
  const User({
    required this.id,
    required this.email,
    this.phone,
    this.businessName,
    required this.createdAt,
    required this.lastActive,
  });
  
  @override
  List<Object?> get props => [
        id,
        email,
        phone,
        businessName,
        createdAt,
        lastActive,
      ];
  
  User copyWith({
    String? id,
    String? email,
    String? phone,
    String? businessName,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      businessName: businessName ?? this.businessName,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}