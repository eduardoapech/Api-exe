import 'package:api_dados/filter/model.dart';
import 'package:dio/dio.dart';

class ApiServices {
  static const String baseUrl = 'https://randomuser.me/api/?gender,nome,login,nat,id,dob,age';
  Dio dio = Dio();

  Future<List<PersonModel>> fetchUserData(int count, {String? gender, Function? onLoadingStart, Function? onLoadingEnd}) async {
    try {
      onLoadingStart?.call(); 
      var queryParams = {
        'results': count.toString(),
        if (gender != null) 'gender': gender,
      };
      var response = await dio.get(baseUrl, queryParameters: queryParams);
      if (response.statusCode == 200) {
        List<dynamic> usersData = response.data['results'];
        return usersData.map<PersonModel>((user) => PersonModel.fromJson(user)).toList();
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      rethrow;
    } finally {
      onLoadingEnd?.call(); 
    }
  }
}

