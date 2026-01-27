import 'material.dart';

class CartItem {
  final int materialId;
  final StudyMaterial? material;
  int quantity;

  CartItem({
    required this.materialId,
    this.material,
    this.quantity = 1,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      materialId: json['material_id'] as int,
      material: json['material'] != null
          ? StudyMaterial.fromJson(json['material'] as Map<String, dynamic>)
          : null,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'material': material?.toJson(),
      'quantity': quantity,
    };
  }

  double get totalPrice => (material?.price ?? 0) * quantity;
}
