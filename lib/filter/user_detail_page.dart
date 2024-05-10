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
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Name: ${user.name}', style: TextStyle(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text('Email: ${user.email}', style: TextStyle(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_city),
                        title: Text('City: ${user.city}', style: TextStyle(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.map),
                        title: Text('State: ${user.state}', style: TextStyle(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.transgender),
                        title: Text('Gender: ${user.gender}', style: TextStyle(fontSize: 18)),
                      ),
                      ListTile(
                        leading: Icon(Icons.cake),
                        title: Text('Age: ${user.age}', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              )
            ])));
  }
}
