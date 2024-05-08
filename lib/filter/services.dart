import 'dart:convert';

import 'package:api_dados/filter/model.dart';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';


class ApiServices {
  static const String baseUrl = 'https://randomuser.me/api/';
  Dio dio = Dio();

  Future<List<FilterModel>> fetchUserData(int count) async {
    try {
      var response = await dio.get('$baseUrl', queryParameters: {'results': count});
      List<FilterModel> users = [];
      for (var user in response.data['results']) {
        users.add(FilterModel.fromJson(user));
      }
      return users;
    } catch (e) {
      print(e);
      throw Exception('Failed to load user data');
    }
  }
}