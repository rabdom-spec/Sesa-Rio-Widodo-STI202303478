import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/destination_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('destinations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) {
        // Verify database is ready
        print('Database opened at: $path');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE destinations (
      id $idType,
      name $textType,
      description $textType,
      latitude $realType,
      longitude $realType,
      openTime TEXT,
      closeTime TEXT,
      imagePath TEXT,
      createdAt TEXT NOT NULL
    )
    ''');
  }

  Future<int> create(Destination destination) async {
    try {
      final db = await instance.database;
      final id = await db.insert('destinations', destination.toMap());
      print('Destination created with id: $id');
      return id;
    } catch (e) {
      print('Error creating destination: $e');
      rethrow;
    }
  }

  Future<List<Destination>> readAll() async {
    try {
      final db = await instance.database;
      const orderBy = 'createdAt DESC';
      final result = await db.query('destinations', orderBy: orderBy);
      return result.map((json) => Destination.fromMap(json)).toList();
    } catch (e) {
      print('Error reading destinations: $e');
      return [];
    }
  }

  Future<Destination?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'destinations',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Destination.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> update(Destination destination) async {
    final db = await instance.database;
    return db.update(
      'destinations',
      destination.toMap(),
      where: 'id = ?',
      whereArgs: [destination.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'destinations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Destination>> search(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'destinations',
      where: 'name LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Destination.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
