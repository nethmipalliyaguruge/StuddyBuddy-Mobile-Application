import 'module.dart';

class Level {
  final int id;
  final int schoolId;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Module>? modules;

  Level({
    required this.id,
    required this.schoolId,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.modules,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as int,
      schoolId: json['school_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      modules: json['modules'] != null
          ? (json['modules'] as List)
              .map((e) => Module.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'modules': modules?.map((e) => e.toJson()).toList(),
    };
  }
}
