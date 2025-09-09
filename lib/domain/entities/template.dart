import 'package:equatable/equatable.dart';

class Template extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String category;
  final int usageCount;
  final DateTime createdAt;

  const Template({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.category,
    required this.usageCount,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        userId,
        title,
        content,
        category,
        usageCount,
        createdAt,
      ];

  Template copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? category,
    int? usageCount,
    DateTime? createdAt,
  }) {
    return Template(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}