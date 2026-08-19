import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:food_go/Auth/Forgot_password.dart';
import 'package:food_go/Auth/Sign_Up_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/app_fonts.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:get/get.dart';
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

        final UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );

        print("Facebook Login Successful");
        print("Name: ${userCredential.user?.displayName}");
        print("Email: ${userCredential.user?.email}");

        Get.offAll(() => BottomNavbar());
      } else if (result.status == LoginStatus.cancelled) {
        print("Facebook Login Cancelled");
      } else {
        print("Facebook Login Failed");
        print(result.message);
      }
    } catch (e) {
      print("Facebook Login Error: $e");

      Get.snackbar(
        "Facebook Login Failed",
        "Unable to login with Facebook.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      await auth.signInWithCredential(credential);

      Get.offAll(() => BottomNavbar());
    } catch (e) {
      print("Google Sign In Error: $e");

      Get.snackbar(
        "Error",
        "Google Sign-In failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loginUser() async {
    final String emailText = email.text.trim();
    final String passwordText = password.text.trim();

    if (emailText.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!GetUtils.isEmail(emailText)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (passwordText.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(
        email: emailText,
        password: passwordText,
      );

      Get.snackbar(
        "Success",
        "Login successful",
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.offAll(() => BottomNavbar());
    } on FirebaseAuthException catch (e) {
      String message = "Login failed";

      switch (e.code) {
        case "invalid-email":
          message = "Please enter a valid email address";
          break;

        case "user-not-found":
          message = "No account found with this email";
          break;

        case "wrong-password":
          message = "Incorrect password";
          break;

        case "invalid-credential":
          message = "Email or password is incorrect";
          break;

        case "user-disabled":
          message = "This account has been disabled";
          break;

        case "too-many-requests":
          message = "Too many attempts. Try again later";
          break;

        case "network-request-failed":
          message = "Please check your internet connection";
          break;

        default:
          message = e.message ?? "Login failed";
      }

      Get.snackbar("Error", message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again",
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

  InputDecoration inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppFonts.poppinsMedium(
        fontSize: 16,
      ).copyWith(color: Colors.grey),
      prefixIcon: Icon(icon, color: AppColors.Pink),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.Pink, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget fieldTitle(String title) {
    return Text(title, style: AppFonts.poppinsMedium(fontSize: 16));
  }

  Widget fieldSpace(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).size.height * 0.018);
  }

  Widget socialButton({required String image, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightgrey, width: 1.5),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage(image),
        ),
      ),
    );
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

                const SizedBox(height: 8),

                Text(
                  "Welcome Back!",
                  style: AppFonts.lobster(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ).copyWith(color: Colors.white),
                ),

                const SizedBox(height: 8),

                Text(
                  "Login to your account",
                  style: AppFonts.lobster(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ).copyWith(color: Colors.white),
                ),

                const SizedBox(height: 8),

                Text(
                  "Your world of living colors awaits",
                  style: AppFonts.poppinsMedium(
                    fontSize: 14,
                  ).copyWith(color: Colors.white70),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
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
                      fieldTitle("Email"),

                      fieldSpace(context),

                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        style: AppFonts.poppinsMedium(fontSize: 18),
                        decoration: inputDecoration(
                          hintText: "davidjonson@gmail.com",
                          icon: Icons.email_outlined,
                        ),
                      ),

                      fieldSpace(context),

                      fieldTitle("Password"),

                      fieldSpace(context),

                      TextField(
                        controller: password,
                        obscureText: obscure,
                        style: AppFonts.poppinsMedium(fontSize: 18),
                        decoration: inputDecoration(
                          hintText: "xxxxxxxx",
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.Pink,
                            ),
                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Checkbox(
                            value: remember,
                            activeColor: AppColors.Pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                remember = value ?? false;
                              });
                            },
                          ),

                          Text(
                            "Remember me",
                            style: AppFonts.poppinsMedium(fontSize: 13),
                          ),

                          const Spacer(),

                          TextButton(
                            onPressed: () {
                              Get.to(() => const ForgotPassword());
                            },
                            child: Text(
                              "Forgot Password?",
                              style: AppFonts.poppinsMedium(
                                fontSize: 13,
                              ).copyWith(color: AppColors.darkpink),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.Pink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading ? null : loginUser,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Log In",
                                    style: AppFonts.poppinsMedium(
                                      fontSize: 18,
                                    ).copyWith(color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "Log in with",
                              style: AppFonts.poppinsMedium(
                                fontSize: 14,
                              ).copyWith(color: Colors.grey),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          socialButton(
                            image: ImagePath.Google,
                            onTap: signInWithGoogle,
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),

                          socialButton(
                            image: ImagePath.applelogo,
                            onTap: () {
                              Get.snackbar(
                                "Apple Login",
                                "Apple login is currently unavailable.",
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),

                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                          ),

                          socialButton(
                            image: ImagePath.Fb,
                            onTap: signInWithFacebook,
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppFonts.poppinsMedium(
                              fontSize: 14,
                            ).copyWith(color: Colors.black),
                            children: [
                              const TextSpan(text: "Don't have an account? "),
                              TextSpan(
                                text: "Sign Up",
                                style: AppFonts.poppinsMedium(fontSize: 14)
                                    .copyWith(
                                      color: AppColors.Pink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Get.to(() => const SignUpScreen());
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
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
