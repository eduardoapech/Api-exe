import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/models/filter_model.dart';

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
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    const sql = '''
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      name_sem_acento TEXT NOT NULL,
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

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN name TEXT;');
      } catch (_) {}
    }
    if (oldVersion < newVersion) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN name_sem_acento TEXT NOT NULL DEFAULT \' \' ');
      } catch (_) {}
    }
  }

  Future<int> createUser(PersonModel user) async {
    try {
      final db = await database;
      return await db.rawInsert(
          'INSERT INTO users(id, name, name_sem_acento, username, email, avatarUrl, city, '
          'state, gender, age) VALUES(?,?,?,?,?,?,?,?,?,?)',
          [
            user.id,
            user.name,
            removeDiacritics(user.name),
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
          'UPDATE users SET name = ?, name_sem_acento = ?, username = ?, email = ?, avatarUrl = ?,'
          'city = ?, state = ?, gender = ?, age = ? WHERE id = ?',
          [
            user.name,
            removeDiacritics(user.name),
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
      print('Erro ao deletar usuário: $e');
      return 0;
    }
  }

  void addFilter(
    StringBuffer whereClause,
    List<String> whereArgs,
    String column,
    String? value, {
    String operator = '=',
  }) {
    if (value != null && value.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause.write(' AND ');
      whereClause.write('$column $operator ?');
      whereArgs.add(value);
    }
  }

  Future<List<PersonModel>> getAllUsers(FilterModel filtroPessoa) async {
    try {
      final db = await database;
      StringBuffer whereClause = StringBuffer();
      List<String> whereArgs = [];

      if (filtroPessoa.name != null && filtroPessoa.name!.isNotEmpty) {
        String nameSemAcento = removeDiacritics(filtroPessoa.name!);
        addFilter(whereClause, whereArgs, 'name_sem_acento', '%$nameSemAcento%', operator: 'LIKE');
      }
      addFilter(whereClause, whereArgs, 'gender', filtroPessoa.gender);
      if (filtroPessoa.minAge != null) {
        addFilter(whereClause, whereArgs, 'age', filtroPessoa.minAge.toString(), operator: '>');
      }
      if (filtroPessoa.maxAge != null) {
        addFilter(whereClause, whereArgs, 'age', filtroPessoa.maxAge.toString(), operator: '<');
      }

      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: whereClause.isNotEmpty ? whereClause.toString() : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      print('Procurando dados no banco de dados... encontrado: $results');
      return results.map((map) => PersonModel.fromMap(map)).toList();
    } catch (e) {
      print('Erro ao buscar todos os usuários: $e');
      return [];
    }
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
