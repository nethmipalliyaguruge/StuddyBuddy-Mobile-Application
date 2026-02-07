import 'level.dart';

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

class School {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Level>? levels;

  School({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.levels,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      levels: json['levels'] != null
          ? (json['levels'] as List)
              .map((e) => Level.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is School && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'levels': levels?.map((e) => e.toJson()).toList(),
    };
  }
}
