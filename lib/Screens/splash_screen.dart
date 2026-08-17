import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  BottomNavbar(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.grey[900]!, Colors.black]
                : const [
                    Color(0xffff8995),
                    AppColors.darkpink,
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Foodgo Logo
            const Center(
              child: Text(
                "Foodgo",
                style: TextStyle(
                  color: AppColors.lightwhite,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // Left Bottom Side Par Dono Burgers
            Positioned(
              bottom: -10,
              left: -35,
              child: SizedBox(
                width: screenWidth * 0.82,
                height: screenHeight * 0.25,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // Bada Burger
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.asset(
                        "assets/images/Burger 1.png",
                        width: screenWidth * 0.56,
                        height: screenHeight * 0.23,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Chota Burger
                    Positioned(
                      left: screenWidth * 0.33,
                      bottom: 0,
                      child: Image.asset(
                        "assets/images/Burger 2.png",
                        width: screenWidth * 0.41,
                        height: screenHeight * 0.16,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
