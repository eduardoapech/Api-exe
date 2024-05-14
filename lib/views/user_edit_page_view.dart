import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/database_helper.dart';

class UserEditPage extends StatefulWidget {
  final PersonModel user;

  UserEditPage({required this.user});

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _username;
  late String _email;
  late String _city;
  late String _state;
  late String _gender;
  late int _age;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _username = widget.user.username;
    _email = widget.user.email;
    _city = widget.user.city;
    _state = widget.user.state;
    _gender = widget.user.gender;
    _age = widget.user.age;
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedUser = PersonModel(
        id: widget.user.id,
        name: _name,
        username: _username,
        email: _email,
        avatarUrl: widget.user.avatarUrl,
        city: _city,
        state: _state,
        gender: _gender,
        age: _age,
      );

      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro atualizado com sucesso'),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, updatedUser); // Return the updated user to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Usuário'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) {
                  _username = value!;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value!;
                },
              ),
              TextFormField(
                initialValue: _city,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
                onSaved: (value) {
                  _city = value!;
                },
              ),
              TextFormField(
                initialValue: _state,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a state';
                  }
                  return null;
                },
                onSaved: (value) {
                  _state = value!;
                },
              ),
              TextFormField(
                initialValue: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a gender';
                  }
                  return null;
                },
                onSaved: (value) {
                  _gender = value!;
                },
              ),
              TextFormField(
                initialValue: _age.toString(),
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _age = int.parse(value!);
                },
              ),
              SizedBox(height: 20),
              Center(
                child: FilledButton.tonal(
                  onPressed: _saveUser,
                  child: Text('Salvar Usuário'),
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 179, 206, 228)), foregroundColor: MaterialStateProperty.all(Color.fromARGB(255, 102, 153, 73))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
