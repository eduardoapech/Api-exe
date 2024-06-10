import 'dart:async';
import 'package:flutter/material.dart';
import 'package:api_dados/get-It/get_it.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/models/filter_model.dart';
import 'package:api_dados/services/database_helper.dart';
import 'package:api_dados/views/user-detail/user_detail_view.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:api_dados/views/home/home_screen_state.dart';

class SavedDataPage extends StatefulWidget {
  const SavedDataPage({Key? key, required this.onView}) : super(key: key);

  final VoidCallback onView;

  @override
  _SavedDataPageState createState() => _SavedDataPageState();
}

class _SavedDataPageState extends State<SavedDataPage> {
  final HomeScreenState homeScreenState = HomeScreenState();
  List<PersonModel> _filteredUsers = [];
  List<PersonModel> _savedUsers = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  final TextEditingController _filterController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();

  final HomeScreenState _homeScreenState = HomeScreenState();

  final List<String> _genderOptions = ['todos', 'male', 'female'];
  String _selectedGender = 'todos';

  final filtroPessoa = getIt<FilterModel>(instanceName: 'filterInstance');

  Future<void> _saveUser(PersonModel user) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createUser(user);

    setState(() {
      _filteredUsers.removeWhere((u) => u.id == user.id); // Remover usuário da lista de filtrados
      _savedUsers.add(user); // Adicionar usuário à lista de salvos
    });
  }

  @override
  void initState() {
    super.initState();
    widget.onView(); // Chamando o callback quando a página é inicializada
    _loadSavedUsers();

    _filterController.addListener(() {
      _homeScreenState.setFilterText(_filterController.text.isNotEmpty);
    });
    _minAgeController.addListener(() {
      _homeScreenState.setMinAgeText(_minAgeController.text.isNotEmpty);
    });
    _maxAgeController.addListener(() {
      _homeScreenState.setMaxAgeText(_maxAgeController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _startDebounceTimer(void Function() callback) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      callback();
    });
  }

  void _handleFilterChange(String newValue) {
    _startDebounceTimer(() {
      _loadSavedUsers();
    });
  }

  Future<void> _loadSavedUsers() async {
    setState(() {
      _isLoading = true;
    });

    filtroPessoa.name = _filterController.text;
    filtroPessoa.minAge = int.tryParse(_minAgeController.text);
    filtroPessoa.maxAge = int.tryParse(_maxAgeController.text);

    if (_selectedGender != 'todos') {
      filtroPessoa.gender = _selectedGender;
    } else {
      filtroPessoa.gender = null;
    }

    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers(filtroPessoa);

    if (_filterController.text.isNotEmpty) {
      final searchText = removeDiacritics(_filterController.text.toUpperCase());
      _savedUsers = users.where((user) {
        final nameSemAcento = removeDiacritics(user.name).toUpperCase();
        return nameSemAcento.startsWith(searchText) || nameSemAcento.contains(searchText);
      }).toList();
    } else {
      _savedUsers = users;
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteUser(String id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.deleteUser(id);
    await _loadSavedUsers();
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context, String userId, String userName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // O usuário deve tocar em um botão para fechar o diálogo
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Tem certeza que deseja excluir $userName?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false para indicar que a exclusão foi cancelada
              },
            ),
            TextButton(
              child: Text('Apagar'),
              onPressed: () async {
                Navigator.of(context).pop(true); // Retorna true para indicar que a exclusão foi confirmada
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUserDetails(PersonModel user) async {
    final updatedUser = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailView(user: user, showSaveButton: true),
      ),
    );

    if (updatedUser != null && updatedUser is PersonModel) {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateUser(updatedUser);
      await _loadSavedUsers();
      await _saveUser(updatedUser);
    }
  }

  void _clearFilter() {
    _filterController.clear();
    _minAgeController.clear();
    _maxAgeController.clear();
    setState(() {
      _selectedGender = 'todos';
      _loadSavedUsers();
    });
  }

  void _restoreUser(PersonModel user, int index) {
    setState(() {
      _savedUsers.insert(index, user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Observer(builder: (_) {
            return TextField(
              controller: _filterController,
              onChanged: (text) {
                _startDebounceTimer(() {
                  _handleFilterChange(text);
                });
              },
              decoration: InputDecoration(
                labelText: 'Pesquisar Nome',
                labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                suffixIcon: _homeScreenState.showClearIconForFilter
                    ? IconButton(
                        onPressed: _clearFilter,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
            );
          }),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedGender,
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender == 'todos' ? 'Todos' : gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                    _startDebounceTimer(() {
                      _loadSavedUsers();
                    });
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  labelText: 'Gênero',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                ),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // Alinhar os campos
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Observer(builder: (_) {
                          return TextField(
                            controller: _minAgeController,
                            onChanged: (text) {
                              _startDebounceTimer(() {
                                _handleFilterChange(text);
                                _homeScreenState.setMinAgeText(text.isNotEmpty);
                              });
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Idade mín.',
                              labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                              suffixIcon: _homeScreenState.showClearIconForMinAge
                                  ? IconButton(
                                      onPressed: _clearFilter,
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Observer(builder: (_) {
                          return TextField(
                            controller: _maxAgeController,
                            onChanged: (text) {
                              _startDebounceTimer(() {
                                _handleFilterChange(text);
                                _homeScreenState.setMaxAgeText(text.isNotEmpty);
                              });
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Idade máx.',
                              labelStyle: const TextStyle(color: Colors.black, fontSize: 16),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 2),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red, width: 2),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green, width: 2),
                              ),
                              suffixIcon: _homeScreenState.showClearIconForMaxAge
                                  ? IconButton(
                                      onPressed: _clearFilter,
                                      icon: const Icon(Icons.clear),
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _savedUsers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Nenhum usuário encontrado'),
                          SizedBox(height: 16),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _savedUsers.length,
                      itemBuilder: (context, index) {
                        final user = _savedUsers[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Dismissible(
                            key: Key(user.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              final shouldDelete = await showDeleteConfirmationDialog(context, user.id, user.name);
                              if (shouldDelete == true) {
                                await _deleteUser(user.id);
                                if (context != null && ScaffoldMessenger.of(context).mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Usuário ${user.name} deletado com sucesso!'),
                                      duration: Duration(milliseconds: 500),
                                    ),
                                  );
                                }
                                return true;
                              } else {
                                return false;
                              }
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
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(color: Colors.black, width: 2.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(user.avatarUrl),
                                      radius: 25,
                                    ),
                                    title: Text(
                                      user.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(', ${user.email}, ${user.city}, ${user.state}, ${user.gender}, Age: ${user.age}'),
                                      ],
                                    ),
                                    onTap: () async {
                                      final updatedUser = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => UserDetailView(user: user, showSaveButton: true),
                                        ),
                                      );
                                      if (updatedUser != null && updatedUser is PersonModel) {
                                        setState(() {
                                          _savedUsers[index] = updatedUser;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
