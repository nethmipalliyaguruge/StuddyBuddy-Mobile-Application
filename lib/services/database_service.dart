import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'studybuddy.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE search_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT NOT NULL UNIQUE,
        searched_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recently_viewed (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        module_name TEXT,
        preview_image TEXT,
        category TEXT,
        viewed_at TEXT NOT NULL
      )
    ''');
  }

  // ── Search History ──

  Future<void> insertSearch(String query) async {
    final db = await database;
    await db.insert(
      'search_history',
      {
        'query': query.trim(),
        'searched_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    final db = await database;
    return db.query(
      'search_history',
      orderBy: 'searched_at DESC',
      limit: 10,
    );
  }

  Future<void> deleteSearch(String query) async {
    final db = await database;
    await db.delete(
      'search_history',
      where: 'query = ?',
      whereArgs: [query],
    );
  }

  Future<void> clearSearchHistory() async {
    final db = await database;
    await db.delete('search_history');
  }

  // ── Recently Viewed ──

  Future<void> insertRecentlyViewed(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'recently_viewed',
      {
        'id': data['id'],
        'title': data['title'],
        'description': data['description'],
        'price': data['price'],
        'module_name': data['module_name'],
        'preview_image': data['preview_image'],
        'category': data['category'],
        'viewed_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final db = await database;
    return db.query(
      'recently_viewed',
      orderBy: 'viewed_at DESC',
      limit: 20,
    );
  }

  Future<void> clearRecentlyViewed() async {
    final db = await database;
    await db.delete('recently_viewed');
  }
}
