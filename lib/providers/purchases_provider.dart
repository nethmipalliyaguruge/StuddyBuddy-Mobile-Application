import 'package:flutter/foundation.dart';
import '../models/purchase.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class PurchasesProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  List<Purchase> _purchases = [];
  Purchase? _selectedPurchase;
  bool _isLoading = false;
  String? _error;

  PurchasesProvider(this._apiService, this._storageService);

  List<Purchase> get purchases => _purchases;
  Purchase? get selectedPurchase => _selectedPurchase;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get purchaseCount => _purchases.length;

  double get totalSpent {
    return _purchases.fold(0, (total, purchase) => total + purchase.amount);
  }

  Future<void> fetchPurchases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyPurchases();
      final data = response.data['data'] ?? response.data;
      _purchases = (data as List)
          .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
          .toList();

      await _storageService.saveToCache('my_purchases', data);
    } catch (e) {
      final cached = await _storageService.getFromCache<List<dynamic>>('my_purchases');
      if (cached != null) {
        _purchases = cached
            .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = 'Failed to fetch purchases';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPurchase(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getPurchase(id);
      final data = response.data['data'] ?? response.data;
      _selectedPurchase = Purchase.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      _error = 'Failed to fetch purchase details';
      _selectedPurchase = _purchases.firstWhere(
        (p) => p.id == id,
        orElse: () => throw Exception('Purchase not found'),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedPurchase(Purchase? purchase) {
    _selectedPurchase = purchase;
    notifyListeners();
  }

  /// Build a download URI for a purchased material, with the auth token
  /// appended as a query parameter (needed for browser-based downloads).
  Future<Uri?> getDownloadUrl(int materialId) async {
    final token = await _storageService.getToken();
    if (token == null) return null;
    final downloadUrl = _apiService.getDownloadUrl(materialId);
    return Uri.parse('$downloadUrl?token=$token');
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
