// Importa o modelo FilterModel
import 'package:api_dados/models/filter_model.dart';
import 'package:flutter/material.dart'; // Importa a biblioteca Flutter para construir a interface do usuário
import 'package:api_dados/views/user_data_page_view.dart'; // Certifique-se de que o caminho está correto para a visualização da página de dados do usuário

// Cria uma instância do modelo FilterModel
// final filtroPessoa = FilterModel();

// // Declaração de variáveis globais para filtros
// late final String name;
// late final String gender;
// late final String age;

// Função principal que inicializa o aplicativo
void main() {
  setupLocator();
  runApp(const MyApp()); // Executa o aplicativo, iniciando pelo widget MyApp
}

// Classe MyApp, que é o widget raiz do aplicativo
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '', // Define o título do aplicativo
      theme: ThemeData(primarySwatch: Colors.blue, textTheme: const TextTheme() // Define o tema do aplicativo, com a cor primária azul
          ),
      home: const UserDataPage(), // Define a página inicial do aplicativo como UserDataPage
    );
  }
}
