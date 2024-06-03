import 'dart:async';

import 'package:flutter/material.dart';
import 'package:api_dados/models/filter_model.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/services/database_helper.dart';
import 'package:api_dados/filter/services.dart';
import 'package:api_dados/views/user_detail_page_view.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

import 'package:badges/badges.dart' as badges;

// Declaração da classe UserDataPage como um StatefulWidget
class UserDataPage extends StatefulWidget {
  const UserDataPage({super.key});

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

// like() {
//   print(removeDiacritics('ÀÁÂÃÄÅǺĀĂĄǍΑΆẢẠẦẪẨẬẰẮẴẲẶА')); // prints: 'AAAAAAAAAAAΑAAAAAAAAAAAAА'
//   print(removeDiacritics('àáâãåǻāăąǎαάảạầấẫẩậằắẵẳặа')); // prints: 'aaaaaaaaaaaaaaaaaaaaaaaaа'
//   print(removeDiacritics('ÈÉÊËĒĔĖĘĚΕΈẼẺẸỀẾỄỂỆЕ')); // prints: 'EEEEEEEEEΕEEEEEEEEEЕ'
//   print(removeDiacritics('èéêëēĕėęěẽẻẹềếễểệе')); // prints: 'eeeeeeeeeeeeeeeeeе'
//   print(removeDiacritics('ÌÍÎÏĨĪĬǏĮİΊΙΪỈỊ')); // prints: 'IIIIIIIIIIIΙIII'
//   print(removeDiacritics('ìíîïĩīĭǐįıỉịї')); // prints: 'iiiiiiiiiiiii'
//   print(removeDiacritics('ÒÓÔÕŌŎǑŐƠØǾΟΌỎỌỒỐỖỔỘỜỚỠỞỢО')); // prints: 'OOOOOOOOOOOΟOOOOOOOOOOOOOО'
//   print(removeDiacritics('òóôõōŏǒőơøǿοόỏọồốỗổộờớỡởợо')); // prints: 'oooooooooooοoooooooooooooо'
//   print(removeDiacritics('ÙÚÛŨŪŬŮŰŲƯǓǕǗǙǛŨỦỤỪỨỮỬỰ')); // prints: 'UUUUUUUUUUUUUUUUUUUUUUU'
//   print(removeDiacritics('ùúûũūŭůűųưǔǖǘǚǜủụừứữửự')); // prints: 'uuuuuuuuuuuuuuuuuuuuuu'
//   print(removeDiacritics('ÝŸŶΥΎΫỲỸỶỴ')); // prints: 'YYYΥYYYYYY'
//   print(removeDiacritics('ýÿŷỳỹỷỵ')); // prints: 'yyyyyyy'
//   print(removeDiacritics('ĹĻĽĿŁ')); // prints: 'LLLLL'
//   print(removeDiacritics('ĺļľŀł')); // prints: 'lllll'
//   print(removeDiacritics('ÇĆĈĊČ')); // prints: 'CCCCC'
//   print(removeDiacritics('çćĉċč')); // prints: 'ccccc'
// }

// Estado associado ao UserDataPage
class _UserDataPageState extends State<UserDataPage> {
  // Listas para armazenar usuários filtrados e salvos
  List<PersonModel> _filteredUsers = [];
  List<PersonModel> _savedUsers = [];


  

  PersonModel? _selectedUser;

  Timer? _debounceTimer;

  // Variável para controlar o estado de carregamento
  bool _isLoading = false;

  // Índice da aba selecionada no BottomNavigationBar
  int _selectedIndex = 0;

  int _savedDataCount = 0;

  // Controladores de texto para os campos de filtro
  final TextEditingController _filterController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();

  final ValueNotifier<bool> _showClearIconforfilter = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showClearIconForMinAge = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showClearIconForMaxAge = ValueNotifier<bool>(false);

  // bool _showClearIcon = false;

  // Gênero selecionado para filtro
  String _selectedGender = '';

  // Instância do modelo de filtro
  final filtroPessoa = FilterModel();

  // final EasyDebounce _debouncer = Debouncer(const Duration(milliseconds: 500));
  @override
  void initState() {
    super.initState();
    _filterController.addListener(() {
      _showClearIconforfilter.value = _filterController.text.isNotEmpty;
    });
    _minAgeController.addListener(() {
      _showClearIconForMinAge.value = _minAgeController.text.isNotEmpty;
    });
    _maxAgeController.addListener(() {
      _showClearIconForMaxAge.value = _maxAgeController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Liberar os controladores de texto ao destruir o estado
    _filterController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _showClearIconforfilter.dispose();
    _showClearIconForMinAge.dispose();
    _showClearIconForMaxAge.dispose();
    super.dispose();
  }

  void _startDebounceTimer(void Function() callback) {
    // Cancela o timer anterior, se existir
    _debounceTimer?.cancel();

    // Inicia um novo timer com um atraso de 500 milissegundos
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      callback();
    });
  }

  void _handleFilterChange(String newValue) {
    // Aqui pode fazer o que precisa com o valor do campo de filtro
    print('Valor do filtro: $newValue');

    // Chamar a função para carregar os usuários com base no novo filtro
    _startDebounceTimer(() {
      _loadSavedUsers();
    });
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
      final searchText = removeDiacritics(_filterController.text.toUpperCase());
      _savedUsers = users
          .where((user) =>
              removeDiacritics(user.name.toUpperCase()).startsWith(searchText) ||
              removeDiacritics(user.name.toUpperCase()).contains(
                searchText,
              ))
          .toList();
    } else {
      _savedUsers = users; // Atualizar a lista de usuários salvos
    }

