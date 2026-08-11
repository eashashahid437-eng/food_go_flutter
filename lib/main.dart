import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Auth/Login_Screen.dart' as login_screen_upper;
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Screens/splash_screen.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // Starting screen
      home: const SplashScreen(),

      // Login route
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
        ),
      ],
    );
  }
}
