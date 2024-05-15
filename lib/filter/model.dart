class PersonModel {
  final String id;
  final String name;
  final String username;
  final String email;
  final String avatarUrl;
  final String city;
  final String state;
  final String gender;
  final int age;

  PersonModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.city,
    required this.state,
    required this.gender,
    required this.age,
  });

  factory PersonModel.fromJson(Map<String, dynamic> json) {
    return PersonModel(
      id: json['login']['uuid'],
      name: '${json['name']['first']} ${json['name']['last']}',
      username: json['login']['username'],
      email: json['email'],
      avatarUrl: json['picture']['large'],
      city: json['location']['city'],
      state: json['location']['state'],
      gender: json['gender'],
      age: json['dob']['age'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'city': city,
      'state': state,
      'gender': gender,
      'age': age,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'],
      name: map['name'],
      username: map['username'],
      email: map['email'],
      avatarUrl: map['avatarUrl'],
      city: map['city'],
      state: map['state'],
      gender: map['gender'],
      age: map['age'],
    );
  }
}
