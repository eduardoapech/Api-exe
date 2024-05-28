import 'package:api_dados/main.dart';
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
    return await openDatabase(path, version: 1, onCreate: _createDB); // Abre o banco de dados e chama _createDB se ele não existir
  }

  // Método para criar a tabela no banco de dados
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
    await db.execute(sql); // Executa a criação da tabela
  }

  // Método para inserir um usuário no banco de dados
  Future<int> createUser(PersonModel user) async {
    try {
      final db = await database;
      return await db.insert('users', user.toMap()); // Insere o usuário na tabela 'users'
    } catch (e) {
      print('Error inserting user: $e');
      return 0;
    }
  }

  // Método para obter um usuário pelo ID
  Future<PersonModel?> getUserId(String id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isNotEmpty) {
        return PersonModel.fromMap(results.first); // Retorna o usuário encontrado
      }
      return null; // Retorna null se o usuário não for encontrado
    } catch (e) {
      print('Error fetching user by id: $e');
      return null;
    }
  }

  // Método para atualizar um usuário no banco de dados
  Future<int> updateUser(PersonModel user) async {
    try {
      final db = await database;
      return await db.update(
        'users',
        user.toMap(), // Converte o usuário para um mapa
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
      return await db.delete('users', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting user: $e');
      return 0;
    }
  }

  // Método para obter todos os usuários aplicando filtros
  Future<List<PersonModel>> getAllUsers(FilterModel filtroPessoa) async {
    try {
      filtroPessoa;
      final db = await database;
      String whereClause = ''; // Inicializa a cláusula WHERE
      List<dynamic> whereArgs = []; // Inicializa a lista de argumentos para a cláusula WHERE

      // Adiciona filtro por nome se especificado
      if (filtroPessoa.name != null && filtroPessoa.name!.isNotEmpty) {
        whereClause += 'name LIKE ?';
        whereArgs.add('%${filtroPessoa.name}%');
      }
      // Adiciona filtro por gênero se especificado
      if (filtroPessoa.gender != null && filtroPessoa.gender!.isNotEmpty) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'gender = ?';
        whereArgs.add(filtroPessoa.gender);
      }
      // Adiciona filtro por idade mínima se especificado
      if (filtroPessoa.minAge != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'age > ?';
        whereArgs.add(filtroPessoa.minAge);
      }
      // Adiciona filtro por idade máxima se especificado
      if (filtroPessoa.maxAge != null) {
        if (whereClause.isNotEmpty) whereClause += ' AND ';
        whereClause += 'age < ?';
        whereArgs.add(filtroPessoa.maxAge);
      }

      // Consulta o banco de dados com os filtros aplicados
      final List<Map<String, dynamic>> results = await db.query(
        'users',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      );

      print('Procurando dados no banco de dados... encontrado: $results');
      return results.map((map) => PersonModel.fromMap(map)).toList(); // Converte os resultados em uma lista de PersonModel
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  // Método para fechar o banco de dados
  Future close() async {
    final db = await database;
    db.close(); // Fecha o banco de dados
  }
}