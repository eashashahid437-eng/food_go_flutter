import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';

class PaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Backend URL seedha yahan define — koi alag file nahi chahiye
  static const String _backendUrl =
      'https://food-delivery-backend-ivory.vercel.app/api/create-payment-intent';

  final List<Map<String, dynamic>> orderItems;

  final RxDouble orderAmount = 0.0.obs;

  final RxDouble taxes = 0.30.obs;

  final RxDouble deliveryFees = 1.50.obs;

  double get totalAmount {
    return orderAmount.value + taxes.value + deliveryFees.value;
  }

  // Ab yahan default 'Stripe Card' set kar diya hai taake database mein theek save ho
  final RxString selectedMethod = 'Stripe Card'.obs;

  final RxBool saveCard = true.obs;

  final RxBool isProcessing = false.obs;

  PaymentController(double price, {this.orderItems = const []}) {
    orderAmount.value = price;
  }

  void selectPaymentMethod(String method) {
    selectedMethod.value = method;
  }

  Future<void> processPayment(BuildContext context) async {
    if (isProcessing.value) return;

    isProcessing.value = true;

    try {
      final User? user = _auth.currentUser;

      if (user == null) {
        Get.snackbar(
          "Login Required",
          "Please login before placing your order.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      if (orderItems.isEmpty) {
        Get.snackbar(
          "Cart Empty",
          "Please add items to cart first.",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      // 1. Call Vercel Backend to Create Payment Intent
      final int amountInCents = (totalAmount * 100).round();

      debugPrint("======================================");
      debugPrint("SENDING PAYMENT REQUEST TO: $_backendUrl");
      debugPrint("AMOUNT IN CENTS: $amountInCents");
      debugPrint("======================================");

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountInCents,
          'currency': 'usd',
        }),
      );

      debugPrint("RESPONSE STATUS CODE: ${response.statusCode}");
      debugPrint("RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      final String clientSecret = jsonResponse['clientSecret'];

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Food Go',
          style: ThemeMode.dark,
        ),
      );

      // 3. Display Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Save Order to Firestore after successful payment
      final DocumentReference orderRef = _firestore.collection('orders').doc();
      final String orderId = orderRef.id;

      final List<Map<String, dynamic>> cleanItems = orderItems.map((item) {
        return {
          'productId': item['productId'] ?? '',
          'productName': item['productName'] ?? item['title'] ?? 'Product',
          'image': item['image'] ?? '',
          'price': _toDouble(item['price']),
          'quantity': _toInt(item['quantity']),
          'itemTotal': _toDouble(item['itemTotal']),
          'isCustomized': item['isCustomized'] ?? false,
          'customizationKey': item['customizationKey'] ?? '',
        };
      }).toList();

      String firstItemName = 'Food Order';

      if (cleanItems.isNotEmpty) {
        firstItemName =
            cleanItems.first['productName']?.toString() ?? 'Food Order';
      }

      final Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'email': user.email ?? '',
        'items': cleanItems,
        'orderTitle': firstItemName,
        'totalItems': cleanItems.fold<int>(
          0,
          (sum, item) => sum + _toInt(item['quantity']),
        ),
        'orderAmount': orderAmount.value,
        'taxes': taxes.value,
        'deliveryFees': deliveryFees.value,
        'totalAmount': totalAmount,
        'paymentMethod': selectedMethod.value, // Ab yahan 'Stripe Card' save hoga
        'saveCardDetails': saveCard.value,
        'status': 'Pending',
        'paymentStatus': 'Paid',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      debugPrint("======================================");
      debugPrint("ORDER & PAYMENT SUCCESSFUL");
      debugPrint("ORDER ID: $orderId");
      debugPrint("======================================");

      if (context.mounted) {
        _showSuccessDialog(context, orderId);
      }
    } on StripeException catch (e) {
      debugPrint("STRIPE ERROR: ${e.error.localizedMessage}");
      Get.snackbar(
        "Payment Cancelled",
        e.error.localizedMessage ?? "Payment failed.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint("ORDER ERROR: $e");

      Get.snackbar(
        "Order Error",
        "Something went wrong while processing your payment.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void _showSuccessDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      color: Color.fromARGB(255, 44, 36, 36), size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Success!",
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your order has been placed successfully.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Order ID",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  orderId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 1;
  }
}
