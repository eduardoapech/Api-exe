// Define a classe FilterModel para armazenar critérios de filtro

import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

setupLocator() { 
  getIt.registerLazySingleton<FilterModel>(() => FilterModel());
}

final filtroPessoa = getIt<FilterModel>();
late final String name;
late final String gender;
late final String age;


class FilterModel { 
  // Campos da classe para armazenar os critérios de filtro
  String? name;  // Nome do usuário a ser filtrado
  String? gender;  // Gênero do usuário a ser filtrado
  int? minAge;  // Idade mínima do usuário a ser filtrado
  int? maxAge;  // Idade máxima do usuário a ser filtrado

  // Construtor da classe FilterModel que inicializa os campos com valores opcionais
  FilterModel({this.name, this.gender, this.minAge, this.maxAge});
}
