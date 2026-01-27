import 'material.dart';

class Purchase {
  final int id;
  final int userId;
  final int materialId;
  final double amount;
  final String? transactionId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StudyMaterial? material;

  Purchase({
    required this.id,
    required this.userId,
    required this.materialId,
    required this.amount,
    this.transactionId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.material,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      materialId: json['material_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      transactionId: json['transaction_id'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      material: json['material'] != null
          ? StudyMaterial.fromJson(json['material'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'material_id': materialId,
      'amount': amount,
      'transaction_id': transactionId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'material': material?.toJson(),
    };
  }
}
