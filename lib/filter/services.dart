import 'package:api_dados/models/person_model.dart';
import 'package:dio/dio.dart';

Future<List<PersonModel>> fetchRandomUsers({String? gender}) async {
  // Define a URL base para a API randomuser.me, solicitando 10 resultados
  const String baseUrl = 'https://randomuser.me/api/1.4/?results=10';
  Dio dio = Dio(); // Cria uma instância da classe Dio

  try {
    // Adiciona o parâmetro de gênero à URL se estiver presente
    String url = gender != null ? '$baseUrl&gender=$gender' : baseUrl;
    
    // Realiza uma requisição GET para a URL com o parâmetro de gênero, se fornecido
    var res = await dio.get(url);
    
    // Verifica se a resposta tem status 200 (OK)
    if (res.statusCode == 200) {
      // Extrai a lista de usuários da resposta
      List<dynamic> usersData = res.data['results'];
      
      // Mapeia os dados dos usuários para uma lista de objetos PersonModel
      return usersData.map<PersonModel>((user) => PersonModel.fromJson(user)).toList();
    } else {
      // Caso o status da resposta não seja 200, imprime uma mensagem de erro e retorna uma lista vazia
      print('Failed to load user data');
      return [];
    }
  } catch (e) {
    // Em caso de exceção, imprime o erro e retorna uma lista vazia
    print(e.toString());
    return [];
  }
}
