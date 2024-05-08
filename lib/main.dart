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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var users = await ApiServices().fetchUserData(5);
      setState(() {
        _users = users;
      });
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Random User Data'),
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_users[index].name),
                subtitle: Text('${_users[index].email}, ${_users[index].city}, ${_users[index].state}, ${_users[index].gender}'),
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
}
