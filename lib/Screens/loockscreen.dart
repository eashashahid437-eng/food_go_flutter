import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';

class StylishFingerprintScreen extends StatefulWidget {
  const StylishFingerprintScreen({super.key});

  @override
  State<StylishFingerprintScreen> createState() =>
      _StylishFingerprintScreenState();
}

class _StylishFingerprintScreenState extends State<StylishFingerprintScreen>
    with TickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  // Custom PIN Variables
  String enteredPin = "";
  String savedPin = "1234";
  bool isError = false;
  bool isLoadingPin = true;

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initializeSecurity();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeSecurity() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['customPin'] != null) {
            savedPin = data['customPin'].toString();
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading PIN from Firebase: $e");
    }

    if (mounted) {
      setState(() {
        isLoadingPin = false;
      });
    }

    _authenticateWithFingerprint();
  }

  Future<void> _authenticateWithFingerprint() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    HapticFeedback.mediumImpact();

    bool authenticated = false;
    try {
      authenticated = await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to unlock FoodGo',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint("Authentication Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }

    if (authenticated) {
      HapticFeedback.heavyImpact();
      Get.offAll(() => BottomNavbar());
    }
  }

  void _onNumberPressed(String number) {
    if (enteredPin.length < 4) {
      setState(() {
        enteredPin += number;
        isError = false;
      });

      HapticFeedback.lightImpact();

      if (enteredPin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (enteredPin.isNotEmpty) {
      setState(() {
        enteredPin = enteredPin.substring(0, enteredPin.length - 1);
        isError = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _verifyPin() {
    if (enteredPin == savedPin) {
      HapticFeedback.mediumImpact();
      Get.offAll(() => BottomNavbar());
    } else {
      HapticFeedback.vibrate();
      setState(() {
        isError = true;
        enteredPin = "";
      });
      Get.snackbar(
        "Incorrect PIN",
        "The 4-digit PIN you entered is wrong.",
        backgroundColor: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        colorText: Get.isDarkMode ? AppColors.lightwhite : Colors.black,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(15),
      );
    }
  }

  Future<void> _forgotPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      Get.snackbar(
        "Error",
        "No email found for this user.",
        backgroundColor: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        colorText: Get.isDarkMode ? AppColors.lightwhite : Colors.black,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      Get.snackbar(
        "Reset Link Sent",
        "A password/PIN reset link has been sent to ${user.email}",
        backgroundColor: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        colorText: Get.isDarkMode ? AppColors.lightwhite : Colors.black,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send reset email: $e",
        backgroundColor: Get.isDarkMode ? AppColors.surfaceDark : Colors.white,
        colorText: Get.isDarkMode ? AppColors.lightwhite : Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    if (isLoadingPin) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.darkpink),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Top Security Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkpink.withOpacity(0.12),
                    border: Border.all(
                      color: AppColors.darkpink.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    size: 28,
                    color: AppColors.darkpink,
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  "FoodGo Security",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 5),

                Text(
                  "Use your fingerprint or enter your 4-digit PIN",
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),

                // Fingerprint Scanner Section
                Center(
                  child: GestureDetector(
                    onTap: _authenticateWithFingerprint,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SizedBox(
                        width: 110,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(110, 110),
                              painter: ScannerCornersPainter(
                                color: AppColors.darkpink,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.darkpink.withOpacity(0.15),
                              ),
                              child: const Icon(
                                Icons.fingerprint_rounded,
                                size: 50,
                                color: AppColors.darkpink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  _isAuthenticating ? "Scanning..." : "Tap fingerprint to unlock",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkpink,
                  ),
                ),
                const SizedBox(height: 15),

                // PIN Dots Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    bool isFilled = index < enteredPin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? AppColors.darkpink : Colors.transparent,
                        border: Border.all(
                          color: isError ? Colors.red : AppColors.darkpink,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Forgot PIN
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: _forgotPin,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "Forgot PIN?",
                      style: TextStyle(
                        color: AppColors.darkpink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Keypad
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("1"),
                          _buildKey("2"),
                          _buildKey("3"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("4"),
                          _buildKey("5"),
                          _buildKey("6"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildKey("7"),
                          _buildKey("8"),
                          _buildKey("9"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(width: 60, height: 60),
                          _buildKey("0"),
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: IconButton(
                              onPressed: _onDeletePressed,
                              icon: Icon(
                                Icons.backspace_outlined,
                                size: 24,
                                color: isDark
                                    ? AppColors.lightwhite
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKey(String number) {
    final bool isDark = Get.isDarkMode;
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.surfaceDark
              : Colors.grey.shade200,
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}

class ScannerCornersPainter extends CustomPainter {
  final Color color;
  ScannerCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 25.0;
    const double radius = 8.0;

    // Top-Left Corner
    final pathTopLeft = Path()
      ..moveTo(0, length)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(length, 0);
    canvas.drawPath(pathTopLeft, paint);

    // Top-Right Corner
    final pathTopRight = Path()
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, length);
    canvas.drawPath(pathTopRight, paint);

    // Bottom-Left Corner
    final pathBottomLeft = Path()
      ..moveTo(0, size.height - length)
      ..lineTo(0, size.height - radius)
      ..quadraticBezierTo(0, size.height, radius, size.height)
      ..lineTo(length, size.height);
    canvas.drawPath(pathBottomLeft, paint);

    // Bottom-Right Corner
    final pathBottomRight = Path()
      ..moveTo(size.width - length, size.height)
      ..lineTo(size.width - radius, size.height)
      ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
      ..lineTo(size.width, size.height - length);
    canvas.drawPath(pathBottomRight, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get/get.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';

// class StylishFingerprintScreen extends StatefulWidget {
//   const StylishFingerprintScreen({super.key});

//   @override
//   State<StylishFingerprintScreen> createState() => _StylishFingerprintScreenState();
// }

// class _StylishFingerprintScreenState extends State<StylishFingerprintScreen>
//     with TickerProviderStateMixin {
//   final LocalAuthentication _auth = LocalAuthentication();
//   bool _isAuthenticating = false;

//   // Custom PIN Variables
//   String enteredPin = "";
//   String savedPin = "1234"; // Default PIN agar Firebase se na mile
//   bool isError = false;
//   bool isLoadingPin = true;

//   // Animations
//   late AnimationController _pulseController;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Pulse animation for scanner / fingerprint
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     )..repeat(reverse: true);

//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );

//     // Load User PIN from Firebase & Auto-trigger Fingerprint
//     _initializeSecurity();
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }

//   Future<void> _initializeSecurity() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//         if (doc.exists && doc.data() != null) {
//           final data = doc.data() as Map<String, dynamic>;
//           // Firebase se real customPin fetch karna
//           if (data['customPin'] != null) {
//             savedPin = data['customPin'].toString();
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Error loading PIN from Firebase: $e");
//     }

//     if (mounted) {
//       setState(() {
//         isLoadingPin = false;
//       });
//     }

//     // Auto trigger fingerprint on screen load
//     _authenticateWithFingerprint();
//   }

//   Future<void> _authenticateWithFingerprint() async {
//     if (_isAuthenticating) return;

//     setState(() {
//       _isAuthenticating = true;
//     });

//     HapticFeedback.mediumImpact();

//     bool authenticated = false;
//     try {
//       authenticated = await _auth.authenticate(
//         localizedReason: 'Scan your fingerprint to unlock FoodGo',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//           useErrorDialogs: true,
//         ),
//       );
//     } catch (e) {
//       debugPrint("Authentication Error: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAuthenticating = false;
//         });
//       }
//     }

//     if (authenticated) {
//       HapticFeedback.heavyImpact();
//       Get.offAll(() => BottomNavbar());
//     }
//   }

//   // Keypad number press logic
//   void _onNumberPressed(String number) {
//     if (enteredPin.length < 4) {
//       setState(() {
//         enteredPin += number;
//         isError = false;
//       });

//       HapticFeedback.lightImpact();

//       if (enteredPin.length == 4) {
//         _verifyPin();
//       }
//     }
//   }

//   // Backspace logic
//   void _onDeletePressed() {
//     if (enteredPin.isNotEmpty) {
//       setState(() {
//         enteredPin = enteredPin.substring(0, enteredPin.length - 1);
//         isError = false;
//       });
//       HapticFeedback.lightImpact();
//     }
//   }

//   // Verify Custom PIN against Firebase saved PIN
//   void _verifyPin() {
//     if (enteredPin == savedPin) {
//       HapticFeedback.mediumImpact();
//       Get.offAll(() => BottomNavbar());
//     } else {
//       HapticFeedback.vibrate();
//       setState(() {
//         isError = true;
//         enteredPin = "";
//       });
//       Get.snackbar(
//         "Incorrect PIN",
//         "The 4-digit PIN you entered is wrong.",
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//         margin: const EdgeInsets.all(15),
//       );
//     }
//   }

//   // Forgot PIN Function via Firebase Email
//   Future<void> _forgotPin() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null || user.email == null) {
//       Get.snackbar(
//         "Error",
//         "No email found for this user.",
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//       );
//       return;
//     }

//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
//       Get.snackbar(
//         "Reset Link Sent",
//         "A password/PIN reset link has been sent to ${user.email}",
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//         snackPosition: SnackPosition.TOP,
//         duration: const Duration(seconds: 4),
//       );
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Failed to send reset email: $e",
//         backgroundColor: Colors.white,
//         colorText: Colors.black,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Get.isDarkMode;

//     if (isLoadingPin) {
//       return Scaffold(
//         backgroundColor: isDark ? AppColors.backgroundDark : AppColors.lightwhite,
//         body: const Center(
//           child: CircularProgressIndicator(color: AppColors.Pink),
//         ),
//       );
//     }

//     return Scaffold(
//       backgroundColor: isDark ? AppColors.backgroundDark : AppColors.lightwhite,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 // Top Security Icon & App Name
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: AppColors.Pink.withOpacity(0.1),
//                     border: Border.all(
//                       color: AppColors.Pink.withOpacity(0.3),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.lock_rounded,
//                     size: 28,
//                     color: AppColors.Pink,
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//                 Text(
//                   "FoodGo Security",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? AppColors.lightwhite : Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   "Use your fingerprint or enter your 4-digit PIN",
//                   style: TextStyle(
//                     fontSize: 13,
//                     color: isDark ? Colors.white60 : Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // === STYLISH IN-DISPLAY FINGERPRINT SCANNER ANIMATION ===
//                 Center(
//                   child: GestureDetector(
//                     onTap: _authenticateWithFingerprint,
//                     child: ScaleTransition(
//                       scale: _scaleAnimation,
//                       child: SizedBox(
//                         width: 110,
//                         height: 110,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             CustomPaint(
//                               size: const Size(110, 110),
//                               painter: ScannerCornersPainter(
//                                 color: AppColors.Pink,
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: AppColors.Pink.withOpacity(0.15),
//                               ),
//                               child: const Icon(
//                                 Icons.fingerprint_rounded,
//                                 size: 50,
//                                 color: AppColors.Pink,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   _isAuthenticating ? "Scanning..." : "Tap fingerprint to unlock",
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.Pink,
//                   ),
//                 ),
//                 const SizedBox(height: 15),

//                 // PIN Dots Indicator (Animated)
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: List.generate(4, (index) {
//                     bool isFilled = index < enteredPin.length;
//                     return AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       margin: const EdgeInsets.symmetric(horizontal: 8),
//                       width: 14,
//                       height: 14,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: isFilled ? AppColors.Pink : Colors.transparent,
//                         border: Border.all(
//                           color: isError ? Colors.red : AppColors.Pink,
//                           width: 2,
//                         ),
//                       ),
//                     );
//                   }),
//                 ),
//                 const SizedBox(height: 10),

//                 // Simple Text Clickable for Forgot PIN
//                 Align(
//                   alignment: Alignment.center,
//                   child: TextButton(
//                     onPressed: _forgotPin,
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: const Size(50, 30),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text(
//                       "Forgot PIN?",
//                       style: TextStyle(
//                         color: AppColors.Pink,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),

//                 // Custom Keypad (1 to 9, 0, Backspace)
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _buildKey("1"),
//                           _buildKey("2"),
//                           _buildKey("3"),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _buildKey("4"),
//                           _buildKey("5"),
//                           _buildKey("6"),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _buildKey("7"),
//                           _buildKey("8"),
//                           _buildKey("9"),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           const SizedBox(width: 60, height: 60),
//                           _buildKey("0"),
//                           IconButton(
//                             onPressed: _onDeletePressed,
//                             icon: Icon(
//                               Icons.backspace_outlined,
//                               size: 26,
//                               color: isDark ? Colors.white70 : Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 15),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildKey(String number) {
//     final bool isDark = Get.isDarkMode;
//     return InkWell(
//       onTap: () => _onNumberPressed(number),
//       borderRadius: BorderRadius.circular(30),
//       child: Container(
//         width: 60,
//         height: 60,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
//         ),
//         child: Text(
//           number,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: isDark ? AppColors.lightwhite : Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // === Scanner Corners Bracket Painter Class ===
// class ScannerCornersPainter extends CustomPainter {
//   final Color color;
//   ScannerCornersPainter({required this.color});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 3.5
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     const double length = 25.0;
//     const double radius = 8.0;

//     // Top-Left Corner
//     final pathTopLeft = Path()
//       ..moveTo(0, length)
//       ..lineTo(0, radius)
//       ..quadraticBezierTo(0, 0, radius, 0)
//       ..lineTo(length, 0);
//     canvas.drawPath(pathTopLeft, paint);

//     // Top-Right Corner
//     final pathTopRight = Path()
//       ..moveTo(size.width - length, 0)
//       ..lineTo(size.width - radius, 0)
//       ..quadraticBezierTo(size.width, 0, size.width, radius)
//       ..lineTo(size.width, length);
//     canvas.drawPath(pathTopRight, paint);

//     // Bottom-Left Corner
//     final pathBottomLeft = Path()
//       ..moveTo(0, size.height - length)
//       ..lineTo(0, size.height - radius)
//       ..quadraticBezierTo(0, size.height, radius, size.height)
//       ..lineTo(length, size.height);
//     canvas.drawPath(pathBottomLeft, paint);

//     // Bottom-Right Corner
//     final pathBottomRight = Path()
//       ..moveTo(size.width - length, size.height)
//       ..lineTo(size.width - radius, size.height)
//       ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
//       ..lineTo(size.width, size.height - length);
//     canvas.drawPath(pathBottomRight, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
