import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:sqflite/sqflite.dart'; // Importa a biblioteca sqflite para manipulação de banco de dados SQLite
import 'package:path/path.dart'; // Importa a biblioteca path para manipulação de caminhos de arquivos
import 'package:api_dados/models/person_model.dart'; // Importa o modelo PersonModel
import 'package:api_dados/models/filter_model.dart'; // Importa o modelo FilterModel

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
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB); // Abre o banco de dados e chama _createDB se ele não existir
  }

  // Método para criar a tabela no banco de dados
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
    await db.execute(sql); // Executa a criação da tabela
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
    // Adicione mais condições conforme necessário para futuras versões
  }

  // Método para inserir um usuário no banco de dados
  Future<int> createUser(PersonModel user) async {
    try {
      final db = await database;
      return await db.rawInsert(
          'INSERT INTO users(id, name, name_sem_acento, username, email, avatarUrl, city, '
          'state, gender, age) VALUES(?,?,?,?,?,?,?,?,?,?)',
          [
            user.id,
            user.name,
            removeDiacritics(user.name), // Salva o nome sem acento
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

  // Método para obter um usuário pelo ID
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

  // Método para deletar um usuário do banco de dados
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
    String operator = '',
  }) {
    if (value != null && value.isNotEmpty) {
      if (whereClause.isNotEmpty) whereClause.write(' AND ');
      whereClause.write('$column $operator ?');
      whereArgs.add(value);
    }
  }

  // Método para obter todos os usuários aplicando filtros
  Future<List<PersonModel>> getAllUsers(FilterModel filtroPessoa) async {
    try {
      final db = await database;
      StringBuffer whereClause = StringBuffer(); // Inicializa a cláusula WHERE
      List<String> whereArgs = []; // Inicializa a lista de argumentos para a cláusula WHERE

      // Adiciona filtro por nome sem acento
      if (filtroPessoa.name != null && filtroPessoa.name!.isNotEmpty) {
        String nameSemAcento = removeDiacritics(filtroPessoa.name!);
        addFilter(whereClause, whereArgs, 'name_sem_acento', '%$nameSemAcento%', operator: 'LIKE');
      }
      // Adiciona filtro por gênero
      addFilter(whereClause, whereArgs, 'gender', filtroPessoa.gender);
      // Adiciona filtro por idade mínima
      if (filtroPessoa.minAge != null) {
        addFilter(whereClause, whereArgs, 'age', filtroPessoa.minAge.toString(), operator: '>');
      }
      // Adiciona filtro por idade máxima
      if (filtroPessoa.maxAge != null) {
        addFilter(whereClause, whereArgs, 'age', filtroPessoa.maxAge.toString(), operator: '<');
      }

      // Consulta o banco de dados com os filtros aplicados
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: whereClause.isNotEmpty ? whereClause.toString() : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      print('Procurando dados no banco de dados... encontrado: $results');
      return results.map((map) => PersonModel.fromMap(map)).toList(); // Converte os resultados em uma lista de PersonModel
    } catch (e) {
      print('Erro ao buscar todos os usuários: $e');
      return [];
    }
  }

  // Método para fechar o banco de dados
  Future close() async {
    final db = await database;
    db.close(); // Fecha o banco de dados
  }
}
