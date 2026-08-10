import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool remember = false;
  bool obscure = true;
  bool isLoading = false;

  // ================= SIGN UP FUNCTION =================

  Future<void> signUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();

    // Name validation
    if (name.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your full name",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Email validation
    if (email.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your email address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Error",
        "Please enter a valid email address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Phone validation
    if (phone.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your phone number",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Password validation
    if (password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter your password",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 8 characters",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Uppercase check
    if (!password.contains(RegExp(r'[A-Z]'))) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 1 uppercase letter",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Lowercase check
    if (!password.contains(RegExp(r'[a-z]'))) {
      Get.snackbar(
        "Weak Password",
        "Password must contain at least 1 lowercase letter",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Terms & Conditions
    if (!remember) {
      Get.snackbar(
        "Terms Required",
        "Please agree to Terms & Conditions",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Loading start
      setState(() {
        isLoading = true;
      });

      // ================= FIREBASE AUTH =================

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // ================= SAVE DISPLAY NAME =================

        await user.updateDisplayName(name);

        // ================= EMAIL VERIFICATION =================

        await user.sendEmailVerification();

        // ================= FIRESTORE =================

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .set({
          "uid": user.uid,
          "name": name,
          "email": email,
          "phone": phone,
          "createdAt": FieldValue.serverTimestamp(),
        });

        // ================= SUCCESS =================

        Get.snackbar(
          "Account Created",
          "Verification email has been sent to $email",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Login screen
        Get.offAll(
          () => const LoginScreen(),
        );
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
        backgroundColor: Colors.red,
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

  // ================= DISPOSE =================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 245, 80, 94),
              Color(0xffff172d),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                // ================= LOGO =================

                Image.asset(
                  "assets/images/Burger 3.png",
                  height: 120,
                ),

                SizedBox(
                  height:
                      MediaQuery.of(context).size.height * 0.01,
                ),

                const Text(
                  "Sign Up",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height:
                      MediaQuery.of(context).size.height * 0.02,
                ),

                const Text(
                  "Your world of living colors awaits",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                SizedBox(
                  height:
                      MediaQuery.of(context).size.height * 0.02,
                ),

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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      // ================= NAME =================

                      const Text("Full Name"),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      TextField(
                        controller: nameController,

                        textCapitalization:
                            TextCapitalization.words,

                        decoration: InputDecoration(
                          hintText: "John Doe",
                          prefixIcon:
                              const Icon(Icons.person),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      // ================= EMAIL =================

                      const Text("Email address"),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      TextField(
                        controller: emailController,

                        keyboardType:
                            TextInputType.emailAddress,

                        decoration: InputDecoration(
                          hintText:
                              "john.doe@example.com",

                          prefixIcon: const Icon(
                            Icons.email_outlined,
                          ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      // ================= PHONE =================

                      const Text("Phone Number"),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      TextField(
                        controller: phoneController,

                        keyboardType:
                            TextInputType.phone,

                        decoration: InputDecoration(
                          hintText: "+92 300 1234567",

                          prefixIcon: const Icon(
                            Icons.phone,
                          ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      // ================= PASSWORD =================

                      const Text("Password"),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      TextField(
                        controller: passwordController,

                        obscureText: obscure,

                        decoration: InputDecoration(
                          hintText: "••••••••",

                          prefixIcon: const Icon(
                            Icons.lock_outline,
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),

                            onPressed: () {
                              setState(() {
                                obscure = !obscure;
                              });
                            },
                          ),

                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      const Text(
                        "At least 8 characters, 1 uppercase, 1 lowercase",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),

                      // ================= TERMS =================

                      Row(
                        children: [

                          Checkbox(
                            value: remember,

                            activeColor:
                                AppColors.Pink,

                            onChanged: (value) {
                              setState(() {
                                remember =
                                    value ?? false;
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
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      // ================= SIGN UP BUTTON =================

                      Center(
                        child: SizedBox(
                          width:
                              MediaQuery.of(context).size.width *
                                  0.7,

                          height: 45,

                          child: ElevatedButton(

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.Pink,

                              foregroundColor:
                                  Colors.black,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),

                            // Prevent multiple clicks
                            onPressed: isLoading
                                ? null
                                : () {
                                    signUp();
                                  },

                            child: isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.03,
                      ),

                      // ================= LOGIN WITH =================

                      Row(
                        children: const [
                          Expanded(
                            child: Divider(),
                          ),

                          Padding(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Text(
                              "Log in with",
                            ),
                          ),

                          Expanded(
                            child: Divider(),
                          ),
                        ],
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      // ================= SOCIAL ICONS =================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Container(
                            padding:
                                const EdgeInsets.all(6),

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,

                              border: Border.all(
                                color:
                                    AppColors.lightgrey,
                                width: 2,
                              ),
                            ),

                            child: CircleAvatar(
                              radius: 20,

                              backgroundImage:
                                  AssetImage(
                                ImagePath.Google,
                              ),
                            ),
                          ),

                          SizedBox(
                            width:
                                MediaQuery.of(context)
                                        .size
                                        .width *
                                    0.05,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.all(6),

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,

                              border: Border.all(
                                color:
                                    AppColors.lightgrey,
                                width: 1.5,
                              ),
                            ),

                            child: CircleAvatar(
                              radius: 20,

                              backgroundImage:
                                  AssetImage(
                                ImagePath.applelogo,
                              ),

                              backgroundColor:
                                  Colors.white,
                            ),
                          ),

                          SizedBox(
                            width:
                                MediaQuery.of(context)
                                        .size
                                        .width *
                                    0.05,
                          ),

                          Container(
                            padding:
                                const EdgeInsets.all(6),

                            decoration:
                                BoxDecoration(
                              shape:
                                  BoxShape.circle,

                              border: Border.all(
                                color:
                                    AppColors.lightgrey,
                                width: 1.5,
                              ),
                            ),

                            child: CircleAvatar(
                              radius: 20,

                              backgroundImage:
                                  AssetImage(
                                ImagePath.twitter,
                              ),

                              backgroundColor:
                                  Colors.white,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height:
                            MediaQuery.of(context).size.height *
                                0.02,
                      ),

                      // ================= TERMS TEXT =================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          const Text(
                            "By signing up you agree to our ",
                          ),

                          GestureDetector(
                            onTap: () {},

                            child: const Text(
                              "Terms & Conditions",

                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    AppColors.darkpink,
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



// import 'package:flutter/material.dart';
// import 'package:food_go/Auth/Login_Screen.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Constants/image_path.dart';
// import 'package:get/get.dart';

// class SignUpScreen extends StatefulWidget {
//   const SignUpScreen({super.key});

//   @override
//   State<SignUpScreen> createState() => _SignUpScreenState();
// }

// class _SignUpScreenState extends State<SignUpScreen> {
//   bool remember = false;
//   bool obscure = true;

//   @override
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
//                 /// Logo
//                 Image.asset("assets/images/Burger 3.png", height: 120),

//                 SizedBox(height: MediaQuery.of(context).size.height * 0.01),

//                 const Text(
//                   "Sign Up",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 SizedBox(height: MediaQuery.of(context).size.height * 0.02),

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
//                       const Text("Full Name"),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: "John Doe",
//                           prefixIcon: const Icon(Icons.person),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       const Text("Email address"),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       TextField(
//                         decoration: InputDecoration(
//                           hintText: "john.doe@example.com",
//                           prefixIcon: const Icon(Icons.email_outlined),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       const Text("Phone Number"),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),
//                       TextField(
//                         obscureText: obscure,
//                         decoration: InputDecoration(
//                           hintText: "+92 300 1234567",
//                           prefixIcon: const Icon(Icons.phone),
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
//                       const Text("Password"),
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       TextField(
//                         obscureText: obscure,
//                         decoration: InputDecoration(
//                           hintText: "••••••••",
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
//                       Text(
                        
//                         "At least 8 characters, 1 uppercase, 1 lowercase",
//                         style: TextStyle(color: Colors.grey[600]),
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

//                           const Text(
//                             "I agree to the Terms & Conditions and Privacy Policy",
//                           ),
//                         ],
//                       ),

//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * 0.02,
//                       ),

//                       Center(
//                         child: SizedBox(
//                           width:MediaQuery.of(context).size.width * 0.7, 
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
//                               Get.to(() => const LoginScreen());
//                             },
//                             child: const Text(
//                               "Sign Up",
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
//                           const Text("By signing up you agree to our "),

//                           GestureDetector(
//                             onTap: () {
//                               // Navigate to Signup Screen
//                             },
//                             child: const Text(
//                               "Terms & Conditions",
//                               style: TextStyle(fontWeight: FontWeight.bold,
//                               color: AppColors.darkpink),
//                             ),
//                           ),
//                         ],
//                       ),

//                       // SizedBox(
//                       //   height: MediaQuery.of(context).size.height * 0.02,
//                       // ),
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
