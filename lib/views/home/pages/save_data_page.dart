import 'dart:async';
import 'package:flutter/material.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/models/filter_model.dart';
import 'package:api_dados/services/database_helper.dart';
import 'package:api_dados/views/user-detail/user_detail_view.dart';
import 'package:remove_diacritic/remove_diacritic.dart';


class SavedDataPage extends StatefulWidget {
  const SavedDataPage({Key? key}) : super(key: key);

  @override
  _SavedDataPageState createState() => _SavedDataPageState();
}

class _SavedDataPageState extends State<SavedDataPage> {
  List<PersonModel> _filteredUsers = [];

  List<PersonModel> _savedUsers = [];
  bool _isLoading = false;
  Timer? _debounceTimer;


  final TextEditingController _filterController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();

  final ValueNotifier<bool> _showClearIconforfilter = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showClearIconForMinAge = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showClearIconForMaxAge = ValueNotifier<bool>(false);

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
    _loadSavedUsers();

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
    _filterController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _showClearIconforfilter.dispose();
    _showClearIconForMinAge.dispose();
    _showClearIconForMaxAge.dispose();
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

    //Todo Buscar usuários do banco de dados aplicando os filtros

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
          child: Column(
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
                    _loadSavedUsers();
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Gênero',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: _showClearIconforfilter,
                builder: (context, showClearIcon, _) {
                  return TextField(
                    controller: _filterController,
                    onChanged: _handleFilterChange,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2.0),
                      ),
                      suffixIcon: showClearIcon
                          ? IconButton(
                              onPressed: _clearFilter,
                              icon: Icon(Icons.clear),
                            )
                          : null,
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showClearIconForMinAge,
                      builder: (context, showClearIcon, _) {
                        return TextField(
                          controller: _minAgeController,
                          onChanged: _handleFilterChange,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Idade mínima',
                            labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            suffixIcon: showClearIcon
                                ? IconButton(
                                    onPressed: _clearFilter,
                                    icon: Icon(Icons.clear),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _showClearIconForMaxAge,
                      builder: (context, showClearIcon, _) {
                        return TextField(
                          controller: _maxAgeController,
                          onChanged: _handleFilterChange,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Idade máxima',
                            labelStyle: TextStyle(color: Colors.black, fontSize: 16),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green, width: 2.0),
                            ),
                            suffixIcon: showClearIcon
                                ? IconButton(
                                    onPressed: _clearFilter,
                                    icon: Icon(Icons.clear),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _savedUsers.isEmpty
                  ? Center(
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
                            onDismissed: (direction) async {
                              final shouldDelete = await showDeleteConfirmationDialog(context, user.id, user.name);
                              if (shouldDelete == true) {
                                await _deleteUser(user.id);
                              } else {
                                _restoreUser(user, index);
                              }
                            },
                            background: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: AlignmentDirectional.centerEnd,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
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
