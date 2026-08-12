import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:google_fonts/google_fonts.dart';

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
          MaterialPageRoute(builder: (context) => BottomNavbar()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery utility se screen width & height nikalna
    final double screenWidth = MediaQueryu.getScreenWidth(context);

    final double screenHeight = MediaQueryu.getScreenHeight(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffff8995), Color(0xffff172d)],
          ),
        ),

        child: Stack(
          children: [
            // Foodgo Logo
            Center(
              child: Text(
                "Foodgo",
                style: GoogleFonts.lobster(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            Positioned(
              bottom: -10,
              left: -35,

              child: SizedBox(
                width: screenWidth * 0.82,
                height: screenHeight * 0.25,

                child: Stack(
                  alignment: Alignment.bottomLeft,

                  children: [
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
