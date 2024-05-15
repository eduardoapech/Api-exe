import 'package:api_dados/validator/validators.dart';
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

  void _saveUser(BuildContext context) async {
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

      Navigator.pop(context, updatedUser); // Retorna o usuário atualizado para a tela anterior
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.blue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.red),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    );
  }

  Widget _buildTextField({
    required String labelText,
    required String initialValue,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: _inputDecoration(labelText),
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboardType,
      ),
    );
  }

  Widget _saveButton(BuildContext context) {
    return TextButton(
      onPressed: () => _saveUser(context),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 40, 51, 59),
        disabledForegroundColor: Colors.grey.withOpacity(0.38),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      ),
      child: const Text('Salvar Usuário'),
    );
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
              _buildTextField(
                labelText: 'Name',
                initialValue: _name,
                validator: Validators.validateName,
                onSaved: (value) {
                  _name = value!;
                },
              ),
              _buildTextField(
                labelText: 'Username',
                initialValue: _username,
                validator: Validators.validateUsername,
                onSaved: (value) {
                  _username = value!;
                },
              ),
              _buildTextField(
                labelText: 'Email',
                initialValue: _email,
                validator: Validators.validateEmail,
                onSaved: (value) {
                  _email = value!;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                labelText: 'City',
                initialValue: _city,
                validator: Validators.validateCity,
                onSaved: (value) {
                  _city = value!;
                },
              ),
              _buildTextField(
                labelText: 'State',
                initialValue: _state,
                validator: Validators.validateState,
                onSaved: (value) {
                  _state = value!;
                },
              ),
              _buildTextField(
                labelText: 'Gender',
                initialValue: _gender,
                validator: Validators.validateGender,
                onSaved: (value) {
                  _gender = value!;
                },
              ),
              _buildTextField(
                labelText: 'Age',
                initialValue: _age.toString(),
                validator: Validators.validateAge,
                onSaved: (value) {
                  _age = int.parse(value!);
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _saveButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
