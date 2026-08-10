import 'package:flutter/material.dart';
import 'package:food_go/Screens/BottomNavbar/home_screen.dart';
import 'package:get/get.dart';

class PaymentDone extends StatefulWidget {
  const PaymentDone({super.key});

  @override
  State<PaymentDone> createState() => _PaymentDoneState();
}

class _PaymentDoneState extends State<PaymentDone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.62,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tick Circle
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xffF52F3D),
                ),

                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),

              const SizedBox(height: 20),

              const Text(
                "Success !",
                style: TextStyle(
                  color: Color(0xffF52F3D),
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Your payment was successful.\n"
                "A receipt for this purchase has\n"
                "been sent to your email.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 11, height: 1.5),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 45,

                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffF52F3D),
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    "Go Back",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
