import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';

class Congrats extends StatefulWidget {
  const Congrats({super.key});

  @override
  State<Congrats> createState() => _CongratsState();
}

class _CongratsState extends State<Congrats> {
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

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const SizedBox(height: 100),

            Container(
              height: 110,
              width: 110,
              decoration: const BoxDecoration(
                color: AppColors.Pink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 70),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            const Text(
              "Congrats!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            const Text(
              "Your password changed successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),

            const Spacer(),

            SizedBox(
              width: MediaQuery.of(context).size.width*0.3,
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Login screen par le jane ke liye
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:AppColors.Pink,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Return to login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          ],
        ),
      ),
    );
  }
}
