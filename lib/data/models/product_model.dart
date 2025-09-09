import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required String id,
    required String userId,
    required String name,
    required double price,
    required int stock,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          name: name,
          price: price,
          stock: stock,
          createdAt: createdAt,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'price': price,
      'stock': stock,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      userId: product.userId,
      name: product.name,
      price: product.price,
      stock: product.stock,
      createdAt: product.createdAt,
    );
  }
}