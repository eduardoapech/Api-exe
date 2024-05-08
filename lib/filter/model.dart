import 'dart:math';
import 'package:flutter/material.dart';

class FilterModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final String city;
  final String state;
  final String gender;
  final int age;
  final Color displayColor; // Campo para armazenar a cor

  FilterModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.city,
    required this.state,
    required this.gender,
    required this.age,
    required this.displayColor,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    Random random = Random();
    Color color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    return FilterModel(
      id: json['login']['uuid'],
      name: '${json['name']['first']} ${json['name']['last']}',
      username: json['login']['username'],
      email: json['email'],
      avatarUrl: json['picture']['large'],
      city: json['location']['city'],
      state: json['location']['state'],
      gender: json['gender'],
      age: json['dob']['age'],
      displayColor: color, // Atribui uma cor aleatória
    );
  }
}
