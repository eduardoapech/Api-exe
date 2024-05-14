import 'package:api_dados/views/user_detail_page_view.dart';
import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';
import 'package:api_dados/database_helper.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<PersonModel> _filteredUsers = [];
  List<PersonModel> _savedUsers = [];
  bool _isLoading = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    fetchRandomUsers().then((value) {
      setState(() {
        _filteredUsers = value;
        _isLoading = false;
      });
    });
  }

  Future<void> _loadSavedUsers() async {
    final dbHelper = DatabaseHelper.instance;
    final users = await dbHelper.getAllUsers();
    setState(() {
      _savedUsers = users;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _loadSavedUsers();
      }
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

  Widget _showUserData() {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : _filteredUsers.isEmpty
            ? Center(child: Text('No users found'))
            : ListView.builder(
                itemCount: _filteredUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(_filteredUsers[index].avatarUrl),
                      radius: 25,
                    ),
                    title: Text(_filteredUsers[index].name),
                    subtitle: Text('${_filteredUsers[index].email}, ${_filteredUsers[index].city},'
                        '${_filteredUsers[index].state}, ${_filteredUsers[index].gender},'
                        ' Age: ${_filteredUsers[index].age}'),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserDetailPage(user: _filteredUsers[index], showSaveButton: true),
                        ),
                      );
                      if (result == true) {
                        _loadUserData(); // Refresh user data after returning from detail page
                        _onItemTapped(1); // Switch to saved data tab
                      }
                    },
                  );
                },
              );
  }

  Widget _showSavedData() {
    return _savedUsers.isEmpty
        ? Center(child: Text('No saved users'))
        : ListView.builder(
            itemCount: _savedUsers.length,
            itemBuilder: (context, index) {
              final user = _savedUsers[index];
              return Dismissible(
                key: Key(user.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) => showDeleteConfirmationDialog(context, user.id, user.name),
                onDismissed: (direction) async {
                  await _deleteUser(user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} foi apagado'),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
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
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(user: user, showSaveButton: false),
                      ),
                    )
                        .then((value) {
                      if (value == true) {
                        _loadSavedUsers(); // Refresh saved users after returning from detail page
                      }
                    });
                  },
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random User Data'),
      ),
      body: _selectedIndex == 0 ? _showUserData() : _showSavedData(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Show Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save Data',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _loadUserData,
              tooltip: 'Reload Users',
              child: Icon(Icons.refresh),
            )
          : null,
    );
  }
}
