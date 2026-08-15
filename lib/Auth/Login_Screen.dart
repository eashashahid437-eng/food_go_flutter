import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:food_go/Auth/Forgot_password.dart';
import 'package:food_go/Auth/Sign_Up_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;

        final OAuthCredential credential = FacebookAuthProvider.credential(
          accessToken.tokenString,
        );

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        print("Facebook Login Successful");
        print("Name: ${userCredential.user?.displayName}");
        print("Email: ${userCredential.user?.email}");

        Get.off(() => BottomNavbar());
      } else if (result.status == LoginStatus.cancelled) {
        print("Facebook Login Cancelled");
      } else {
        print("Facebook Login Failed");
        print(result.message);
      }
    } catch (e) {
      print("Facebook Login Error: $e");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await auth.signInWithCredential(credential);

      Get.offAll(() => BottomNavbar());
    } catch (e) {
      print("Google Sign In Error: $e");
      Get.snackbar("Error", "Google Sign-In failed");
    }
  }

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
                Image.asset("assets/images/auth burger login.png", height: 170),

                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Text(
                  "Welcome Back !",
                  style: GoogleFonts.lobster(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                Text(
                  "Login to your account",
                  style: GoogleFonts.lobster(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                const Text(
                  "Your world of living colors awaits",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                              Get.to(() => const ForgotPassword());
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
                      const Row(
                        children: [
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
                        children: [
                          InkWell(
                            onTap: signInWithGoogle,
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

                          InkWell(
                            onTap: () {
                              Get.snackbar(
                                "Apple Login",
                                "Apple login is currently unavailable.",
                              );
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

                                backgroundImage: AssetImage(ImagePath.applelogo),

                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),
                          InkWell(
                            onTap: () {
                              signInWithFacebook();
                              Get.snackbar(
                                "Facebook Login",
                                "Facebook login is not configured yet.",
                              );
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
                                backgroundImage: AssetImage(ImagePath.Fb),
                                backgroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

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
