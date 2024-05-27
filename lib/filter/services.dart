import 'package:dio/dio.dart'; // Importa a biblioteca Dio para realizar requisições HTTP
import 'package:api_dados/models/person_model.dart'; // Importa o modelo PersonModel

// Função assíncrona para buscar usuários aleatórios
Future<List<PersonModel>> fetchRandomUsers() async {
  // Define a URL base para a API randomuser.me, solicitando 10 resultados
  const String baseUrl = 'https://randomuser.me/api/1.4/?results=10';
  Dio dio = Dio(); // Cria uma instância da classe Dio

  try {
    // Realiza uma requisição GET para a URL base
    var res = await dio.get(baseUrl);
    
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
