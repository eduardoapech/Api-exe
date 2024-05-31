import 'package:sqflite/sqflite.dart'; // Importa a biblioteca sqflite para manipulação de banco de dados SQLite
import 'package:path/path.dart'; // Importa a biblioteca path para manipulação de caminhos de arquivos
import 'package:api_dados/models/person_model.dart'; // Importa o modelo PersonModel
import 'package:api_dados/models/filter_model.dart'; // Importa o modelo FilterModel
import 'package:remove_diacritic/remove_diacritic.dart'; // Importa a biblioteca remove_diacritic

// Classe para gerenciar o banco de dados SQLite
class DatabaseHelper {
  // Singleton para garantir que apenas uma instância do DatabaseHelper seja criada
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Construtor privado para o singleton
  DatabaseHelper._init();
  
  // Método para obter a instância do banco de dados, inicializando-o se necessário
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('users.db'); // Inicializa o banco de dados com o nome 'users.db'
    return _database!;
  }
  
  // Método para inicializar o banco de dados
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // Obtém o caminho do diretório do banco de dados
    final path = join(dbPath, filePath); // Cria o caminho completo para o banco de dados
    return await openDatabase(path, version: 1, onCreate: _createDB, onUpgrade: _upgradeDB); // Abre o banco de dados e chama _createDB se ele não existir
  }

  // Método para atualizar o banco de dados
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async { 
    if (oldVersion < 2) { 
      await db.execute('ALTER TABLE users ADD COLUMN phone TEXT;');
    }
  }

  // Método para criar as tabelas no banco de dados
  Future _createDB(Database db, int version) async {
    const sqlWithAccents = '''
    CREATE TABLE IF NOT EXISTS users_with_accents (
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

    const sqlWithoutAccents = '''
    CREATE TABLE IF NOT EXISTS users_without_accents (
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

    await db.execute(sqlWithAccents);
    await db.execute(sqlWithoutAccents);
  }

  // Método para inserir um usuário no banco de dados
  Future<int> createUser(PersonModel user) async {
    try {
      final db = await database;
      // Insere o usuário na tabela 'users_with_accents'
      await db.insert('users_with_accents', user.toMap());
      // Insere o usuário na tabela 'users_without_accents' com o nome sem acentos
      return await db.insert('users_without_accents', user.toMap()..['name_without_accents'] = removeDiacritics(user.name));
    } catch (e) {
      print('Error inserting user: $e');
      return 0;
    }
  }

  // Método para atualizar um usuário no banco de dados
  Future<int> updateUser(PersonModel user) async {
    try {
      final db = await database;
      // Atualiza o usuário na tabela 'users_with_accents'
      await db.update(
        'users_with_accents',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [user.id],
      );
      // Atualiza o usuário na tabela 'users_without_accents' com o nome sem acentos
      return await db.update(
        'users_without_accents',
        user.toMap()..['name'] = removeDiacritics(user.name),
        where: 'id = ?',
        whereArgs: [user.id],
      );
    } catch (e) {
      print('Error updating user: $e');
      return 0;
    }
  }

  // Método para deletar um usuário do banco de dados
  Future<int> deleteUser(String id) async {
    try {
      final db = await database;
      // Deleta o usuário das tabelas 'users_with_accents' e 'users_without_accents'
      await db.delete('users_with_accents', where: 'id = ?', whereArgs: [id]);
      return await db.delete('users_without_accents', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting user: $e');
      return 0;
    }
  }

  // Método para obter todos os usuários aplicando filtros
  Future<List<PersonModel>> getAllUsers(FilterModel filtroPessoa, {bool useAccents = true}) async {
    try {
      final db = await database;
      String whereClause = '';
      List<dynamic> whereArgs = [];
      String tableName = useAccents ? 'users_with_accents' : 'users_without_accents';

      if (filtroPessoa.name != null && filtroPessoa.name!.isNotEmpty) {
        whereClause += 'name LIKE ?';
        whereArgs.add('%${useAccents ? filtroPessoa.name : removeDiacritics(filtroPessoa.name!)}%');
      }
      if (filtroPessoa.gender != null && filtroPessoa.gender!.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'gender = ?';
        whereArgs.add(filtroPessoa.gender);
      }
      if (filtroPessoa.minAge != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'age >= ?';
        whereArgs.add(filtroPessoa.minAge);
      }
      if (filtroPessoa.maxAge != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'age <= ?';
        whereArgs.add(filtroPessoa.maxAge);
      }
      final List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      return results.map((map) => PersonModel.fromMap(map)).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  // Método para obter um usuário pelo ID
  Future<PersonModel?> getUserId(String id, {bool useAccents = true}) async {
    try {
      final db = await database;
      String tableName = useAccents ? 'users_with_accents' : 'users_without_accents';
      final List<Map<String, dynamic>> results = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isNotEmpty) {
        return PersonModel.fromMap(results.first);
      }
      return null;
    } catch (e) {
      print('Error fetching user by id: $e');
      return null;
    }
  }

  // Método para fechar o banco de dados
  Future close() async {
    final db = await database;
    db.close(); // Fecha o banco de dados
  }
}