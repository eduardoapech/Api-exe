import 'package:flutter/material.dart';
import 'package:api_dados/models/filter_model.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/services/database_helper.dart';
import 'package:api_dados/filter/services.dart';
import 'package:api_dados/views/user_detail_page_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// Declaração da classe UserDataPage como um StatefulWidget
class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

// Estado associado ao UserDataPage
class _UserDataPageState extends State<UserDataPage> {
  // Listas para armazenar usuários filtrados e salvos
  List<PersonModel> _filteredUsers = [];
  List<PersonModel> _savedUsers = [];

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  // Índice da aba selecionada no BottomNavigationBar
  int _selectedIndex = 0;

  // Controladores de texto para os campos de filtro
  final _filterController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();

  // Gênero selecionado para filtro
  String _selectedGender = '';

  // Instância do modelo de filtro
  final filtroPessoa = FilterModel();

  @override
  void initState() {
    super.initState();
    // Carregar dados de usuários aleatórios ao inicializar o estado
    _loadUserData();
  }

  @override
  void dispose() {
    // Liberar os controladores de texto ao destruir o estado
    _filterController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  // Método para carregar usuários aleatórios
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true; // Definir estado de carregamento como verdadeiro
    });
    final users = await fetchRandomUsers(); // Buscar usuários aleatórios
    setState(() {
      _filteredUsers = users; // Atualizar a lista de usuários filtrados
      _isLoading = false; // Definir estado de carregamento como falso
    });
  }

  // Método para carregar usuários salvos aplicando filtros
  Future<void> _loadSavedUsers() async {
    setState(() {
      _isLoading = true; // Definir estado de carregamento como verdadeiro
    });

    // Configurar filtros com base nos valores dos controladores de texto e no gênero selecionado
    filtroPessoa.name = _filterController.text;
    
    filtroPessoa.minAge = int.tryParse(_minAgeController.text);
    filtroPessoa.maxAge = int.tryParse(_maxAgeController.text);

    //Se o gênero selecionado não for 'todos', aplicar filtro gênero
    if (_selectedGender != 'todos') {
    filtroPessoa.gender = _selectedGender;
    } else { 
      filtroPessoa.gender = null; //Não aplicar filtro por gênero
    }

    //Todo Buscar usuários do banco de dados aplicando os filtros
    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers(filtroPessoa);

    // Filtrar os usuários para que apenas os que começam com a primeira letra digitada sejam exibidos
    if (_filterController.text.isNotEmpty) {
      final firstLetter = _filterController.text[0].toUpperCase();
      _savedUsers = users.where((user) => user.name.toUpperCase().startsWith(firstLetter)).toList();
    } else {
      _savedUsers = users; // Atualizar a lista de usuários salvos
    }

    setState(() {
      _isLoading = false; // Definir estado de carregamento como falso
    });
  }

  // Método para alternar entre as abas no BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualizar o índice da aba selecionada
      if (index == 1) {
        _loadSavedUsers(); // Carregar usuários salvos ao selecionar a aba correspondente
      }
    });
  }

  // Método para deletar um usuário do banco de dados
  Future<void> _deleteUser(String id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteUser(id); // Deletar usuário pelo ID
    await _loadSavedUsers(); // Recarregar a lista de usuários salvos
  }

  // Diálogo de confirmação para deletar um usuário
  Future<bool?> showDeleteConfirmationDialog(BuildContext context, String userId, String userName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Impedir fechamento ao clicar fora do diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja excluir $userName?'), // Mensagem de confirmação
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Fechar diálogo sem deletar
              },
            ),
            TextButton(
              child: const Text('Apagar'),
              onPressed: () {
                Navigator.of(context).pop(true); // Fechar diálogo e confirmar exclusão
              },
            ),
          ],
        );
      },
    );
  }

  // Método para salvar um usuário no banco de dados
  Future<void> _saveUser(PersonModel user) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createUser(user); // Salvar usuário no banco de dados
    setState(() {
      _filteredUsers.removeWhere((u) => u.id == user.id); // Remover usuário da lista de filtrados
      _savedUsers.add(user); // Adicionar usuário à lista de salvos
    });
  }

  // Constrói os campos de filtro na aba de dados salvos
  Widget _buildFilterFields() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Campo de texto para pesquisar pelo nome
          TextField(
            controller: _filterController,
            decoration: const InputDecoration(
              labelText: 'Pesquisar nome',
              labelStyle: TextStyle(color: Colors.black, fontSize: 16),
              border: OutlineInputBorder(),
            ),
             style: const TextStyle(color: Colors.black, fontSize: 16),
            onChanged: (value) {
              _loadSavedUsers();
            },
          ),
          const SizedBox(height: 8.0),
          // Dropdown para selecionar o gênero
          DropdownButtonFormField<String>(
            value: _selectedGender.isNotEmpty ? _selectedGender : null,
            items: const [
              DropdownMenuItem(
                value: 'todos',
                child: Text('Todos', ),
              ),
              DropdownMenuItem(
                value: 'male',
                child: Text('Male'),
              ),
              DropdownMenuItem(
                value: 'female',
                child: Text('Female'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedGender = value ?? '';
              });
              _loadSavedUsers();
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Gênero',
              labelStyle: TextStyle(color: Colors.black, fontSize: 16)
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 8.0),
          // Campos de texto para idade mínima e máxima
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Idade mínima',
                     labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                   style: const TextStyle(color: Colors.black, fontSize: 16),
                  keyboardType: TextInputType.number,
                  onChanged: (value) { 
                    _loadSavedUsers();
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: _maxAgeController,
                  decoration: const InputDecoration(
                    labelText: 'Idade máxima',
                     labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                   style: const TextStyle(color: Colors.black, fontSize: 16),
                  keyboardType: TextInputType.number,
                   onChanged: (value) { 
                    _loadSavedUsers();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Constrói a lista de usuários aleatórios ou exibe um indicador de progresso
  Widget _showUserData() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Nenhum usuário encontrado'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
              radius: 25,
            ),
            title: Text(user.name),
            subtitle: Text('${user.email}, ${user.city}, ${user.state}, ${user.gender}, Age: ${user.age}'),
            onTap: () async {
              final updatedUser = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(user: user, showSaveButton: true),
                ),
              );
              if (updatedUser != null && updatedUser is PersonModel) {
                await _saveUser(updatedUser); // Salvar usuário ao retornar da página de detalhes
              }
            },
          );
        },
      );
    }
  }

  // Constrói a lista de usuários salvos ou exibe um indicador de progresso
  Widget _showSavedData() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_savedUsers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nenhum usuário salvo encontrado'),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _savedUsers.length,
        itemBuilder: (context, index) {
          final user = _savedUsers[index];
          return Dismissible(
            key: Key(user.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) => showDeleteConfirmationDialog(context, user.id, user.name),
            onDismissed: (direction) async {
              await _deleteUser(user.id); // Deletar usuário ao deslizar a lista
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} foi excluído'),
                ),
              );
            },
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: AlignmentDirectional.centerEnd,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.avatarUrl),
                radius: 25,
              ),
              title: Text(user.name),
              subtitle: Text('${user.email}, ${user.city}, ${user.state}, ${user.gender}, Age: ${user.age}'),
              onTap: () async {
                final updatedUser = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserDetailPage(user: user, showSaveButton: true),
                  ),
                );
                if (updatedUser != null && updatedUser is PersonModel) {
                  setState(() {
                    _savedUsers[index] = updatedUser; // Atualizar usuário ao retornar da página de detalhes
                  });
                }
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lista de páginas para o BottomNavigationBar
    List<Widget> pages = <Widget>[
      _showUserData(),
      Column(
        children: [
          _buildFilterFields(), // Campos de filtro
          Expanded(child: _showSavedData()), // Lista de usuários salvos
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Data'), // Título da AppBar
      ),
      body: pages.elementAt(_selectedIndex), // Exibir a página correspondente à aba selecionada
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Show Data', // Rótulo da primeira aba
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Saved Data', // Rótulo da segunda aba
          ),
        ],
        currentIndex: _selectedIndex, // Índice da aba atualmente selecionada
        onTap: _onItemTapped, // Método para alternar entre as abas
        backgroundColor: Colors.white, //cor de fundo do BottomNavigationBar
        selectedItemColor: Colors.orange, //cor do item selecionado
        unselectedItemColor: Colors.grey, //cor dos itens não selecionados
        selectedIconTheme: const IconThemeData(color: Colors.orange), //cor do item selecionado
        unselectedIconTheme: const IconThemeData(color: Colors.grey), // cor dos itens não selecionados
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _loadUserData,
              child: const Icon(Icons.refresh), // Botão flutuante para recarregar usuários aleatórios
            )
          : null,
    );
  }
}
