import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_go/Auth/Forgot_password.dart';
import 'package:food_go/Auth/Sign_Up_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool remember = false;
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffff8995), Color(0xffff172d)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                /// Logo
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
                      const Text("Email"),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
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

                      const Text("Password"),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
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

                      Row(
                        children: [
                          Checkbox(
                            value: remember,
                            onChanged: (value) {
                              setState(() {
                                remember = value!;
                              });
                            },
                          ),

                          const Text("Remember me"),

                          const Spacer(),

                          TextButton(
                            onPressed: () {
                              Get.to(()=>ForgotPassword());
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

                      Center(
                        child: SizedBox(
                          width:MediaQuery.of(context).size.width * 0.7, 
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightPink,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                            Get.to(() =>  BottomNavbar());
                            },
                            child: const Text(
                              "Log In",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),

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
                          Container(
                            padding: const EdgeInsets.all(
                              6,
                            ), // Border thickness
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
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),
                          Container(
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
                              backgroundImage: AssetImage(ImagePath.applelogo),
                              backgroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),
                          Container(
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
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.center,
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
                                color: AppColors.darkpink,
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
                      // RichText(
                      //   text: TextSpan(
                      //     style: const TextStyle(
                      //       fontSize: 16,
                      //       color: Colors.black,
                      //     ),
                      //     children: [
                      //       const TextSpan(text: "Don't have an account? "),
                      //       TextSpan(
                      //         text: "Sign Up",
                      //         style: const TextStyle(
                      //           color: Colors.orange,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //         recognizer: TapGestureRecognizer()
                      //           ..onTap = () {
                      //             Get.to(() => const SignUpScreen());
                      //           },
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const Text("Don't have an account? "),

                      //     GestureDetector(
                      //       onTap: () {
                      //         Get.to(() => SignUpScreen()); // Navigate to Signup Screen
                      //         // Navigate to Signup Screen
                      //       },
                      //       child: const Text(
                      //         "Sign Up",
                      //         style: TextStyle(fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
