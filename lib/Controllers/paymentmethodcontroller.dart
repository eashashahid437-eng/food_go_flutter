import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> orderItems;

  final RxDouble orderAmount = 0.0.obs;

  final RxDouble taxes = 0.30.obs;

  final RxDouble deliveryFees = 1.50.obs;

  double get totalAmount {
    return orderAmount.value + taxes.value + deliveryFees.value;
  }

  final RxString selectedMethod = 'credit_card'.obs;

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
        'orderTitle':
            firstItemName, // Yahan 'itemName' ko 'orderTitle' kar diya hai
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

      debugPrint("======================================");
      debugPrint("ORDER CREATED SUCCESSFULLY");
      debugPrint("ORDER ID: $orderId");
      debugPrint("USER ID: ${user.uid}");
      debugPrint("ITEMS: ${cleanItems.length}");
      debugPrint("TOTAL: ${totalAmount.toStringAsFixed(2)}");
      debugPrint("STATUS: Pending");
      debugPrint("PAYMENT STATUS: Paid");
      debugPrint("======================================");

      if (context.mounted) {
        _showSuccessDialog(context, orderId);
      }
    } catch (e) {
      debugPrint("ORDER ERROR: $e");

      Get.snackbar(
        "Order Error",
        "Something went wrong while placing your order.",
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
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
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
