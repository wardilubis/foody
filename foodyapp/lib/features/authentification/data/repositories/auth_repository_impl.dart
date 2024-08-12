import 'package:dartz/dartz.dart';
import 'package:foody/core/error/exceptions.dart';
import 'package:foody/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> registerUser(User user) async {
    try {
      await remoteDataSource.registerUser(user);
      return Right(null);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
