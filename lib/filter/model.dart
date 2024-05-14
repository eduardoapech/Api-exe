class PersonModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String city;
  final String state;
  final String gender;
  final int age;
  final String avatarUrl;

  PersonModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.city,
    required this.state,
    required this.gender,
    required this.age,
    required this.avatarUrl,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['login']['uuid'],
      name: "${json['name']['first']} ${json['name']['last']}",
      username: json['login']['username'],
      email: json['email'],
      city: json['location']['city'],
      state: json['location']['state'],
      gender: json['gender'],
      age: json['dob']['age'],
      avatarUrl: json['picture']['large'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'city': city,
      'state': state,
      'gender': gender,
      'age': age,
      'avatarUrl': avatarUrl,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      email: map['email'],
      city: map['city'],
      state: map['state'],
      gender: map['gender'],
      age: map['age'],
      avatarUrl: map['avatarUrl'],
    );
  }
}
