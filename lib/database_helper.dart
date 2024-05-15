import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:api_dados/filter/model.dart'; // Certifique-se de que o caminho está correto para o seu modelo PersonModel.

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const sql = '''
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      avatarUrl TEXT,
      city TEXT NOT NULL,
      state TEXT NOT NULL,
      gender TEXT NOT NULL,
      age INTEGER NOT NULL
    );
    ''';
    await db.execute(sql);
  }

  Future<int> createUser(PersonModel user) async {
    try {
      final db = await database;
      return await db.rawInsert(
          'INSERT INTO users(id, name, username, email, avatarUrl, city, '
          'state, gender, age) VALUES(?,?,?,?,?,?,?,?,?)',
          [
            user.id,
            user.name,
            user.username,
            user.email,
            user.avatarUrl,
            user.city,
            user.state,
            user.gender,
            user.age,
          ]);
    } catch (e) {
      print('Error inserting user: $e');
      return 0;
    }
  }

  Future<PersonModel?> getUserId(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.rawQuery('SELECT * FROM users WHERE id = ?', [id]);
      if (results.isNotEmpty) {
        return PersonModel.fromMap(results.first);
      }
      return null;
    } catch (e) {
      print('Error fetching user by id: $e');
      return null;
    }
  }

  Future<int> updateUser(PersonModel user) async {
    try {
      final db = await database;
      final result = await db.rawUpdate(
          'UPDATE users SET name = ?, username = ?, email = ?, avatarUrl = ?,'
          'city = ?, state = ?, gender = ?, age = ? WHERE id = ?',
          [
            user.name,
            user.username,
            user.email,
            user.avatarUrl,
            user.city,
            user.state,
            user.gender,
            user.age,
            user.id,
          ]);
      return result;
    } catch (e) {
      print('Error updating user: $e');
      return 0;
    }
  }

  Future<int> deleteUser(String id) async {
    try {
      final db = await database;
      return await db.delete('users', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting user: $e');
      return 0;
    }
  }

  Future<List<PersonModel>> getAllUsers() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query('users');
      return results.map((map) => PersonModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
