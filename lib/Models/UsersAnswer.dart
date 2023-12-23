import 'Users.dart';

class UsersAnswers{
  int? success;
  List<Users>? users;

  UsersAnswers(this.success, this.users);
  factory UsersAnswers.fromJson(Map<String,dynamic>json){
    var jsonArray= json["users"] as List;
    List<Users>? users=jsonArray.map((jsonArrayObject) => Users.fromJson(jsonArrayObject)).toList();
    return UsersAnswers(json["success"]as int,users);
  }
}