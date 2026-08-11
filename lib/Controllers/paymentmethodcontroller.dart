import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  // Real price jo pichli screen se aayegi
  var orderAmount = 0.0.obs;
  var taxes = 0.30.obs;
  var deliveryFees = 1.50.obs;
  
  // Constructor mein price receive hogi
  PaymentController(double price) {
    orderAmount.value = price;
  }
  
  double get totalAmount => orderAmount.value + taxes.value + deliveryFees.value;

  var selectedMethod = 'mastercard'.obs;
  var saveCard = true.obs;
  var isProcessing = false.obs;

  Future<void> processPayment(BuildContext context) async {
    isProcessing.value = true;
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar("Error", "User not logged in!", backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Firestore database mein real order save hoga
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user.uid,
        'email': user.email ?? '',
        'orderAmount': orderAmount.value,
        'taxes': taxes.value,
        'deliveryFees': deliveryFees.value,
        'totalAmount': totalAmount,
        'paymentMethod': selectedMethod.value == 'mastercard' ? 'Credit Card' : 'Debit Card',
        'saveCardDetails': saveCard.value,
        'status': 'Success',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog(context);

    } catch (e) {
      Get.snackbar("Error", "Payment failed: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text("Success !", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text(
                  "Your payment was successful.\nA receipt for this purchase has\nbeen sent to your email.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Get.back();
                    },
                    child: const Text("Go Back", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
