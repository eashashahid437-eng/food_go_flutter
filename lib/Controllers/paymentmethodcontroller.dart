import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';

class PaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Backend URLs
  static const String _backendUrl =
      'https://food-delivery-backend-ivory.vercel.app/api/create-payment-intent';
  static const String _notifyAdminUrl =
      'https://food-delivery-backend-ivory.vercel.app/api/notify-admin';

  final List<Map<String, dynamic>> orderItems;

  final RxDouble orderAmount = 0.0.obs;
  final RxDouble taxes = 0.30.obs;
  final RxDouble deliveryFees = 1.50.obs;

  double get totalAmount {
    return orderAmount.value + taxes.value + deliveryFees.value;
  }

  final RxString selectedMethod = 'Stripe Card'.obs;
  final RxBool saveCard = true.obs;
  final RxBool isProcessing = false.obs;

  PaymentController(double price, {this.orderItems = const []}) {
    orderAmount.value = price;
  }

  void selectPaymentMethod(String method) {
    selectedMethod.value = method;
  }

  // Updated Admin Notification Method (includes userName and userId)
  Future<void> _notifyAdminNewOrder({
    required String orderTitle,
    required double totalAmount,
    required String orderId,
    required String userId,
    required String userName,
  }) async {
    try {
      await http.post(
        Uri.parse(_notifyAdminUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderTitle': orderTitle,
          'totalAmount': totalAmount,
          'orderId': orderId,
          'userId': userId,
          'userName': userName,
        }),
      );
    } catch (e) {
      debugPrint("Admin notify failed: $e");
    }
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

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amountInCents,
          'currency': 'usd',
        }),
      );

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

      // User details extract for Admin reference
      final String userName =
          user.displayName ?? user.email?.split('@').first ?? 'Customer';

      final Map<String, dynamic> orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'userName': userName,
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
        'paymentMethod': selectedMethod.value,
        'saveCardDetails': saveCard.value,
        'status': 'Pending',
        'paymentStatus': 'Paid',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);

      // 5. Admin ko naye order ka notification bhejo (with User info)
      await _notifyAdminNewOrder(
        orderTitle: firstItemName,
        totalAmount: totalAmount,
        orderId: orderId,
        userId: user.uid,
        userName: userName,
      );

      if (context.mounted) {
        _showSuccessDialog(context);
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
  // Dynamic Theme Dialog
  void _showSuccessDialog(BuildContext context) {
    final bool isDark = Get.isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 75,
                  height: 75,
                  decoration: const BoxDecoration(
                    color: AppColors.darkpink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 45,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Success !",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkpink,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  "Your payment was successful.\nA receipt for this purchase has been sent to your email.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkpink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Go Back",
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

  // // Exact Figma Template Dialog
  // void _showSuccessDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (dialogContext) {
  //       return Dialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(24),
  //         ),
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // Icon
  //               Container(
  //                 width: 75,
  //                 height: 75,
  //                 decoration: const BoxDecoration(
  //                   color: AppColors.darkpink,
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: const Icon(
  //                   Icons.check,
  //                   color: Colors.white,
  //                   size: 45,
  //                 ),
  //               ),
  //               const SizedBox(height: 20),

  //               // Title
  //               const Text(
  //                 "Success !",
  //                 style: TextStyle(
  //                   fontSize: 24,
  //                   fontWeight: FontWeight.bold,
  //                   color: AppColors.darkpink,
  //                 ),
  //               ),
  //               const SizedBox(height: 12),

  //               // Subtitle (Exact Figma Text)
  //               const Text(
  //                 "Your payment was successful.\nA receipt for this purchase has been sent to your email.",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   height: 1.4,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //               const SizedBox(height: 30),

  //               // Button
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 48,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.of(dialogContext).pop();
  //                     Get.back();
  //                   },
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: AppColors.darkpink,
  //                     elevation: 0,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                   ),
  //                   child: const Text(
  //                     "Go Back",
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

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
