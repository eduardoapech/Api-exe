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

TextEditingController _ageController = TextEditingController();
TextEditingController _minAgeController = TextEditingController();
TextEditingController _maxAgeController = TextEditingController();
TextEditingController _searchController = TextEditingController();


class _UserDataPageState extends State<UserDataPage> {
  List<FilterModel> _users = [];
  List<FilterModel> _filteredUsers = [];
  bool _isLoading = false;
  

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
  List<FilterModel> tempFilteredUsers = _users;
  
  // Filtro por nome
  if (_searchController.text.isNotEmpty) {
    String searchQuery = _searchController.text.toLowerCase();
    tempFilteredUsers = tempFilteredUsers.where((user) =>
      user.name.toLowerCase().startsWith(searchQuery)).toList();
  }

  // Filtro por gênero
  if (_selectedGender != null && _selectedGender!.isNotEmpty && _selectedGender != 'all') {
    tempFilteredUsers = tempFilteredUsers.where((user) =>
      user.gender.toLowerCase() == _selectedGender!.toLowerCase()).toList();
  }

  // Filtro por intervalo de idade
  int? minAge = int.tryParse(_minAgeController.text);
  int? maxAge = int.tryParse(_maxAgeController.text);
  if (minAge != null && maxAge != null) {
    tempFilteredUsers = tempFilteredUsers.where((user) =>
      user.age >= minAge && user.age <= maxAge).toList();
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
          preferredSize: Size.fromHeight(200.0), // Ajuste a altura conforme necessário
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
                child: Row(
                  children: [
                    Expanded(child: _buildGenderDropdown()),
                    SizedBox(width: 8), // Espaço entre os widgets
                    Expanded(child: _buildAgeRangeFields()), // Utilizando o novo método de intervalo de idades
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
              ? Center(child: Text('Nenhum usuário encontrado'))
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
      items: <String>['all', 'male', 'female'].map((String value) {
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

  Widget _buildAgeRangeFields() {
  return Row(
    children: [
      Expanded(
        child: TextField(
          controller: _minAgeController, // Você precisará definir este controlador
          decoration: InputDecoration(
            labelText: 'Idade Mínima',
            hintText: 'Ex: 20',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _onSearchChanged(),
        ),
      ),
      SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: _maxAgeController, // Você precisará definir este controlador
          decoration: InputDecoration(
            labelText: 'Idade Máxima',
            hintText: 'Ex: 30',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) => _onSearchChanged(),
        ),
      ),
    ],
  );
}

}
