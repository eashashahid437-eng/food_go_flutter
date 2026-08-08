import 'package:flutter/material.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Auth/SetResetCode.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
   bool remember = false;
  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
            // Agar GetX use kar rahi hain:
            // Get.back();
          },
        ),
        title: const Text(
          "Forgot Password",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Center(
              child: Text(
                "Enter Your Email Address to Reset Your password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: AppColors.lightgrey),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            const Text("Email address", textAlign: TextAlign.start),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            TextField(
              decoration: InputDecoration(
                hintText: "john.doe@example.com",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              const Text(" New Password"),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
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
                      const Text(" Confirm Password"),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),

                      TextField(
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
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),

                       Center(
                         child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.7,
                                               height: 45,
                          child: ElevatedButton(
                            
                            style: ElevatedButton.styleFrom(
                            
                              backgroundColor: AppColors.Pink,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Get.off(() => Setresetcode());
                            },
                            child: const Text(
                              "Set New Password",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                                               ),
                       ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.back(); // Previous screen (Login) par wapas
                            // Ya:
                            Get.off(() => const LoginScreen());
                          },
                          child: const Text(
                            "Return to Login",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkpink,
                            ),
                          ),
                        ),
                      )
          ],
        ),
      ),
    );
  }
}
