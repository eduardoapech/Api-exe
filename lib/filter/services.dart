import 'package:api_dados/filter/model.dart';
import 'package:dio/dio.dart';

ApiServices() async {
  const String baseUrl = 'https://randomuser.me/api/1.4/?results=10';
  Dio dio = Dio();

  try {
    var res = await dio.get(baseUrl);
    if (res.statusCode == 200) {
      List<dynamic> usersData = res.data['results'];
      return usersData.map<PersonModel>((user) => PersonModel.fromJson(user)).toList();
    } else {
      print('Failed to load user data');
    }
  } catch (e) {
    print(e.toString());
  }
}
