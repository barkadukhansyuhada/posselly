import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double price;
  final int stock;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.price,
    required this.stock,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        userId,
        name,
        price,
        stock,
        createdAt,
      ];

  Product copyWith({
    String? id,
    String? userId,
    String? name,
    double? price,
    int? stock,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}