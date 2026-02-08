import 'package:flutter/foundation.dart';
import 'package:studybuddy/services/database_service.dart';

class SearchHistoryProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<String> _history = [];

  SearchHistoryProvider(this._databaseService);

  List<String> get history => _history;

  Future<void> loadHistory() async {
    final rows = await _databaseService.getSearchHistory();
    _history = rows.map((row) => row['query'] as String).toList();
    notifyListeners();
  }

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await _databaseService.insertSearch(trimmed);
    await loadHistory();
  }

  Future<void> removeSearch(String query) async {
    await _databaseService.deleteSearch(query);
    await loadHistory();
  }

  Future<void> clearHistory() async {
    await _databaseService.clearSearchHistory();
    _history = [];
    notifyListeners();
  }
}
