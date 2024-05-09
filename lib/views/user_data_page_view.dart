import 'package:flutter/material.dart';
import 'package:api_dados/filter/user_detail_page.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';
import '../filter/gender_dropdown.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<PersonModel> _filteredUsers = [];
  bool _isLoading = false;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega os dados iniciais ao iniciar
  }

  void _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      var users = await ApiServices().fetchUserData(50, gender: _selectedGender);
      setState(() {
        _filteredUsers = users;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random User Data'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Row(
              children: [
                Expanded(
                  child: GenderDropdown(
                    selectedGender: _selectedGender,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                      });
                      _loadUserData();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
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
                            subtitle: Text('${_filteredUsers[index].email}, ${_filteredUsers[index].city}, ${_filteredUsers[index].state}, ${_filteredUsers[index].gender}, Age: ${_filteredUsers[index].age}'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserDetailPage(user: _filteredUsers[index]),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadUserData,
        tooltip: 'Reload Data',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
