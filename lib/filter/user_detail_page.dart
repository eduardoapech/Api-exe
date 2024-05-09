import 'package:flutter/material.dart';
import 'package:api_dados/filter/model.dart';

class UserDetailPage extends StatelessWidget {
  final PersonModel user;

  UserDetailPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
            Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
            Text('City: ${user.city}', style: TextStyle(fontSize: 18)),
            Text('State: ${user.state}', style: TextStyle(fontSize: 18)),
            Text('Gender: ${user.gender}', style: TextStyle(fontSize: 18)),
            Text('Age: ${user.age}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
