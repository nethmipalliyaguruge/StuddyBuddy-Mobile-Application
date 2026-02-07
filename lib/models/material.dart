import 'user.dart';
import 'module.dart';

DateTime _parseDateTime(dynamic value) {
  if (value == null || value == '') return DateTime.now();
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }
  return DateTime.now();
}

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
    // Handle isActive from both API format (status string) and local JSON (is_active bool)
    final isActive = json['is_active'] != null
        ? (json['is_active'] == 1 || json['is_active'] == true)
        : (json['status'] == 'approved' || json['status'] == true);

    // Handle file path from both API format (note_file object) and local JSON (file_path string)
    String? filePath = json['file_path'] as String?;
    if (filePath == null && json['note_file'] != null && json['note_file'] is Map) {
      filePath = json['note_file']['file_name'] as String?;
    }

    // Handle preview image from both API format (previews array) and local JSON (preview_image string)
    String? previewImage = json['preview_image'] as String?;
    if (previewImage == null && json['previews'] != null && json['previews'] is List) {
      final previews = json['previews'] as List;
      if (previews.isNotEmpty && previews.first is Map) {
        previewImage = previews.first['url'] as String?;
      }
    }

    return StudyMaterial(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      moduleId: json['module_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      filePath: filePath,
      previewImage: previewImage,
      price: (json['price'] as num).toDouble(),
      isActive: isActive,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      seller: json['seller'] != null || json['user'] != null
          ? User.fromJson((json['seller'] ?? json['user']) as Map<String, dynamic>)
          : null,
      module: json['module'] != null && json['module'] is Map
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
