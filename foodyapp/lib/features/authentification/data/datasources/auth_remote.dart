import '../models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<void> registerUser(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<void> registerUser(UserModel user) async {
    final response = await client.post(
      'https://yourapi.com/register',
      data: user.toJson(),
    );

    if (response.statusCode != 201) {
      throw ServerException();
    }
  }
}
