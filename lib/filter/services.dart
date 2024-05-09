import 'package:api_dados/filter/model.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static const String baseUrl = 'https://randomuser.me/api/';
  Dio dio = Dio();

  // Adiciona parâmetros opcionais para filtro de idade, gênero e nacionalidade
  Future<List<PersonModel>> fetchUserData(int count, {int? minAge, int? maxAge}) async {
    var queryParams = {
      'results': count.toString(),
      if (minAge != null) 'minAge': minAge.toString(),
      if (maxAge != null) 'maxAge': maxAge.toString(),
    };

    var response = await dio.get(baseUrl, queryParameters: queryParams);
    return response.data['results'].map<PersonModel>((user) => PersonModel.fromJson(user)).where((userModel) => (minAge == null || userModel.age >= minAge) && (maxAge == null || userModel.age <= maxAge)).toList();
  }
}
