import 'package:flutter/material.dart';
import 'package:api_dados/filter/user_detail_page.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/filter/services.dart';

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  List<PersonModel> _filteredUsers = [];
  bool _isLoading = false;

  _loadUserData() async {
    _isLoading = true;
    ApiServices().then((value) {
      setState(() {
        _filteredUsers = value;
        _isLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Random User Data'),
        ),
        body: _isLoading
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
        floatingActionButton: FloatingActionButton(
          onPressed: _loadUserData,
          tooltip: 'Reload',
          child: Icon(Icons.refresh),
        ));
  }
}
