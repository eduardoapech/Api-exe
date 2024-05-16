import 'package:api_dados/validator/validators.dart';
import 'package:api_dados/widgets/cs_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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



  // Controladores para os campos de texto
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _ageController;

  late String _gender;

  bool _isFieldChanged = false;

  // Valores originais para verificação
  late String _originalName, _originalUsername, _originalEmail, _originalCity, _originalState, _originalGender;
  late int _originalAge;

  @override
  void initState() {
    super.initState();
    _gender = _originalGender = widget.user.gender;

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
    _originalAge = widget.user.age;
  }

  Future<bool> _showConfirmationDialog(String message) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirmação'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Retorna false para cancelar a ação
                child: Text('Não'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Retorna true para confirmar a ação
                child: Text('Sim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _saveUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      


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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cadastro atualizado com sucesso')));
      Navigator.pop(context, updatedUser); // Retorna o usuário atualizado
    }
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

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Gender',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões de rádio
          children: <Widget>[
            Radio<String>(
              value: 'male',
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value!;
                });
              },
            ),
            Text('Male'),
            Radio<String>(
              value: 'female',
              groupValue: _gender,
              onChanged: (value) {
                setState(() {
                  _gender = value!;
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
    bool isEdited = _nameController.text != _originalName || _usernameController.text != _originalUsername || _emailController.text != _originalEmail || _cityController.text != _originalCity || _stateController.text != _originalState || _gender != _originalGender || int.parse(_ageController.text) != _originalAge;

    if (isEdited) {
      bool confirmExit = await _showConfirmationDialog('Tem certeza de que deseja sair sem salvar as alterações?');
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
      onPopInvoked: (didPop) {},
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
                    validator: Validators.validateName,
                    onChanged: (value) {
                      setState(() {
                        _isFieldChanged = true;
                      });
                    }),
                CsTextField(
                  labelText: 'Username',
                  controller: _usernameController,
                  validator: Validators.validateUsername,
                  onChanged: (value) {
                    setState(() {
                        _isFieldChanged = true;
                    });
                  },
                ),
                CsTextField(
                  labelText: 'Email',
                  controller: _emailController,
                  validator: Validators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                        _isFieldChanged = true;
                    });
                  },
                ),
                CsTextField(
                  labelText: 'City',
                  controller: _cityController,
                  validator: Validators.validateCity,
                  onChanged: (value) { setState(() {
                        _isFieldChanged = true;
                  });},
                ),
                CsTextField(
                  labelText: 'State',
                  controller: _stateController,
                  validator: Validators.validateState,
                  onChanged: (value) {setState(() {
                        _isFieldChanged = true;
                  });},
                ),
                _buildGenderField(),
                CsTextField(
                  labelText: 'Age',
                  controller: _ageController,
                  validator: Validators.validateAge,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  onChanged: (value) { setState(() {
                        _isFieldChanged = true;
                  });},
                ),
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
