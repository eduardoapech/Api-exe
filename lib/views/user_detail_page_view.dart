import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/database_helper.dart';
import 'package:api_dados/user_edit_page.dart'; // Importe o arquivo da página de edição

class UserDetailPage extends StatefulWidget {
  final PersonModel user;
  final bool showSaveButton;

  UserDetailPage({required this.user, this.showSaveButton = false});

  @override
  _UserDetailPageState createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late PersonModel _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserEditPage(user: _user),
                ),
              ).then((updatedUser) {
                if (updatedUser != null) {
                  setState(() {
                    _user = updatedUser;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildAvatar(_user.avatarUrl),
            const SizedBox(height: 20),
            Expanded(
              child: _buildUserInfo(context),
            ),
            if (widget.showSaveButton)
              Center(
                child: _saveButton(context),
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
          _buildUserDetailTile(Icons.person, 'Id', _user.id),
          _buildUserDetailTile(Icons.person_outline, 'Name', _user.name),
          _buildUserDetailTile(Icons.account_circle, 'Username', _user.username),
          _buildUserDetailTile(Icons.email, 'Email', _user.email),
          _buildUserDetailTile(Icons.location_city, 'City', _user.city),
          _buildUserDetailTile(Icons.map, 'State', _user.state),
          _buildUserDetailTile(Icons.transgender, 'Gender', _user.gender),
          _buildUserDetailTile(Icons.cake, 'Age', _user.age.toString()),
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
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 40, 51, 59),
        disabledForegroundColor: Colors.grey.withOpacity(0.38),
      ),
      child: const Text('Salvar Usuário'),
    );
  }

  void _saveUser(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    String message;

    // Verifica se o usuário já existe
    final existingUser = await dbHelper.getUserId(_user.id);
    int result;
    if (existingUser != null) {
      // Atualiza o usuário existente
      result = await dbHelper.updateUser(_user);
      message = result != 0 ? 'Usuário Atualizado com Sucesso' : 'Falha na Atualização';
    } else {
      // Cria um novo usuário
      result = await dbHelper.createUser(_user);
      message = result != 0 ? 'Usuário Salvo com Sucesso' : 'Falha ao Salvar Usuário';
    }

    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Volta para a tela inicial após salvar
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, result != 0);
    });
  }
}
