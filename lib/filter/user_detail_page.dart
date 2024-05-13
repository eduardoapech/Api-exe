import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/database_helper.dart';

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
            _buildAvatar(user.avatarUrl),
            const SizedBox(height: 20),
            Expanded(
              child: _buildUserInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String imageUrl) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(imageUrl),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildUserDetailTile(Icons.person, 'Id', user.id),
          _buildUserDetailTile(Icons.person_outline, 'Name', user.name),
          _buildUserDetailTile(Icons.account_circle, 'Username', user.username),
          _buildUserDetailTile(Icons.email, 'Email', user.email),
          _buildUserDetailTile(Icons.location_city, 'City', user.city),
          _buildUserDetailTile(Icons.map, 'State', user.state),
          _buildUserDetailTile(Icons.transgender, 'Gender', user.gender),
          _buildUserDetailTile(Icons.cake, 'Age', user.age.toString()),
          Center(
            child: _saveButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text('$label: $value', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _saveButton(BuildContext context) {
    return TextButton(
      onPressed: () => _saveUser(context),
      child: const Text('Save User'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 40, 51, 59),
        disabledForegroundColor: Colors.grey.withOpacity(0.38).withOpacity(0.38),
      ),
    );
  }

  void _saveUser(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    String message; // Declare a variável no início para garantir que ela está acessível em todo o método

    // Verifica se o usuário já existe
    final existingUser = await dbHelper.getUserId(user.id);
    int result;
    if (existingUser != null) {
      // Atualiza o usuário existente
      result = await dbHelper.updateUser(user);
      message = result != 0 ? 'Usuário Atualizado com Sucesso' : 'Falha na Atualização';
    } else {
      // Cria um novo usuário
      result = await dbHelper.createUser(user);
      message = result != 0 ? 'Usuário Salvo com Sucesso' : 'Usuário já está Salvo';
    }

    final snackBar = SnackBar(
      content: Text(message), // Aqui a variável message será sempre inicializada
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
