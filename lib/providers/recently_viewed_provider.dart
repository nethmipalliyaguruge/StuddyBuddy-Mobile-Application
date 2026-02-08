import 'package:flutter/foundation.dart';
import 'package:studybuddy/models/material.dart';
import 'package:studybuddy/services/database_service.dart';

class RecentlyViewedProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<StudyMaterial> _recentlyViewed = [];
  final Map<int, String> _categories = {};

  RecentlyViewedProvider(this._databaseService);

  List<StudyMaterial> get recentlyViewed => _recentlyViewed;

  String? categoryFor(int materialId) => _categories[materialId];

  Future<void> loadRecentlyViewed() async {
    final rows = await _databaseService.getRecentlyViewed();
    _recentlyViewed = rows.map(_materialFromRow).toList();
    _categories.clear();
    for (final row in rows) {
      if (row['category'] != null) {
        _categories[row['id'] as int] = row['category'] as String;
      }
    }
    notifyListeners();
  }

  Future<void> addToRecentlyViewed(StudyMaterial material, String? category) async {
    await _databaseService.insertRecentlyViewed({
      'id': material.id,
      'title': material.title,
      'description': material.description,
      'price': material.price,
      'module_name': material.module?.name,
      'preview_image': material.previewImage,
      'category': category,
    });
    await loadRecentlyViewed();
  }

  Future<void> clearHistory() async {
    await _databaseService.clearRecentlyViewed();
    _recentlyViewed = [];
    _categories.clear();
    notifyListeners();
  }

  StudyMaterial _materialFromRow(Map<String, dynamic> row) {
    return StudyMaterial(
      id: row['id'] as int,
      userId: 0,
      moduleId: 0,
      title: row['title'] as String,
      description: row['description'] as String?,
      price: (row['price'] as num).toDouble(),
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
