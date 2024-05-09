import 'package:api_dados/views/user_data_page_view.dart';
import 'package:flutter/material.dart';
// Substitua 'your_api_class_file.dart' pelo nome do arquivo onde você definiu a classe API

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random User Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserDataPage(),
    );
  }
}
