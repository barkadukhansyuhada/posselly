import '../../domain/entities/template.dart';

class TemplateModel extends Template {
  const TemplateModel({
    required String id,
    required String userId,
    required String title,
    required String content,
    required String category,
    required int usageCount,
    required DateTime createdAt,
  }) : super(
          id: id,
          userId: userId,
          title: title,
          content: content,
          category: category,
          usageCount: usageCount,
          createdAt: createdAt,
        );

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      usageCount: json['usage_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'usage_count': usageCount,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TemplateModel.fromEntity(Template template) {
    return TemplateModel(
      id: template.id,
      userId: template.userId,
      title: template.title,
      content: template.content,
      category: template.category,
      usageCount: template.usageCount,
      createdAt: template.createdAt,
    );
  }
}