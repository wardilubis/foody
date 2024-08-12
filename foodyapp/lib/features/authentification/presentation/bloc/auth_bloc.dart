import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_user.dart';
import '../../../../core/error/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUser;

  AuthBloc({required this.registerUser}) : super(AuthInitial());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is RegisterButtonPressed) {
      yield AuthLoading();

      final user = User(
        username: event.username,
        email: event.email,
        password: event.password,
      );

      final failureOrSuccess = await registerUser(user);

      yield failureOrSuccess.fold(
        (failure) => AuthError(message: _mapFailureToMessage(failure)),
        (_) => AuthRegistered(),
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Registration failed, please try again.';
      case UsernameAlreadyExistsFailure:
        return 'Username already exists.';
      default:
        return 'Unexpected error occurred.';
    }
  }
}
