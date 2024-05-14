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
                          builder: (context) => UserDetailPage(user: _filteredUsers[index]),
                        ),
                      );
                      if (result == true) {
                        _loadSavedUsers(); // Refresh saved users after returning from detail page
                        _onItemTapped(1); // Switch to saved data tab
                      }
                    },
                  );
                },
              );
  }

  Widget _showSavedData() {
    return _savedUsers.isEmpty
        ? Center(child: Text('Vazio'))
        : ListView.builder(
            itemCount: _savedUsers.length,
            itemBuilder: (context, index) {
              final user = _savedUsers[index];
              return Dismissible(
                key: Key(user.id),
                direction: DismissDirection.horizontal, // Permite deslizar em ambas as direções

                onDismissed: (direction) async {
                  await _deleteUser(user.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${user.name} foi Apagado'),
                    ),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                resizeDuration: const Duration(milliseconds: 300),
                movementDuration: const Duration(milliseconds: 200),
                dismissThresholds: const <DismissDirection, double>{},
                crossAxisEndOffset: 0.5,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatarUrl),
                    radius: 25,
                  ),
                  title: Text(user.name),
                  subtitle: Text('${user.email}, ${user.city}, ${user.state},'
                      ' ${user.gender}, Age: ${user.age}'),
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(user: user),
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
