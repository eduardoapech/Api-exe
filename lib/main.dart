import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';
import 'package:flutter/material.dart';
// Substitua 'your_api_class_file.dart' pelo nome do arquivo onde você definiu a classe API

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random User Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserDataPage(),
    );
  }
}

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<FilterModel> _users = [];
  List<FilterModel> _filteredUsers = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var users = await ApiServices().fetchUserData(20);
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 String? _selectedGender;

void _onSearchChanged() {
  String searchQuery = _searchController.text.toLowerCase();
  List<FilterModel> tempFilteredUsers = _users.where((user) =>
      user.name.toLowerCase().startsWith(searchQuery)).toList();

  if (_selectedGender != null && _selectedGender!.isNotEmpty) {
    tempFilteredUsers = tempFilteredUsers.where((user) =>
        user.gender.toLowerCase() == _selectedGender!.toLowerCase()).toList();
  }

  setState(() {
    _filteredUsers = tempFilteredUsers;
  });
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Random User Data'),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(130.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by name...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildGenderDropdown(),
            ),
          ],
        ),
      ),
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(_filteredUsers[index].avatarUrl),
                  radius: 25,
                ),
                title: Text(_filteredUsers[index].name),
                subtitle: Text('${_filteredUsers[index].email}, ${_filteredUsers[index].city}, ${_filteredUsers[index].state}, ${_filteredUsers[index].gender}, Age: ${_filteredUsers[index].age}'),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: _loadUserData,
      tooltip: 'Reload Data',
      child: Icon(Icons.refresh),
    ),
  );
}

  Widget _buildGenderDropdown() {
  return DropdownButton<String>(
    value: _selectedGender,
    hint: Text('Select Gender'),
    items: <String>['male', 'female'].map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList(),
    onChanged: (String? newValue) {
      setState(() {
        _selectedGender = newValue;
        _onSearchChanged(); // Atualiza a lista filtrada com a seleção de gênero
      });
    },
  );
}
}