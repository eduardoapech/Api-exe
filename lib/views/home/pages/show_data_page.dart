import 'package:api_dados/get-It/get_it.dart';
import 'package:api_dados/models/filter_model.dart';
import 'package:flutter/material.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/services/database_helper.dart';
import 'package:api_dados/filter/services.dart';
import 'package:api_dados/views/user-detail/user_detail_view.dart';

class ShowDataPage extends StatefulWidget {
  final Function onUserSaved;
  final Function(bool) onUserSavedStatusChanged;

  const ShowDataPage({Key? key, required this.onUserSaved, required void Function() onUserDeleted, required this.onUserSavedStatusChanged}) : super(key: key);

  @override
  _ShowDataPageState createState() => _ShowDataPageState();
}

class _ShowDataPageState extends State<ShowDataPage> {
  List<PersonModel> _filteredUsers = [];
  List<PersonModel> _savedUsers = [];
  bool _userSaved = false;
  bool _isLoading = false;
  final filtroShowdata = getIt<FilterModel>(instanceName: 'filterInstance');
  final List<String> _genderOptions = ['todos', 'male', 'female'];
  String _selectedGender = 'todos';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final users = await fetchRandomUsers(gender: _selectedGender);

    setState(() {
      _filteredUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _saveUser(PersonModel user) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createUser(user);

    setState(() {
      _filteredUsers.removeWhere((u) => u.id == user.id); // Remover usuário da lista de filtrados
      _savedUsers.add(user); // Adicionar usuário à lista de salvos
      _userSaved = true; // Marcando que o usuário foi salvo
    });

    widget.onUserSaved();
    widget.onUserSavedStatusChanged(_userSaved); // Notificando a página pai
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
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
                filtroShowdata.gender = _selectedGender == 'todos' ? null : _selectedGender;
                _loadUserData();
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
        ),
        Expanded(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _filteredUsers.isEmpty
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
                              title: Text(
                                user.name,
                                style: TextStyle( 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                                    builder: (context) => UserDetailView(user: user, showSaveButton: true),
                                  ),
                                );
                                if (updatedUser != null && updatedUser is PersonModel) {
                                  await _saveUser(updatedUser);
                                }
                              },
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
