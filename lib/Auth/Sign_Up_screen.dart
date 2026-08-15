import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
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

        print("Google Login Successful");
        print("Name: ${userCredential.user?.displayName}");
        print("Email: ${userCredential.user?.email}");

        Get.off(() => BottomNavbar());
      }
    } catch (e) {
      print("Google Login Error: $e");
      Get.snackbar(
        "Google Login Failed",
        "An error occurred. Please try again.",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
    }
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
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }
    if (phone.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your phone number",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }
    if (password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your password",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 8 characters",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 1 uppercase letter",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 1 lowercase letter",
        backgroundColor: Colors.white,
        colorText: Colors.black,
      );
      return;
    }
    if (!remember) {
      Get.snackbar(
        "Terms Required",
        "Please agree to Terms & Conditions",
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
          "createdAt": FieldValue.serverTimestamp(),
        });

        Get.snackbar(
          "Account Created",
          "Verification email has been sent to $email",
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
        backgroundColor: Colors.white,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
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

                const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).size.height * 0.02),

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
                      const Text("Full Name"),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
                        controller: nameController,

                        textCapitalization: TextCapitalization.words,

                        decoration: InputDecoration(
                          hintText: "John Doe",
                          prefixIcon: const Icon(Icons.person),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      const Text("Email address"),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
                        controller: emailController,

                        keyboardType: TextInputType.emailAddress,

                        decoration: InputDecoration(
                          hintText: "john.doe@example.com",

                          prefixIcon: const Icon(Icons.email_outlined),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      const Text("Phone Number"),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
                        controller: phoneController,

                        keyboardType: TextInputType.phone,

                        decoration: InputDecoration(
                          hintText: "+92 300 1234567",

                          prefixIcon: const Icon(Icons.phone),

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
                        controller: passwordController,

                        obscureText: obscure,

                        decoration: InputDecoration(
                          hintText: "••••••••",

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

                      const Text(
                        "At least 8 characters, 1 uppercase, 1 lowercase",
                        style: TextStyle(color: Colors.grey),
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: remember,

                            activeColor: AppColors.Pink,

                            onChanged: (value) {
                              setState(() {
                                remember = value ?? false;
                              });
                            },
                          ),

                          const Expanded(
                            child: Text(
                              "I agree to the Terms & Conditions and Privacy Policy",
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
                            onPressed: isLoading
                                ? null
                                : () {
                                    signUp();
                                  },

                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Sign Up",
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

                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,

                      //   children: [
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

                      //         backgroundImage: AssetImage(ImagePath.twitter),

                      //         backgroundColor: Colors.white,
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

                      //         backgroundImage: AssetImage(ImagePath.Fb),

                      //         backgroundColor: Colors.white,
                      //       ),
                      //     ),
                      //   ],
                      // ),
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
                          const Text("By signing up you agree to our "),

                          GestureDetector(
                            onTap: () {},

                            child: const Text(
                              "Terms & Conditions",

                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkpink,
                              ),
                            ),
                          ),
                        ],
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
