import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin AuthGuardMixin<T extends StatefulWidget> on State<T> {
  void checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = context.read<AuthBloc>().state;
        if (authState is! Authenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }
}
