class Module {
  final int id;
  final int levelId;
  final String name;
  final String? code;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Module({
    required this.id,
    required this.levelId,
    required this.name,
    this.code,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as int,
      levelId: json['level_id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level_id': levelId,
      'name': name,
      'code': code,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
