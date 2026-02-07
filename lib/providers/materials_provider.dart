import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/material.dart';
import '../models/school.dart';
import '../models/level.dart';
import '../models/module.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MaterialsProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  List<StudyMaterial> _materials = [];
  List<School> _schools = [];
  List<Level> _levels = [];
  List<Module> _modules = [];
  StudyMaterial? _selectedMaterial;

  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  // Filters
  int? _selectedSchoolId;
  int? _selectedLevelId;
  int? _selectedModuleId;
  String? _searchQuery;
  double? _minPrice;
  double? _maxPrice;
  String? _sortBy;

  MaterialsProvider(this._apiService, this._storageService);

  List<StudyMaterial> get materials => _materials;
  List<School> get schools => _schools;
  List<Level> get levels => _levels;
  List<Module> get modules => _modules;
  StudyMaterial? get selectedMaterial => _selectedMaterial;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;

  int? get selectedSchoolId => _selectedSchoolId;
  int? get selectedLevelId => _selectedLevelId;
  int? get selectedModuleId => _selectedModuleId;
  String? get searchQuery => _searchQuery;

  Future<void> fetchSchools({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getSchools();
      final data = response.data['data'] ?? response.data;
      _schools = (data as List)
          .map((e) => School.fromJson(e as Map<String, dynamic>))
          .toList();
      _isOffline = false;

      await _storageService.saveToCache('schools', data);
    } catch (e, stackTrace) {
      debugPrint('fetchSchools error: $e');
      debugPrint('Stack trace: $stackTrace');
      await _loadFromCacheOrAssets('schools');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLevels({int? schoolId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getLevels(schoolId: schoolId);
      final data = response.data['data'] ?? response.data;
      final allLevels = (data as List)
          .map((e) => Level.fromJson(e as Map<String, dynamic>))
          .toList();
      // Filter by schoolId client-side in case the API doesn't filter
      final filtered = schoolId != null
          ? allLevels.where((level) => level.schoolId == schoolId).toList()
          : allLevels;
      // Deduplicate by id to avoid duplicate dropdown entries
      final seen = <int>{};
      _levels = filtered.where((level) => seen.add(level.id)).toList();
      _isOffline = false;

      await _storageService.saveToCache('levels', data);
    } catch (e, stackTrace) {
      debugPrint('fetchLevels error: $e');
      debugPrint('Stack trace: $stackTrace');
      await _loadFromCacheOrAssets('levels');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchModules({int? levelId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getModules(levelId: levelId);
      final data = response.data['data'] ?? response.data;
      _modules = (data as List)
          .map((e) => Module.fromJson(e as Map<String, dynamic>))
          .toList();
      _isOffline = false;

      await _storageService.saveToCache('modules', data);
    } catch (e, stackTrace) {
      debugPrint('fetchModules error: $e');
      debugPrint('Stack trace: $stackTrace');
      await _loadFromCacheOrAssets('modules');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMaterials({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMaterials(
        schoolId: _selectedSchoolId,
        levelId: _selectedLevelId,
        moduleId: _selectedModuleId,
        search: _searchQuery,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sort: _sortBy,
      );
      final data = response.data['data'] ?? response.data;
      _materials = (data as List)
          .map((e) => StudyMaterial.fromJson(e as Map<String, dynamic>))
          .toList();
      _isOffline = false;

      await _storageService.saveToCache('materials', data);
    } catch (e, stackTrace) {
      debugPrint('fetchMaterials error: $e');
      debugPrint('Stack trace: $stackTrace');
      await _loadFromCacheOrAssets('materials');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMaterial(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMaterial(id);
      final data = response.data['data'] ?? response.data;
      _selectedMaterial = StudyMaterial.fromJson(data as Map<String, dynamic>);
      _isOffline = false;
    } catch (e) {
      _error = 'Failed to fetch material details';
      _selectedMaterial = _materials.firstWhere(
        (m) => m.id == id,
        orElse: () => throw Exception('Material not found'),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedMaterial(StudyMaterial? material) {
    _selectedMaterial = material;
    notifyListeners();
  }

  void setFilters({
    int? schoolId,
    int? levelId,
    int? moduleId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) {
    _selectedSchoolId = schoolId;
    _selectedLevelId = levelId;
    _selectedModuleId = moduleId;
    _searchQuery = search;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _sortBy = sortBy;
    notifyListeners();
  }

  void clearFilters() {
    _selectedSchoolId = null;
    _selectedLevelId = null;
    _selectedModuleId = null;
    _searchQuery = null;
    _minPrice = null;
    _maxPrice = null;
    _sortBy = null;
    notifyListeners();
  }

  void setSearch(String? query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _loadFromCacheOrAssets(String key) async {
    try {
      final cached = await _storageService.getFromCache<List<dynamic>>(key);
      if (cached != null) {
        _parseData(key, cached);
        _isOffline = true;
        return;
      }

      final jsonString = await rootBundle.loadString('assets/json/$key.json');
      final data = jsonDecode(jsonString) as List<dynamic>;
      _parseData(key, data);
      _isOffline = true;
    } catch (e) {
      _error = 'Failed to load $key data';
    }
  }

  void _parseData(String key, List<dynamic> data) {
    switch (key) {
      case 'schools':
        _schools = data.map((e) => School.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case 'levels':
        _levels = data.map((e) => Level.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case 'modules':
        _modules = data.map((e) => Module.fromJson(e as Map<String, dynamic>)).toList();
        break;
      case 'materials':
        _materials = data.map((e) => StudyMaterial.fromJson(e as Map<String, dynamic>)).toList();
        break;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
