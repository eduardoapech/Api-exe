import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart'; // Certifique-se que este é o caminho correto para o seu modelo PersonModel.
import 'package:api_dados/database_helper.dart'; // Caminho para sua classe DatabaseHelper

class UserDetailPage extends StatelessWidget {
  final PersonModel user;

  UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Id: ${user.id}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Name: ${user.name}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('Username: ${user.username}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email),
                      title: Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: Text('City: ${user.city}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: Text('State: ${user.state}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.transgender),
                      title: Text('Gender: ${user.gender}', style: const TextStyle(fontSize: 18)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cake),
                      title: Text('Age: ${user.age}', style: const TextStyle(fontSize: 18)),
                    ),
                    ElevatedButton(
                      onPressed: () => _saveUser(context),
                      child: const Text('Save User'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveUser(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    int result = await dbHelper.createUser(user);
    String message = result != 0 ? 'User saved successfully' : 'Failed to save user';
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
