import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';
import 'package:api_dados/services/database_helper.dart';
import 'package:api_dados/views/user_detail_page_view.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<PersonModel> _filteredUsers = [];
  List<PersonModel> _savedUsers = [];
  List<PersonModel> _allUsers = [];
  bool _isLoading = false;
  int _selectedIndex = 0;
  TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    final users = await fetchRandomUsers();
    setState(() {
      _allUsers = users;
      _filteredUsers = users;
      _isLoading = false;
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
      barrierDismissible: false,
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
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Apagar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _filterUsers(String query) {
    final filtered = _allUsers.where((user) {
      final lowerCaseQuery = query.toLowerCase();
      final nameMatch = user.name.toLowerCase().contains(lowerCaseQuery);
      final emailMatch = user.email.toLowerCase().contains(lowerCaseQuery);
      return nameMatch || emailMatch;
    }).toList();
    setState(() {
      _filteredUsers = filtered;
    });
  }

  Widget _buildFilterTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _filterController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(15.0),
          hintText: 'Pesquisar nome ou email',
        ),
        onChanged: _filterUsers,
      ),
    );
  }

  Widget _showUserData() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Nenhum usuário encontrado'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserData,
              child: Text('Tentar novamente'),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
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
              final updatedUser = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserDetailPage(user: _filteredUsers[index], showSaveButton: true),
                ),
              );
              if (updatedUser != null && updatedUser is PersonModel) {
                setState(() {
                  _filteredUsers[index] = updatedUser;
                  int savedUserIndex = _savedUsers.indexWhere((u) => u.id == updatedUser.id);
                  if (savedUserIndex != -1) {
                    _savedUsers[savedUserIndex] = updatedUser;
                  } else {
                    _savedUsers.add(updatedUser);
                  }
                });
              }
            },
          );
        },
      );
    }
  }

  Widget _showSavedData() {
    return _savedUsers.isEmpty
        ? Center(child: Text('Nenhum usuário salvo'))
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
                      content: Text('${user.name} foi excluído'),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  alignment: AlignmentDirectional.centerEnd,
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
                  onTap: () async {
                    final updatedUser = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(user: user, showSaveButton: true),
                      ),
                    );
                    if (updatedUser != null && updatedUser is PersonModel) {
                      setState(() {
                        _savedUsers[index] = updatedUser;
                        int filteredUserIndex = _filteredUsers.indexWhere((u) => u.id == updatedUser.id);
                        if (filteredUserIndex != -1) {
                          _filteredUsers[filteredUserIndex] = updatedUser;
                        }
                      });
                    }
                  },
                ),
              );
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = <Widget>[
      Column(
        children: [
          _buildFilterTextField(),
          Expanded(child: _showUserData()),
        ],
      ),
      _showSavedData(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('User Data'),
      ),
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Show Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save Data',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _loadUserData,
              tooltip: 'Recarregar Usuários',
              child: Icon(Icons.refresh),
            )
          : null,
    );
  }
}
