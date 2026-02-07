DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null || value == '') return null;
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}

DateTime _parseDateTime(dynamic value) {
  return _parseNullableDateTime(value) ?? DateTime.now();
}

class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? profilePhotoUrl;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'student',
    this.profilePhotoUrl,
    this.emailVerifiedAt,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'student',
      profilePhotoUrl: json['profile_photo_url'] as String?,
      emailVerifiedAt: _parseNullableDateTime(json['email_verified_at']),
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_photo_url': profilePhotoUrl,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePhotoUrl,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
