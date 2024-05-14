import 'package:flutter/material.dart';
import 'package:api_dados/views/user_data_page_view.dart'; // Certifique-se de que o caminho está correto

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
