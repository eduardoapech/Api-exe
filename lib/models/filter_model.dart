

class FilterModel {
  // Campos da classe para armazenar os critérios de filtro
  String? name; // Nome do usuário a ser filtrado
  String? gender = 'todos'; // Gênero do usuário a ser filtrado
  int? minAge; // Idade mínima do usuário a ser filtrado
  int? maxAge; // Idade máxima do usuário a ser filtrado

  // Construtor da classe FilterModel que inicializa os campos com valores opcionais
  FilterModel({this.name, this.gender, this.minAge, this.maxAge});
}
