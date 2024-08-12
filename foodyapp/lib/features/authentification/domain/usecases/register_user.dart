import 'package:dartz/dartz.dart';
import 'package:foody/core/error/failures.dart';
import 'package:foody/core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUser implements UseCase<void, User> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, void>> call(User user) async {
    return await repository.registerUser(user);
  }
}
