import 'user.dart';
import 'module.dart';

class StudyMaterial {
  final int id;
  final int userId;
  final int moduleId;
  final String title;
  final String? description;
  final String? filePath;
  final String? previewImage;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? seller;
  final Module? module;

  StudyMaterial({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.title,
    this.description,
    this.filePath,
    this.previewImage,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
    this.module,
  });

  factory StudyMaterial.fromJson(Map<String, dynamic> json) {
    return StudyMaterial(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      moduleId: json['module_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      filePath: json['file_path'] as String?,
      previewImage: json['preview_image'] as String?,
      price: (json['price'] as num).toDouble(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      seller: json['seller'] != null || json['user'] != null
          ? User.fromJson((json['seller'] ?? json['user']) as Map<String, dynamic>)
          : null,
      module: json['module'] != null
          ? Module.fromJson(json['module'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'file_path': filePath,
      'preview_image': previewImage,
      'price': price,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'seller': seller?.toJson(),
      'module': module?.toJson(),
    };
  }
}
