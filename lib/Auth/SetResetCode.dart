import 'package:flutter/material.dart';
import 'package:food_go/Auth/ConfirmResetCode.dart';
import 'package:food_go/Auth/Login_Screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class Setresetcode extends StatefulWidget {
  const Setresetcode({super.key});

  @override
  State<Setresetcode> createState() => _SetresetcodeState();
}

class _SetresetcodeState extends State<Setresetcode> {
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(10),
    ),
  );

  late final PinTheme focusedPinTheme = defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      border: Border.all(color: Colors.pink),
    ),
  );

  late final PinTheme submittedPinTheme = defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      color: Colors.pink.shade50,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              // Title
              const Center(
                child: Text(
                  "Reset Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              // Description
              const Center(
                child: Text(
                  "Enter the reset code sent to your email address",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04),

              // Reset Code Field
              Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                validator: (value) {
                  return value == '2222' ? null : 'Pin is incorrect';
                },
                onCompleted: (pin) {
                  debugPrint('Entered PIN: $pin');
                },
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              Text(
                "Did'nt get Code?",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              TextButton(
                onPressed: () {},
                child: Text(
                  "Resend Code",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              
              SizedBox(
                width: MediaQuery.of(context).size.height*0.3,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                     Get.to(() => ConfirmResetCode());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.Pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "New Password",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

                Center(
                        child: TextButton(
                          onPressed: () {
                            Get.back(); 
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
      ),
    );
  }
}
