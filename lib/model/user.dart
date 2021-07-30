import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String? name;
  final String? age;

  User({this.name, this.age});

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return new User(
      name: parsedJson['name'] ?? "",
      age: parsedJson['age'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": this.name,
      "age": this.age,
    };
  }

  static getUser() async {
    SharedPreferences shared_User = await SharedPreferences.getInstance();
    String jsonString = '';
    Map<String, dynamic> decode_options = jsonDecode(jsonString);
    String user = jsonEncode(User.fromJson(decode_options));
    shared_User.setString('user', user);

    // SharedPreferences shared_User = await SharedPreferences.getInstance();
    // Map userMap = jsonDecode(shared_User.getString('user'));
    // var user = User.fromJson(userMap);
  }
}
