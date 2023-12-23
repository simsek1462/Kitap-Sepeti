class Users {
  String? id;
  String? name;
  String? surname;
  String? email;
  String? password;
  String? adress;

  Users(this.id,this.name, this.surname, this.email, this.password, this.adress);

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(json["id"] as String,json["name"] as String,json["surname"] as String,json["mail"] as String,json["password"] as String,json["adress"] as String);
  }
  Map<String, dynamic> toJson() {
    return {
      'id':id,
      'name': name,
      'surname': surname,
      'email': email,
      'password': password,
      'adress': adress
    };
  }
}
