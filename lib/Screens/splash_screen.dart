import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';

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
          builder: (context) =>  BottomNavbar(),
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

            // Left Bottom Side Par Dono Burgers (Fully Attached to Edge)
            Positioned(
              bottom: -10,
              left: -35, // Is se burger screen ke bilkul left corner se chipak jayega
              child: SizedBox(
                width: 320,
                height: 200,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    // Bada Burger
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Image.network(
                        "https://res.cloudinary.com/eyncqf0n/image/upload/v1786102755/image_2_vormow.png",
                        width: 220,
                        height: 190,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Chota Burger (Bade Burger ke sath bilkul jura hua)
                    Positioned(
                      left: 130, // Isko thoda aur pass kar diya hai
                      bottom: 0,
                      child: Image.network(
                        "https://res.cloudinary.com/eyncqf0n/image/upload/f_auto,q_auto/image_1_ixnwqk",
                        width: 160,
                        height: 130,
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
