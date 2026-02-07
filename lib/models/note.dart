import 'module.dart';

class Note {
  final int id;
  final int userId;
  final int moduleId;
  final String title;
  final String? description;
  final String? filePath;
  final List<String> previewImages;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Module? module;

  String? get previewImage => previewImages.isNotEmpty ? previewImages.first : null;

  Note({
    required this.id,
    required this.userId,
    required this.moduleId,
    required this.title,
    this.description,
    this.filePath,
    this.previewImages = const [],
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.module,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    // Handle isActive from both API format (status string) and local JSON (is_active bool)
    final isActive = json['is_active'] != null
        ? (json['is_active'] == 1 || json['is_active'] == true)
        : (json['status'] == 'approved' || json['status'] == true);

    // Handle file path from both API format (note_file object) and local JSON (file_path string)
    String? filePath = json['file_path'] as String?;
    if (filePath == null && json['note_file'] != null && json['note_file'] is Map) {
      filePath = json['note_file']['file_name'] as String?;
    }

    // Handle preview images from both API format (previews array) and local JSON (preview_images/preview_image)
    List<String> previewImages = [];
    if (json['previews'] != null && json['previews'] is List) {
      final previews = json['previews'] as List;
      for (final p in previews) {
        if (p is Map && p['url'] != null) {
          previewImages.add(p['url'] as String);
        }
      }
    }
    if (previewImages.isEmpty && json['preview_images'] != null && json['preview_images'] is List) {
      previewImages = (json['preview_images'] as List).whereType<String>().toList();
    }
    if (previewImages.isEmpty && json['preview_image'] != null) {
      previewImages = [json['preview_image'] as String];
    }

    return Note(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      moduleId: json['module_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      filePath: filePath,
      previewImages: previewImages,
      price: (json['price'] as num).toDouble(),
      isActive: isActive,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'preview_images': previewImages,
      'price': price,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'module': module?.toJson(),
    };
  }
}
