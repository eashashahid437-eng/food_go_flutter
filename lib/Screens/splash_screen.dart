import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';

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
      // Firebase check karega ke user already login hai ya nahi
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User already logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>  BottomNavbar(),
          ),
        );
      } else {
        // User login nahi hai
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
    // MediaQuery utility se screen width & height nikalna
    final double screenWidth =
        MediaQueryu.getScreenWidth(context);

    final double screenHeight =
        MediaQueryu.getScreenHeight(context);

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





// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:food_go/Auth/Login_Screen.dart';
// import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
// import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/utility/responsive.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();

//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const LoginScreen(),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // MediaQueryu utility se screen width & height nikalna
//     final double screenWidth = MediaQueryu.getScreenWidth(context);
//     final double screenHeight = MediaQueryu.getScreenHeight(context);

//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xffff8995),
//               Color(0xffff172d),
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Foodgo Logo
//             const Center(
//               child: Text(
//                 "Foodgo",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),

//             // Left Bottom Side Par Dono Burgers (Fully Attached to Edge)
//             Positioned(
//               bottom: -10,
//               left: -35, // Is se burger screen ke bilkul left corner se chipak jayega
//               child: SizedBox(
//                 width: screenWidth * 0.82,
//                 height: screenHeight * 0.25,
//                 child: Stack(
//                   alignment: Alignment.bottomLeft,
//                   children: [
//                     // Bada Burger
//                     Positioned(
//                       left: 0,
//                       bottom: 0,
//                       child: Image.asset(
//                         "assets/images/Burger 1.png",
//                         width: screenWidth * 0.56,
//                         height: screenHeight * 0.23,
//                         fit: BoxFit.contain,
//                       ),
//                     ),

//                     // Chota Burger (Bade Burger ke sath bilkul jura hua)
//                     Positioned(
//                       left: screenWidth * 0.33, // Responsive spacing
//                       bottom: 0,
//                       child: Image.asset(
//                         "assets/images/Burger 2.png",
//                         width: screenWidth * 0.41,
//                         height: screenHeight * 0.16,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
