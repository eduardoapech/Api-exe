import 'package:api_dados/views/user_edit_page_view.dart'; // Importa a página de edição do usuário
import 'package:flutter/material.dart'; // Importa a biblioteca Flutter para construção da UI
import 'package:api_dados/models/person_model.dart'; // Importa o modelo PersonModel
import 'package:api_dados/services/database_helper.dart'; // Importa o DatabaseHelper para operações com banco de dados

// Declaração da classe UserDetailPage como um StatefulWidget
class UserDetailPage extends StatefulWidget {
  final PersonModel user; // Usuário cujos detalhes serão exibidos
  final bool showSaveButton; // Flag para mostrar ou não o botão de salvar

  const UserDetailPage({super.key, required this.user, this.showSaveButton = false}); // Construtor

  @override
  // ignore: library_private_types_in_public_api
  _UserDetailPageState createState() => _UserDetailPageState();
}

// Estado associado ao UserDetailPage
class _UserDetailPageState extends State<UserDetailPage> {
  late PersonModel _user; // Variável para armazenar o usuário

  @override
  void initState() {
    super.initState();
    _user = widget.user; // Inicializa _user com o usuário passado como parâmetro
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''), // Define o título da AppBar com o nome do usuário
        actions: [
          IconButton(
            icon: const Icon(Icons.edit), // Ícone de edição
            onPressed: () async {
              // Navega para a página de edição do usuário
              final updatedUser = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UserEditPage(user: _user),
                ),
              );
              // Se o usuário foi atualizado, reflete as mudanças
              if (updatedUser != null && updatedUser is PersonModel) {
                setState(() {
                  _user = updatedUser;
                });
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.blue, // Define a cor de fundo azul para a tela
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildAvatar(_user.avatarUrl, _user.name), // Constrói o avatar do usuário
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0), // Define o raio da borda do contorno
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildUserInfo(context), // Constrói as informações do usuário
                  ),
                ),
              ),
              if (widget.showSaveButton)
                Center(
                  child: _saveButton(context), // Constrói o botão de salvar se showSaveButton for true
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói o avatar do usuário
  Widget _buildAvatar(String imageUrl, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  // Constrói as informações do usuário
  Widget _buildUserInfo(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white),
        padding: const EdgeInsets.all(8.0),
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
      ),
    );
  }

  // Constrói um ListTile para exibir detalhes do usuário
  Widget _buildUserDetailTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon), // Ícone correspondente ao detalhe
      title: Text('$label: $value', style: const TextStyle(fontSize: 18)), // Label e valor do detalhe
    );
  }

  // Constrói o botão de salvar usuário
  Widget _saveButton(
    BuildContext context,
  ) {
    return TextButton(
      onPressed: () => _confirmSaveUser(
        context,
      ), // Chama _confirmSaveUser ao pressionar
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Colors.white,
        ),
        side: WidgetStateProperty.all(const BorderSide(
          color: Colors.black,
        )), // Define a cor da borda
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.green.withOpacity(
                0.2,
              ); // Define a cor do overlay quando o botão está sendo pressionado
            }
            if (states.contains(WidgetState.focused) ||
                states.contains(
                  WidgetState.pressed,
                )) return Colors.green.withOpacity(0.4); // Define a cor do overlay quando o botão está em foco
            return null;
          },
        ),
      ),
      child: const Text(
        'Salvar Usuário',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  // Confirma a atualização do usuário
  void _confirmSaveUser(BuildContext context) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Deseja Salvar?',
          ),
          content: const Text(
            '',
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.white,
                ),
                side: WidgetStateProperty.all(const BorderSide(
                  color: Colors.red,
                )), // Define a cor da borda
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.hovered)) {
                      return Colors.red.withOpacity(
                        0.2,
                      ); // Define a cor do overlay quando o botão está sendo pressionado
                    }
                    if (states.contains(WidgetState.focused) ||
                        states.contains(
                          WidgetState.pressed,
                        )) return Colors.red.withOpacity(0.4); // Define a cor do overlay quando o botão está em foco
                    return null;
                  },
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // Fecha o diálogo sem confirmar
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.white,
                ),
                side: WidgetStateProperty.all(
                  const BorderSide(
                    color: Colors.green,
                  ),
                ), // Define a cor da borda
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(
                      WidgetState.hovered,
                    )) {
                      return Colors.red.withOpacity(
                        0.2,
                      ); // Define a cor do overlay quando o botão está sendo pressionado
                    }
                    if (states.contains(
                          WidgetState.focused,
                        ) ||
                        states.contains(WidgetState.pressed)) {
                      return Colors.green.withOpacity(
                        0.4,
                      ); // Define a cor do overlay quando o botão está em foco
                    }
                    return null;
                  },
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // Fecha o diálogo e confirma
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _saveUser(context); // Chama _saveUser se confirmado
    }
  }

  // Salva ou atualiza o usuário no banco de dados
  void _saveUser(BuildContext context) async {
    final dbHelper = DatabaseHelper.instance;
    String message;

    // Verifica se o usuário já existe no banco de dados
    final existingUser = await dbHelper.getUserId(_user.id);
    if (existingUser != null) {
      // Atualiza o usuário existente
      await dbHelper.updateUser(_user);
      message = 'Usuário atualizado com sucesso';
    } else {
      // Insere um novo usuário
      await dbHelper.createUser(_user);
      message = 'Usuário salvo com sucesso';
    }

    // Mostra uma mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pop(context, _user); // Retorna o usuário atualizado para a tela anterior
  }
}
