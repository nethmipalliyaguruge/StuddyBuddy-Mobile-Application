import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class NotesProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  List<Note> _notes = [];
  Note? _selectedNote;
  bool _isLoading = false;
  String? _error;

  NotesProvider(this._apiService, this._storageService);

  List<Note> get notes => _notes;
  Note? get selectedNote => _selectedNote;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get noteCount => _notes.length;

  Future<void> fetchNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getMyNotes();
      final data = response.data['data'] ?? response.data;
      _notes = (data as List)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();

      await _storageService.saveToCache('my_notes', data);
    } catch (e) {
      final cached = await _storageService.getFromCache<List<dynamic>>('my_notes');
      if (cached != null) {
        _notes = cached
            .map((e) => Note.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = 'Failed to fetch notes';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNote({
    required String title,
    required String description,
    required int moduleId,
    required double price,
    Uint8List? fileBytes,
    String? fileName,
    List<Uint8List>? previewImageBytesList,
    List<String>? previewImageNames,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (fileBytes != null || (previewImageBytesList != null && previewImageBytesList.isNotEmpty)) {
        await _apiService.createNoteWithFile(
          title: title,
          description: description,
          moduleId: moduleId,
          price: price,
          fileBytes: fileBytes,
          fileName: fileName,
          previewImageBytesList: previewImageBytesList,
          previewImageNames: previewImageNames,
        );
      } else {
        await _apiService.createNote({
          'title': title,
          'description': description,
          'module_id': moduleId,
          'price': price,
        });
      }

      await fetchNotes();
      return true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          _error = data['message'].toString();
        } else {
          _error = 'Failed to create note (${e.response!.statusCode})';
        }
      } else {
        _error = 'Failed to create note: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateNote({
    required int id,
    String? title,
    String? description,
    int? moduleId,
    double? price,
    bool? isActive,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (moduleId != null) data['module_id'] = moduleId;
      if (price != null) data['price'] = price;
      if (isActive != null) data['is_active'] = isActive;

      await _apiService.updateNote(id, data);
      await fetchNotes();
      return true;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          _error = data['message'].toString();
        } else {
          _error = 'Failed to update note (${e.response!.statusCode})';
        }
      } else {
        _error = 'Failed to update note: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteNote(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteNote(id);
      _notes.removeWhere((note) => note.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete note';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setSelectedNote(Note? note) {
    _selectedNote = note;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
