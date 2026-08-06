import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/image_path.dart';
import 'home_screen.dart';

const String splashImage = 'assets/images/splash_image.png';
const String burger1 = 'assets/images/burger1.png';
const String burger2 = 'assets/images/burger2.png';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffff8995),
              Color(0xffff172d),
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
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // Bottom burger
            Positioned(
              bottom: -10,
              left: -20,
              child: Image.asset(
                ImagePath.burger1,
                width: 230,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),

            // Bottom right burger
            Positioned(
              bottom: -5,
              right: -25,
              child: Image.asset(
                ImagePath.burger2,
                width: 210,
                height: 170,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

}