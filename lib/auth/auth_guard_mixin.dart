import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:go_router/go_router.dart';

mixin AuthGuardMixin<T extends StatefulWidget> on State<T> {
  // Get auth controller instance
  AuthController get authController => Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    checkAuthentication();
  }

  void checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!authController.isLoggedIn) {
        context.goNamed('login');
      }
    });
  }
}
