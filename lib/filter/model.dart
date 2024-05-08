class FilterModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final String city;
  final String state;
  final String gender;
  final int age;  // Campo adicionado

  FilterModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.city,
    required this.state,
    required this.gender,
    required this.age,  // Construtor atualizado
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      id: json['login']['uuid'],
      name: '${json['name']['first']} ${json['name']['last']}',
      username: json['login']['username'],
      email: json['email'],
      avatarUrl: json['picture']['large'],
      city: json['location']['city'],
      state: json['location']['state'],
      gender: json['gender'],
      age: json['dob']['age'],  // Extração da idade do JSON
    );
  }
}
