import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'firebase_options.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Screens/splash_screen.dart';
import 'package:food_go/Controllers/cartcontroller.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ---- Stripe setup ----
  Stripe.publishableKey = "pk_test_51U61yA31XAVPYuneJXmxrdbRDy3ZSCoXAgoY2sVRcjZcJHj6UN0D5odYlGaaKHfjMQjOJRU8iKXZG1PQQNmqFCXS00ZxWIkS6Z"; // apni Stripe publishable key yahan lagao
  await Stripe.instance.applySettings();
  // -----------------------

  Get.put<CartController>(CartController(), permanent: true);

  try {
    String? token = await FirebaseMessaging.instance.getToken();
    print("===== MY FCM TOKEN IS: $token =====");

    if (token != null) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
              'fcmToken': token,
              'tokenUpdatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      }
    }
  } catch (e) {
    print("Error getting FCM token: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),

      themeMode: ThemeMode.light,

      home: const SplashScreen(),
      getPages: [GetPage(name: '/login', page: () => const LoginScreen())],
    );
  }
}