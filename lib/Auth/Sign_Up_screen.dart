import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/app_fonts.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/BottomNavbar/BottomNavbar.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool remember = false;
  bool obscure = true;
  bool isLoading = false;

  Future<void> signInWithGoogle() async {
    try {
      setState(() {
        isLoading = true;
      });

      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        User? user = userCredential.user;

        if (user != null) {
          // Firestore mein check karein ke doc already exist karta hai ya nahi
          final userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            // Agar new user hai to sara profile data save kar dein
            await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
              "uid": user.uid,
              "name": user.displayName ?? "",
              "email": user.email ?? "",
              "phone": user.phoneNumber ?? "",
              "photoUrl": user.photoURL ?? "",
              "authProvider": "google",
              "createdAt": FieldValue.serverTimestamp(),
            });
          }

          print("Google Login Successful: ${user.email}");
          Get.off(() => BottomNavbar());
        }
      }
    } catch (e) {
      print("Google Login Error: $e");

      Get.snackbar(
        "Google Login Failed",
        "An error occurred. Please try again.",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      setState(() {
        isLoading = true;
      });

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

        User? user = userCredential.user;

        if (user != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
              "uid": user.uid,
              "name": user.displayName ?? "",
              "email": user.email ?? "",
              "phone": user.phoneNumber ?? "",
              "photoUrl": user.photoURL ?? "",
              "authProvider": "facebook",
              "createdAt": FieldValue.serverTimestamp(),
            });
          }

          print("Facebook Login Successful: ${user.email}");
          Get.off(() => BottomNavbar());
        }
      } else if (result.status == LoginStatus.cancelled) {
        print("Facebook Login Cancelled");
      } else {
        print("Facebook Login Failed: ${result.message}");
      }
    } catch (e) {
      print("Facebook Login Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your full name",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email address",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (phone.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your phone number",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your password",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 8 characters",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 1 uppercase letter",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 1 lowercase letter",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (!remember) {
      Get.snackbar(
        "Terms Required",
        "Please agree to Terms & Conditions",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.sendEmailVerification();

        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "phone": phone,
          "photoUrl": "",
          "authProvider": "email",
          "createdAt": FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          "Account Created",
          "Verification email has been sent to $email",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black,
          duration: const Duration(seconds: 4),
        );

        Get.offAll(() => const LoginScreen());
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case "email-already-in-use":
          message = "This email is already registered.";
          break;
        case "invalid-email":
          message = "The email address is invalid.";
          break;
        case "weak-password":
          message = "The password is too weak.";
          break;
        case "network-request-failed":
          message = "Please check your internet connection.";
          break;
        case "operation-not-allowed":
          message = "Email/Password authentication is disabled.";
          break;
        default:
          message = e.message ?? "Something went wrong.";
      }

      Get.snackbar(
        "Sign Up Failed",
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.white,
        colorText: Colors.black,
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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    super.dispose();
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
                Image.asset("assets/images/auth burger login.png", height: 179),

                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Text(
                  "Sign Up",
                  style: AppFonts.lobster(
                    fontSize: 36,
                  ).copyWith(color: Colors.white),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                Text(
                  "Your world of living colors awaits",
                  style: AppFonts.poppinsMedium(
                    fontSize: 15,
                  ).copyWith(color: Colors.white70),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

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
                      fieldTitle("Full Name"),
                      fieldSpace(context),

                      TextField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppFonts.poppinsMedium(fontSize: 18),
                        decoration: inputDecoration(
                          hintText: "John Doe",
                          icon: Icons.person_outline,
                        ),
                      ),

                      fieldSpace(context),

                      fieldTitle("Email address"),
                      fieldSpace(context),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppFonts.poppinsMedium(fontSize: 18),
                        decoration: inputDecoration(
                          hintText: "john.doe@example.com",
                          icon: Icons.email_outlined,
                        ),
                      ),

                      fieldSpace(context),

                      fieldTitle("Phone Number"),
                      fieldSpace(context),

                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: AppFonts.poppinsMedium(fontSize: 18),
                        decoration: inputDecoration(
                          hintText: "+92 300 1234567",
                          icon: Icons.phone_outlined,
                        ),
                      ),

                      fieldSpace(context),

                      fieldTitle("Password"),
                      fieldSpace(context),

                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        style: AppFonts.poppinsMedium(fontSize: 18),
                        decoration: inputDecoration(
                          hintText: "••••••••",
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

                      const SizedBox(height: 10),

                      Text(
                        "At least 8 characters, 1 uppercase, 1 lowercase",
                        style: AppFonts.poppinsMedium(
                          fontSize: 12,
                        ).copyWith(color: Colors.grey),
                      ),

                      const SizedBox(height: 6),

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

                          Expanded(
                            child: Text(
                              "I agree to the Terms & Conditions and Privacy Policy",
                              style: AppFonts.poppinsMedium(fontSize: 12),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

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
                            onPressed: isLoading ? null : signUp,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Sign Up",
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
                          InkWell(
                            onTap: signInWithGoogle,
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
                                backgroundColor: Colors.white,
                                colorText: Colors.black,
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

                          InkWell(
                            onTap: signInWithFacebook,
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

                      const SizedBox(height: 20),

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppFonts.poppinsMedium(
                              fontSize: 12,
                            ).copyWith(color: Colors.grey),
                            children: [
                              const TextSpan(
                                text: "By signing up you agree to our ",
                              ),
                              TextSpan(
                                text: "Terms & Conditions",
                                style: AppFonts.poppinsMedium(fontSize: 12)
                                    .copyWith(
                                      color: AppColors.darkpink,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
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
