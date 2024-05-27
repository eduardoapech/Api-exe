import 'package:api_dados/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api_dados/filter/model.dart';
import 'package:api_dados/widgets/cs_text_field.dart';

class UserEditPage extends StatefulWidget {
  final PersonModel user;

  UserEditPage({required this.user});

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>();

  bool hasModifications = false;
  late PersonModel _editedUser;

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _ageController;

  late String _gender;

  late String _originalName,
      _originalUsername,
      _originalEmail,
      _originalCity,
      _originalState,
      _originalGender;
  late int _originalAge;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;

    _nameController = TextEditingController(text: widget.user.name);
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _cityController = TextEditingController(text: widget.user.city);
    _stateController = TextEditingController(text: widget.user.state);
    _ageController = TextEditingController(text: widget.user.age.toString());

    _originalName = widget.user.name;
    _originalUsername = widget.user.username;
    _originalEmail = widget.user.email;
    _originalCity = widget.user.city;
    _originalState = widget.user.state;
    _originalGender = widget.user.gender;
    _originalAge = widget.user.age;
    _gender = widget.user.gender;

    _nameController.addListener(_checkForModifications);
    _usernameController.addListener(_checkForModifications);
    _emailController.addListener(_checkForModifications);
    _cityController.addListener(_checkForModifications);
    _stateController.addListener(_checkForModifications);
    _ageController.addListener(_checkForModifications);
  }

  void _checkForModifications() {
    setState(() {
      hasModifications = _nameController.text != _originalName ||
          _usernameController.text != _originalUsername ||
          _emailController.text != _originalEmail ||
          _cityController.text != _originalCity ||
          _stateController.text != _originalState ||
          _gender != _originalGender ||
          int.parse(_ageController.text) != _originalAge;
    });
  }

  void _onFieldChanged(String field, String value) {
    setState(() {
      switch (field) {
        case 'name':
          _editedUser.name = value;
          break;
        case 'username':
          _editedUser.username = value;
          break;
        case 'email':
          _editedUser.email = value;
          break;
        case 'city':
          _editedUser.city = value;
          break;
        case 'state':
          _editedUser.state = value;
          break;
        case 'age':
          _editedUser.age = int.parse(value);
          break;
        case 'gender':
          _editedUser.gender = value;
          break;
      }
      hasModifications = true;
    });
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmação'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Não'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Sim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _saveUser(BuildContext context) async {
    if (_formKey.currentState!.validate() && hasModifications) {
      final updatedUser = PersonModel(
        id: widget.user.id,
        name: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        avatarUrl: widget.user.avatarUrl,
        city: _cityController.text,
        state: _stateController.text,
        gender: _gender,
        age: int.parse(_ageController.text),
      );
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cadastro atualizado com sucesso')));
      Navigator.pop(context, updatedUser);
    }
  }

  Widget _saveButton(BuildContext context) {
    return TextButton(
      onPressed: hasModifications ? () => _saveUser(context) : null,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 40, 51, 59),
        disabledForegroundColor: Colors.grey.withOpacity(0.38),
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      ),
      child: const Text('Salvar Usuário'),
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Gender',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Radio<String>(
              value: 'male',
              groupValue: _gender,
              onChanged: (value) {
                hasModifications = true;
              },
            ),
            Text('Male'),
            Radio<String>(
              value: 'female',
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                  _onFieldChanged('gender', value);
                });
              },
            ),
            Text('Female'),
          ],
        ),
        if (_gender.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0),
            child: Text(
              'Por favor, selecione um gênero',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _handleBackPress() async {
    if (hasModifications) {
      bool confirmExit = await _showConfirmationDialog(
          'Tem certeza de que deseja sair sem salvar as alterações?');
      if (confirmExit) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        await _handleBackPress();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar Usuário'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _handleBackPress,
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                CsTextField(
                    labelText: 'Name',
                    controller: _nameController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o nome';
                      }
                      return null;
                    },
                    onChanged: (newText) {
                      hasModifications = true;
                    }),
                CsTextField(
                    labelText: 'Username',
                    controller: _usernameController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o nome de usuário';
                      }
                      return null;
                    },
                    onChanged: (newText) {
                      hasModifications = true;
                    }),
                CsTextField(
                    labelText: 'Email',
                    controller: _emailController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o email';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (newText) {
                      hasModifications = true;
                    }),
                CsTextField(
                    labelText: 'City',
                    controller: _cityController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira a cidade';
                      }
                      return null;
                    },
                    onChanged: (newText) {
                      hasModifications = true;
                    }),
                CsTextField(
                    labelText: 'State',
                    controller: _stateController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira o estado';
                      }
                      return null;
                    },
                    onChanged: (newText) {
                      hasModifications = true;
                    }),
                _buildGenderField(),
                CsTextField(
                    labelText: 'Age',
                    controller: _ageController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira a idade';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    onChanged: (newText) {
                      setState(() {
                        hasModifications = newText;
                      });
                    }),
                const SizedBox(height: 20),
                _saveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
