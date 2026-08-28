import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_go/Auth/login_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Constants/app_fonts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    final String email = emailController.text.trim();

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

    setState(() {
      isLoading = true;
    });

    try {
      // ---- Humara custom backend call kar rahe hain (Gmail SMTP se email bhejta hai) ----
      final response = await http.post(
        Uri.parse(
          'https://food-delivery-backend-ivory.vercel.app/api/send-reset-email',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return;

      if (response.statusCode == 200) {
        Get.snackbar(
          "Email Sent",
          data['message'] ??
              "Password reset link has been sent to your email.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.white,
          colorText: Colors.black,
          duration: const Duration(seconds: 3),
        );

        Get.offAll(() => const LoginScreen());
      } else {
        Get.snackbar(
          "Error",
          data['error'] ?? "Something went wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black,
        );
      }
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        "Error",
        "Network error. Please check your internet connection.",
        snackPosition: SnackPosition.BOTTOM,
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

  InputDecoration emailDecoration() {
    return InputDecoration(
      hintText: "john.doe@example.com",
      hintStyle: AppFonts.poppinsMedium(
        fontSize: 15,
      ).copyWith(color: Colors.grey.shade400),
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.Pink.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.email_outlined, color: AppColors.Pink),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.Pink, width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: size.height * 0.38,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 245, 80, 94),
                      Color(0xffff172d),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(45),
                    bottomRight: Radius.circular(45),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      top: 25,
                      right: -35,
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: -15,
                      left: -35,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 95,
                            width: 95,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 55,
                              color: AppColors.Pink,
                            ),
                          ),

                          const SizedBox(height: 18),

                          Text(
                            "Forgot Password?",
                            style: AppFonts.lobster(
                              fontSize: 34,
                            ).copyWith(color: Colors.white),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Don't worry, we've got you!",
                            style: AppFonts.poppinsMedium(
                              fontSize: 14,
                            ).copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Reset your password",
                        style: AppFonts.poppinsMedium(
                          fontSize: 22,
                        ).copyWith(color: Colors.black87),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        "Enter the email address associated\nwith your account.",
                        textAlign: TextAlign.center,
                        style: AppFonts.poppinsMedium(
                          fontSize: 14,
                        ).copyWith(color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Text(
                      "Email address",
                      style: AppFonts.poppinsMedium(fontSize: 16),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppFonts.poppinsMedium(fontSize: 17),
                      decoration: emailDecoration(),
                    ),

                    const SizedBox(height: 28),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.Pink.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.Pink,
                            size: 21,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "We'll send you a password reset link to your email address.",
                              style: AppFonts.poppinsMedium(
                                fontSize: 12,
                              ).copyWith(color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.Pink,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: AppColors.Pink.withOpacity(0.35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 23,
                                width: 23,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Send Reset Link",
                                    style: AppFonts.poppinsMedium(
                                      fontSize: 17,
                                    ).copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 21,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Get.offAll(() => const LoginScreen());
                        },
                        child: Text(
                          "←  Return to Login",
                          style: AppFonts.poppinsMedium(
                            fontSize: 15,
                          ).copyWith(color: AppColors.darkpink),
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
    );
  }
}
