import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cinenook/blocs/auth/auth_bloc.dart';
import 'package:cinenook/blocs/auth/auth_state.dart';
import 'package:go_router/go_router.dart';

mixin AuthGuardMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  void checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final authState = context.read<AuthBloc>().state;
      if (authState is! Authenticated) {
        context.goNamed('login');
      }
    });
  }
}