    setState(() {
      _isLoading = false; // Definir estado de carregamento como falso
      _savedDataCount = 0;
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

  void _incrementSavedDataCount() {
    setState(() {
      _savedDataCount++;
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

  Future<void> _saveUser(PersonModel user) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createUser(user); // Salvar usuário no banco de dados

    setState(() {
      _filteredUsers.removeWhere((u) => u.id == user.id); // Remover usuário da lista de filtrados
      _savedUsers.add(user); // Adicionar usuário à lista de salvos
      _savedDataCount++; // Incrementar o contador de usuários salvos
    });
  }

  // Constrói os campos de filtro na aba de dados salvos
  Widget _buildFilterFields() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: _showClearIconforfilter,
            builder: (context, value, child) {
              // Campo de texto para pesquisar pelo nome
              return TextField(
                controller: _filterController,
                decoration: InputDecoration(
                  labelText: 'Pesquisar nome',
                  labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                  border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
                  focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.0)),
                  suffixIcon: value
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _filterController.clear();

                            _loadSavedUsers();
                          },
                        )
                      : null,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: _handleFilterChange,
              );
            },
          ),
          const SizedBox(height: 8.0),
          // Dropdown para selecionar o gênero
          DropdownButtonFormField<String>(
            value: _selectedGender.isNotEmpty ? _selectedGender : null,
            items: const [
              DropdownMenuItem(
                value: 'todos',
                child: Text('Todos'),
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
            onChanged: (value) async {
              _startDebounceTimer(() {
                _loadSavedUsers();
              });
              setState(() {
                _selectedGender = value ?? '';
              });
            },
            decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.0)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                  color: Colors.black,
                  width: 2.0,
                )),
                labelText: 'Gênero',
                labelStyle: TextStyle(color: Colors.black, fontSize: 16)),
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          const SizedBox(height: 8.0),
          // Campos de texto para idade mínima e máxima
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showClearIconForMinAge,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _minAgeController,
                      decoration: InputDecoration(
                          labelText: 'Idade mínima',
                          labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                          border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0)),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.0)),
                          suffixIcon: value
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _minAgeController.clear();
                                    _loadSavedUsers();
                                  },
                                )
                              : null),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      onChanged: (_) async {
                        _startDebounceTimer(() {
                          _loadSavedUsers();
                        });
                      },
                      keyboardType: TextInputType.number,
                    );
                  },
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _showClearIconForMaxAge,
                  builder: (context, value, child) {
                    return TextField(
                      controller: _maxAgeController,
                      decoration: InputDecoration(
                        labelText: 'Idade máxima',
                        labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 6.0)),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2.0)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2.0)),
                        suffixIcon: value
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _maxAgeController.clear();
                                  _loadSavedUsers();
                                },
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      onChanged: (_) async {
                        _startDebounceTimer(() {
                          _loadSavedUsers();
                        });
                      },
                      keyboardType: TextInputType.number,
                    );
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nenhum usuário encontrado'),
            SizedBox(height: 16),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 2.0),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                  radius: 25,
                ),
                title: Text(user.name),
                subtitle: Text('${user.email}, ${user.city}, ${user.state}, ${user.gender}, Age: ${user.age}'),
                trailing: IconButton(
                  icon: const Icon(Icons.save, color: Colors.green),
                  onPressed: () async {
                    await _saveUser(user);
                  },
                ),
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
              ),
            ),
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
        child: Text('Nenhum usuário salvo encontrado'),
      );
    } else {
      return ListView.builder(
        itemCount: _savedUsers.length,
        itemBuilder: (context, index) {
          final user = _savedUsers[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: const BorderSide(color: Colors.black, width: 2.0),
              ),
              child: Dismissible(
                key: Key(user.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => showDeleteConfirmationDialog(context, user.id, user.name),
                onDismissed: (direction) async {
                  await Future.delayed(Duration(milliseconds: 100));
                  await _deleteUser(user.id);
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
                  title: Text(removeDiacritics(user.name)),
                  subtitle: Text('${user.email}, ${user.city}, ${user.state}, ${user.gender}, Age: ${user.age}'),
                  onTap: () async {
                    setState(() {
                      _selectedUser = user; // Armazena o usuário selecionado
                    });
                    final updatedUser = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(user: user, showSaveButton: true),
                      ),
                    );
                    if (updatedUser != null && updatedUser is PersonModel) {
                      setState(() {
                        _savedUsers[index] = updatedUser;
                        _selectedUser = updatedUser;
                      });
                    }
                  },
                ),
              ),
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
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Show Data', // Rótulo da primeira aba
          ),
          BottomNavigationBarItem(
            icon: _savedDataCount > 0
                ? badges.Badge(
                    badgeContent: Text('$_savedDataCount',
                        style: const TextStyle(
                          color: Colors.white,
                        )),
                    child: const Icon(Icons.save),
                  )
                : const Icon(Icons.save),
            label: 'Saved Data', // Rótulo da segunda aba
          ),
        ],
        currentIndex: _selectedIndex, // Índice da aba atualmente selecionada
        onTap: _onItemTapped, // Método para alternar entre as abas
        backgroundColor: Colors.white, //cor de fundo do BottomNavigationBar
        selectedItemColor: Colors.red, //cor do item selecionado
        unselectedItemColor: Colors.grey, //cor dos itens não selecionados
        selectedIconTheme: const IconThemeData(color: Colors.red), //cor do item selecionado
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
