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
    // Handle both API format (title, status) and local JSON format (name, is_active)
    final isActive = json['is_active'] != null
        ? (json['is_active'] == 1 || json['is_active'] == true)
        : (json['status'] == true || json['status'] == 1);

    return Module(
      id: json['id'] as int,
      levelId: json['level_id'] as int,
      name: (json['name'] ?? json['title'] ?? '') as String,
      code: json['code'] as String?,
      description: json['description'] as String?,
      isActive: isActive,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Module && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

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
