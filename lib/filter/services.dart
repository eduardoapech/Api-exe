import 'package:api_dados/filter/model.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static const String baseUrl = 'https://randomuser.me/api/';
  Dio dio = Dio();

  Future<List<PersonModel>> fetchUserData(int count, {String? gender}) async {
    var queryParams = {
      'results': count.toString(),
      if (gender != null) 'gender': gender,
    };

    var response = await dio.get(baseUrl, queryParameters: queryParams);
    return response.data['results'].map<PersonModel>((user) => PersonModel.fromJson(user)).toList();
  }
}