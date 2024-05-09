import 'package:api_dados/filter/nat.dart';
import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';
import '../filter/gender_dropdown.dart';
import '../filter/age_range_fields.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<PersonModel> _users = [];
  List<PersonModel> _filteredUsers = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  String? _selectedGender;
  String? _selectedNationality;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      var users = await ApiServices().fetchUserData(50);
      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    var tempFilteredUsers = _users.where((user) {
      return user.name.toLowerCase().startsWith(_searchController.text.toLowerCase()) &&
          (_selectedGender == null || _selectedGender == 'all' || user.gender.toLowerCase() == _selectedGender!.toLowerCase()) &&
          (_selectedNationality == null || user.nat.toLowerCase() == _selectedNationality!.toLowerCase()) &&
          (int.tryParse(_minAgeController.text) == null || user.age >= int.tryParse(_minAgeController.text)!) &&
          (int.tryParse(_maxAgeController.text) == null || user.age <= int.tryParse(_maxAgeController.text)!);
    }).toList();
    setState(() => _filteredUsers = tempFilteredUsers);
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
            padding: EdgeInsets.symmetric(horizontal: 2.0),
            child: Row(
              children: [
                Expanded(
                  child: GenderDropdown(
                    selectedGender: _selectedGender,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue;
                        _onSearchChanged();
                      });
                    },
                  ),
                ),
                SizedBox(width: 2),
                Expanded(
                  child: AgeRangeFields(
                    minAgeController: _minAgeController,
                    maxAgeController: _maxAgeController,
                    onChanged: (_) => _onSearchChanged(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                  child: NationalityDropdown(
                    selectedNationality: _selectedNationality,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedNationality = newValue;
                        _onSearchChanged();
                      });
                    },
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
                                  subtitle: Text(
                                      '${_filteredUsers[index].email}, ${_filteredUsers[index].city}, ${_filteredUsers[index].state}, ${_filteredUsers[index].gender}, Age: ${_filteredUsers[index].age}'),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}