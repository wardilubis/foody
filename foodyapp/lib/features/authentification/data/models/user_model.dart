import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String username,
    required String email,
    required String password,
  }) : super(username: username, email: email, password: password);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
