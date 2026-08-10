import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_go/Auth/Forgot_password.dart';
import 'package:food_go/Auth/Sign_Up_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:food_go/Screens/BottomNavbar/home_screen.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  bool remember = false;
  bool obscure = true;
  bool isLoading = false;

  Future<void> loginUser() async {
    if (email.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      Get.snackbar(
        'Success',
        'Login successful',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Login successful -> Home
      Get.offAll(() => BottomNavbar());
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';

      switch (e.code) {
        case 'invalid-email':
          message = 'Please enter a valid email address';
          break;

        case 'user-not-found':
          message = 'No account found with this email';
          break;

        case 'wrong-password':
          message = 'Incorrect password';
          break;

        case 'invalid-credential':
          message = 'Email or password is incorrect';
          break;

        case 'user-disabled':
          message = 'This account has been disabled';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Try again later';
          break;

        case 'network-request-failed':
          message = 'Please check your internet connection';
          break;

        default:
          message = e.message ?? 'Login failed';
      }

      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithGoogle() async {
    throw UnimplementedError('Google sign-in is not implemented.');
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 245, 80, 94), Color(0xffff172d)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                // ================= LOGO =================
                Image.asset("assets/images/Burger 3.png", height: 120),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                const Text(
                  "Welcome Back !",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                const Text(
                  "Login to your account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                const Text(
                  "Your world of living colors awaits",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                // ================= WHITE CONTAINER =================
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(22),

                  decoration: const BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= EMAIL =================
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,

                        decoration: InputDecoration(
                          hintText: "davidjonson@gmail.com",

                          prefixIcon: const Icon(Icons.email_outlined),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      // ================= PASSWORD =================
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
                        controller: password,
                        obscureText: obscure,

                        decoration: InputDecoration(
                          hintText: "xxxxxxxx",

                          prefixIcon: const Icon(Icons.lock_outline),

                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                            ),

                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      // ================= REMEMBER + FORGOT =================
                      Row(
                        children: [
                          Checkbox(
                            value: remember,

                            onChanged: (value) {
                              setState(() {
                                remember = value ?? false;
                              });
                            },
                          ),

                          const Text("Remember me"),

                          const Spacer(),

                          TextButton(
                            onPressed: () {
                              Get.to(() => ForgotPassword());
                            },

                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      // ================= LOGIN BUTTON =================
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,

                          height: 45,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.Pink,
                              foregroundColor: Colors.black,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            onPressed: isLoading ? null : loginUser,

                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,

                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    "Log In",
                                    style: TextStyle(fontSize: 20),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),

                      // ================= OR =================
                      Row(
                        children: const [
                          Expanded(child: Divider()),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),

                            child: Text("Log in with"),
                          ),

                          Expanded(child: Divider()),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          
                          InkWell(
                            onTap: () async {
                              try {
                  await signInWithGoogle();
                  Get.offAll(() => HomeScreen());
                } catch (e) { 
                  Get.snackbar("Error", e.toString());
                }
                    
                              print("Google button clicked");
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.lightgrey,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(ImagePath.Google),
                              ),
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),

                          // APPLE BUTTON
                          InkWell(
                            onTap: () {
                              print("Apple button clicked");
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.lightgrey,
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                  ImagePath.applelogo,
                                ),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),

                          // TWITTER BUTTON
                          InkWell(
                            onTap: () {
                              print("Twitter button clicked");
                            },
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.lightgrey,
                                  width: 1.5,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(ImagePath.twitter),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,

                      //   crossAxisAlignment: CrossAxisAlignment.center,

                      //   children: [
                      //     // GOOGLE
                      //     Container(
                      //       padding: const EdgeInsets.all(6),

                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,

                      //         border: Border.all(
                      //           color: AppColors.lightgrey,
                      //           width: 2,
                      //         ),
                      //       ),

                      //       child: CircleAvatar(
                      //         radius: 20,

                      //         backgroundImage: AssetImage(ImagePath.Google),
                      //       ),
                      //     ),

                      //     SizedBox(
                      //       width: MediaQuery.of(context).size.width * 0.05,
                      //     ),

                      //     Container(
                      //       padding: const EdgeInsets.all(6),

                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,

                      //         border: Border.all(
                      //           color: AppColors.lightgrey,
                      //           width: 1.5,
                      //         ),
                      //       ),

                      //       child: CircleAvatar(
                      //         radius: 20,

                      //         backgroundImage: AssetImage(ImagePath.applelogo),

                      //         backgroundColor: Colors.white,
                      //       ),
                      //     ),

                      //     SizedBox(
                      //       width: MediaQuery.of(context).size.width * 0.05,
                      //     ),

                      //     // TWITTER
                      //     Container(
                      //       padding: const EdgeInsets.all(6),

                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,

                      //         border: Border.all(
                      //           color: AppColors.lightgrey,
                      //           width: 1.5,
                      //         ),
                      //       ),

                      //       child: CircleAvatar(
                      //         radius: 20,

                      //         backgroundImage: AssetImage(ImagePath.twitter),

                      //         backgroundColor: Colors.white,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),

                              children: [
                                const TextSpan(text: "Don't have an account? "),

                                TextSpan(
                                  text: "Sign Up",

                                  style: const TextStyle(
                                    color: AppColors.Pink,
                                    fontWeight: FontWeight.bold,
                                  ),

                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => const SignUpScreen());
                                    },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:food_go/Auth/Forgot_password.dart';
// import 'package:food_go/Auth/Sign_Up_screen.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Constants/image_path.dart';
// import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
// import 'package:food_go/Screens/BottomNavbar/home_screen.dart';
// import 'package:food_go/utility/responsive.dart';
// import 'package:get/get.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool remember = false;
//   bool obscure = true;

//   @override
//   FirebaseAuth auth = FirebaseAuth.instance;
//   TextEditingController email = TextEditingController();
//   TextEditingController password = TextEditingController();
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color.fromARGB(255, 245, 80, 94), Color(0xffff172d)],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.03),

//                 /// Logo
//                 Image.asset("assets/images/Burger 3.png", height: 120),

//                 SizedBox(height: MediaQuery.of(context).size.height * 0.03),

//                 const Text(
//                   "Welcome Back !",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).size.height * 0.03),
//                 const Text(
//                   "Login to your account",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 SizedBox(height: MediaQuery.of(context).size.height * 0.03),

//                 const Text(
//                   "Your world of living colors awaits",
//                   style: TextStyle(color: Colors.white70, fontSize: 15),
//                 ),

//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),

//                 Container(
//                   width: MediaQuery.of(context).size.width,
//                   padding: const EdgeInsets.all(22),
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(40),
//                       topRight: Radius.circular(40),
//                     ),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Email"),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       TextField(
//                         controller: email,
//                         decoration: InputDecoration(
//                           hintText: "davidjonson@gmail.com",
//                           prefixIcon: const Icon(Icons.email_outlined),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       const Text("Password"),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       TextField(
//                         obscureText: obscure,
//                         controller: password,
//                         decoration: InputDecoration(
                        
//                           hintText: "xxxxxxxx",
//                           prefixIcon: const Icon(Icons.lock_outline),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               obscure ? Icons.visibility_off : Icons.visibility,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 obscure = !obscure;
//                               });
//                             },
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       Row(
//                         children: [
//                           Checkbox(
//                             value: remember,
//                             onChanged: (value) {
//                               setState(() {
//                                 remember = value!;
//                               });
//                             },
//                           ),

//                           const Text("Remember me"),

//                           const Spacer(),

//                           TextButton(
//                             onPressed: () {
//                               Get.to(() => ForgotPassword());
//                             },
//                             child: const Text(
//                               "Forgot Password?",
//                               style: TextStyle(color: Colors.red),
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       Center(
//                         child: SizedBox(
//                           width: MediaQuery.of(context).size.width * 0.7,
//                           height: 45,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppColors.Pink,
//                               foregroundColor: Colors.black,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             onPressed: () {
//                                auth.createUserWithEmailAndPassword(
//                   email: email.text,
//                   password: password.text,).then((userCredential) {
//                     Get.snackbar('Success', 'User registered successfully');
//                     Get.to(HomeScreen());
//                  }).onError((error, stackTrace) {
//                     Get.snackbar('Error', error.toString());
//                  });
//                               Get.to(() => BottomNavbar());
//                             },
//                             child: const Text(
//                               "Log In",
//                               style: TextStyle(fontSize: 20),
//                             ),
//                           ),
//                         ),
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.03,
//                       ),

//                       Row(
//                         children: const [
//                           Expanded(child: Divider()),
//                           Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 10),
//                             child: Text("Log in with"),
//                           ),
//                           Expanded(child: Divider()),
//                         ],
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(
//                               6,
//                             ), // Border thickness
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: AppColors.lightgrey,
//                                 width: 2,
//                               ),
//                             ),
//                             child: CircleAvatar(
//                               radius: 20,
//                               backgroundImage: AssetImage(ImagePath.Google),
//                             ),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.05,
//                           ),
//                           Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: AppColors.lightgrey,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: CircleAvatar(
//                               radius: 20,
//                               backgroundImage: AssetImage(ImagePath.applelogo),
//                               backgroundColor: Colors.white,
//                             ),
//                           ),
//                           SizedBox(
//                             width: MediaQuery.of(context).size.width * 0.05,
//                           ),
//                           Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: AppColors.lightgrey,
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: CircleAvatar(
//                               radius: 20,
//                               backgroundImage: AssetImage(ImagePath.twitter),
//                               backgroundColor: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           RichText(
//                             text: TextSpan(
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                               ),
//                               children: [
//                                 const TextSpan(text: "Don't have an account? "),
//                                 TextSpan(
//                                   text: "Sign Up",
//                                   style: const TextStyle(
//                                     color: AppColors.Pink,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   recognizer: TapGestureRecognizer()
//                                     ..onTap = () {
//                                       Get.to(() => const SignUpScreen());
//                                     },
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
                    
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
