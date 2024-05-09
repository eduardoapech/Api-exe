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

    try {
      var response = await dio.get(baseUrl, queryParameters: queryParams);
      if (response.statusCode == 200) {
        // Assumindo que a chave 'results' contém a lista de usuários
        List<dynamic> usersData = response.data['results'];
        return usersData.map<PersonModel>((user) => PersonModel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow; // Re-lança a exceção para tratamento adicional se necessário
    }
  }
}
