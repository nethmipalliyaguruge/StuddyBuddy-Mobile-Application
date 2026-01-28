import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CartProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  CartProvider(this._apiService, this._storageService);

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.totalPrice);
  }

  Future<void> loadCart() async {
    final cached = await _storageService.getFromCache<List<dynamic>>('cart');
    if (cached != null) {
      _items = cached
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> addItem(StudyMaterial material) async {
    final existingIndex = _items.indexWhere((item) => item.materialId == material.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        materialId: material.id,
        material: material,
        quantity: 1,
      ));
    }

    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(int materialId) async {
    _items.removeWhere((item) => item.materialId == materialId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(int materialId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(materialId);
      return;
    }

    final index = _items.indexWhere((item) => item.materialId == materialId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> incrementQuantity(int materialId) async {
    final index = _items.indexWhere((item) => item.materialId == materialId);
    if (index >= 0) {
      _items[index].quantity++;
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> decrementQuantity(int materialId) async {
    final index = _items.indexWhere((item) => item.materialId == materialId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        await _saveCart();
        notifyListeners();
      } else {
        await removeItem(materialId);
      }
    }
  }

  bool isInCart(int materialId) {
    return _items.any((item) => item.materialId == materialId);
  }

  Future<void> clearCart() async {
    _items.clear();
    await _storageService.removeFromCache('cart');
    notifyListeners();
  }

  Future<void> syncWithServer() async {
    if (_items.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cartIds = _items.map((item) => item.materialId).toList();
      final response = await _apiService.getCartItems(cartIds);
      final data = response.data['data'] ?? response.data;

      if (data is List) {
        final validMaterials = data
            .map((e) => StudyMaterial.fromJson(e as Map<String, dynamic>))
            .toList();

        _items = _items.where((item) {
          return validMaterials.any((m) => m.id == item.materialId);
        }).map((item) {
          final material = validMaterials.firstWhere(
            (m) => m.id == item.materialId,
          );
          return CartItem(
            materialId: item.materialId,
            material: material,
            quantity: item.quantity,
          );
        }).toList();

        await _saveCart();
      }
    } catch (e) {
      _error = 'Failed to sync cart with server';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkout() async {
    if (_items.isEmpty) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final materialIds = _items.map((item) => item.materialId).toList();
      await _apiService.checkout(materialIds);
      await clearCart();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Checkout failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveCart() async {
    final cartData = _items.map((item) => item.toJson()).toList();
    await _storageService.saveToCache('cart', cartData);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
