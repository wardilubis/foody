import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/registration_form.dart';

class RegistrationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: BlocProvider(
        create: (_) => AuthBloc(
          registerUser: context.read<RegisterUser>(),
        ),
        child: RegistrationForm(),
      ),
    );
  }
}
