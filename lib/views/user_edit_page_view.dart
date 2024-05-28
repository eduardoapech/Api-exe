import 'package:api_dados/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:api_dados/models/person_model.dart';
import 'package:api_dados/widgets/cs_text_field.dart';

class UserEditPage extends StatefulWidget {
  final PersonModel user;

  UserEditPage({required this.user});

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _formKey = GlobalKey<FormState>();

  bool hasModifications = false; // Indica se houve modificações no formulário
  late PersonModel _editedUser;

  // Controladores para os campos de texto
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _ageController;

  late String _gender; // Inicializa o gênero com valor vazio

  // Variáveis para armazenar os valores originais dos campos
  late String _originalName, _originalUsername, _originalEmail, _originalCity, _originalState, _originalGender;
  late int _originalAge;

  @override
  void initState() {
    super.initState();
    _editedUser = widget.user;

    // Inicializa os controladores com os valores do usuário
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
    _gender = widget.user.gender; // Inicializa o gênero com o valor do usuário

    // Adiciona listeners para verificar modificações nos campos
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
                         _ageController.text != _originalAge.toString();
    });
  }

  // Atualiza o campo do usuário quando há modificações
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
          _editedUser.age = int.tryParse(value) ?? _originalAge; // Lida com formato de número inválido
          break;
        case 'gender':
          _editedUser.gender = value;
          break;
      }
      hasModifications = true;
    });
  }

  // Mostra um diálogo de confirmação
  Future<void> _showConfirmationDialog(String message) async {
    var response = await showDialog<bool>(
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
    if (response) {
      Navigator.pop(context);
    }
  }

  // Salva o usuário atualizado no banco de dados
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
        age: int.tryParse(_ageController.text) ?? _originalAge, // Lida com formato de número inválido
      );
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateUser(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro atualizado com sucesso')),
      );
      Navigator.of(context).pop(updatedUser); // Use Navigator.of(context).pop para garantir que a navegação ocorra corretamente
    }
  }

  // Botão de salvar usuário
  Widget _saveButton(BuildContext context) {
    return TextButton(
      onPressed: hasModifications ? () => _saveUser(context) : null,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white, // Cor do texto do botão quando habilitado
        backgroundColor: Color.fromARGB(255, 40, 51, 59), // Cor de fundo do botão quando habilitado
        disabledForegroundColor: Colors.grey.withOpacity(0.38), // Cor do texto do botão quando desabilitado
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Padding do botão
      ),
      child: const Text('Salvar Usuário'), // Texto do botão
    );
  }

  // Constrói o campo de seleção de gênero usando DropdownButtonFormField
  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _gender.isNotEmpty ? _gender : null,
      items: [
        DropdownMenuItem(
          value: 'outro',
          child: Text('Outro'),
        ),
        DropdownMenuItem(
          value: 'male',
          child: Text('Male'),
        ),
        DropdownMenuItem(
          value: 'female',
          child: Text('Female'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          hasModifications = true;
          _gender = value ?? '';
          
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Gênero',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, selecione um gênero';
        }
        return null;
      },
    );
    
  }
  

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasModifications,
      onPopInvoked: (bool didPop) {
        if (didPop) return;

        _showConfirmationDialog('Tem certeza de que deseja atualizar o usuário?');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Editar Usuário'),
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
                  onChanged: (_) {
                    hasModifications = true;
                  },
                ),
                CsTextField(
                  labelText: 'Username',
                  
                  controller: _usernameController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira o nome de usuário';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    hasModifications = true;
                  },
                ),
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
                  onChanged: (_) {
                    hasModifications = true;
                  },
                ),
                CsTextField(
                  labelText: 'City',
                  controller: _cityController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira a cidade';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    hasModifications = true;
                  },
                ),
                CsTextField(
                  labelText: 'State',
                  controller: _stateController,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Insira o estado';
                    }
                    return null;
                  },
                  onChanged: (_) {
                    hasModifications = true;
                  },
                ),
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
                      hasModifications = true;
                    });
                  },
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
