import 'package:cinenook/api/api.dart';
import 'package:cinenook/controllers/auth_controller.dart';
import 'package:cinenook/controllers/movie_controller.dart';
import 'package:cinenook/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Api api = Api();

    // Initialize controllers
    Get.put<AuthController>(AuthController());
    Get.put<MovieController>(MovieController(api: api));

    final authController = Get.find<AuthController>();

    // Create app router with auth controller
    final appRouter = AppRouter(authController);

    // Use standard MaterialApp.router but configure GetX with Get.key
    return GetMaterialApp.router(
      title: 'CineNook',
      theme: ThemeData.dark(useMaterial3: true),
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
    );
  }
}
