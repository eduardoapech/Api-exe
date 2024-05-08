import 'dart:convert';

import 'package:api_dados/filter/model.dart';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class ApiServices {
  static const String baseUrl = 'https://randomuser.me/api/';
  Dio dio = Dio();

  // Adiciona parâmetros opcionais para filtro de idade e gênero
  Future<List<FilterModel>> fetchUserData(int count, {int? minAge, int? maxAge, String? gender}) async {
    try {
      var response = await dio.get('$baseUrl', queryParameters: {'results': count});
      List<FilterModel> users = [];
      for (var user in response.data['results']) {
        FilterModel userModel = FilterModel.fromJson(user);
        // Aplica o filtro se os parâmetros foram fornecidos
        if ((minAge == null || userModel.age >= minAge) && 
            (maxAge == null || userModel.age <= maxAge) &&
            (gender == null || userModel.gender == gender)) {
          users.add(userModel);
        }
      }
      return users;
    } catch (e) {
      print(e);
      throw Exception('Failed to load user data');
    }
  }
}
