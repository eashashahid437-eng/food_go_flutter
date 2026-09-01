// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/paymentmethodcontroller.dart';
import 'package:get/get.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalPrice;
  final List<Map<String, dynamic>> orderItems;

  const PaymentMethodScreen({
    super.key,
    required this.totalPrice,
    this.orderItems = const [],
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late PaymentController controller;

  @override
  void initState() {
    super.initState();

    controller = PaymentController(
      widget.totalPrice,
      orderItems: widget.orderItems,
    );

    Get.put(controller);
  }

  @override
  void dispose() {
    if (Get.isRegistered<PaymentController>()) {
      Get.delete<PaymentController>();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Payment",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.055,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(
              "Order summary",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: isDark
                    ? AppColors.lightwhite
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 15),
            Obx(
              () => _summaryRow(
                "Order",
                controller.orderAmount.value,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () =>
                  _summaryRow("Taxes", controller.taxes.value, isDark: isDark),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _summaryRow(
                "Delivery fees",
                controller.deliveryFees.value,
                isDark: isDark,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.grey),
            ),
            Obx(
              () => _summaryRow(
                "Total",
                controller.totalAmount,
                isTotal: true,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated delivery time:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.lightwhite : Colors.brown.shade900,
                  ),
                ),
                Text(
                  '15 - 30mins',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.lightwhite : Colors.brown.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Stylish Secure Payment Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Secure Stripe Payment",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.lightwhite : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Tap 'Pay Now' to enter your card details securely.",
                          style: TextStyle(
                            fontSize: 12, 
                            color: isDark ? Colors.grey[400] : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total price",
                      style: TextStyle(
                        fontSize: 12, 
                        color: isDark ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        "\$${controller.totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.isProcessing.value
                          ? null
                          : () {
                              controller.processPayment(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFF3E3A3A)
                            : const Color(0xFF2C2424),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isProcessing.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "PAY NOW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    String title,
    double amount, {
    bool isTotal = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? (isDark ? AppColors.lightwhite : AppColors.textPrimaryLight)
                : Colors.grey[400],
          ),
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Controllers/paymentmethodcontroller.dart';
// import 'package:get/get.dart';

// class PaymentMethodScreen extends StatefulWidget {
//   final double totalPrice;
//   final List<Map<String, dynamic>> orderItems;

//   const PaymentMethodScreen({
//     super.key,
//     required this.totalPrice,
//     this.orderItems = const [],
//   });

//   @override
//   State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
// }

// class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
//   late PaymentController controller;

//   @override
//   void initState() {
//     super.initState();

//     controller = PaymentController(
//       widget.totalPrice,
//       orderItems: widget.orderItems,
//     );

//     Get.put(controller);
//   }

//   @override
//   void dispose() {
//     if (Get.isRegistered<PaymentController>()) {
//       Get.delete<PaymentController>();
//     }

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Get.isDarkMode;
//     final Size screenSize = MediaQuery.sizeOf(context);

//     return Scaffold(
//       backgroundColor: isDark
//           ? AppColors.backgroundDark
//           : AppColors.backgroundLight,
//       appBar: AppBar(
//         backgroundColor: isDark
//             ? AppColors.surfaceDark
//             : AppColors.surfaceLight,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//           ),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           "Payment",
//           style: TextStyle(
//             color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//             fontWeight: FontWeight.bold,
//             fontSize: screenSize.width * 0.055,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 5),
//             Text(
//               "Order summary",
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w300,
//                 color: isDark
//                     ? AppColors.lightwhite
//                     : AppColors.textPrimaryLight,
//               ),
//             ),
//             const SizedBox(height: 15),
//             Obx(
//               () => _summaryRow(
//                 "Order",
//                 controller.orderAmount.value,
//                 isDark: isDark,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Obx(
//               () =>
//                   _summaryRow("Taxes", controller.taxes.value, isDark: isDark),
//             ),
//             const SizedBox(height: 8),
//             Obx(
//               () => _summaryRow(
//                 "Delivery fees",
//                 controller.deliveryFees.value,
//                 isDark: isDark,
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: Divider(color: Colors.grey),
//             ),
//             Obx(
//               () => _summaryRow(
//                 "Total",
//                 controller.totalAmount,
//                 isTotal: true,
//                 isDark: isDark,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Estimated delivery time:',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.brown.shade900,
//                   ),
//                 ),
//                 Text(
//                   '15 - 30mins',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                     color: Colors.brown.shade900,
//                   ),
//                 ),
//               ],
//             ),
//             // const Text(
//             //   "Estimated delivery time:         15 - 30 mins",
//             //   style: TextStyle(
//             //     fontSize: 13,
//             //     color: Colors.grey,
//             //   ),
//             // ),
//             const SizedBox(height: 25),

//             // Stylish Secure Payment Banner
//             Container(
//               padding: const EdgeInsets.all(18),
//               decoration: BoxDecoration(
//                 color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey.withOpacity(0.2)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.lock_outline,
//                       color: Colors.red,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: const [
//                         Text(
//                           "Secure Stripe Payment",
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 3),
//                         Text(
//                           "Tap 'Pay Now' to enter your card details securely.",
//                           style: TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Banner ke neechay space kam karne ke liye chota SizedBox
//             const SizedBox(height: 40),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "Total price",
//                       style: TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                     const SizedBox(height: 2),
//                     Obx(
//                       () => Text(
//                         "\$${controller.totalAmount.toStringAsFixed(2)}",
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primaryLight,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   width: 150,
//                   height: 50,
//                   child: Obx(
//                     () => ElevatedButton(
//                       onPressed: controller.isProcessing.value
//                           ? null
//                           : () {
//                               controller.processPayment(context);
//                             },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isDark
//                             ? AppColors.surfaceDark
//                             : const Color(0xFF2C2424),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: controller.isProcessing.value
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               "PAY NOW",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _summaryRow(
//     String title,
//     double amount, {
//     bool isTotal = false,
//     required bool isDark,
//   }) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: isTotal ? 16 : 14,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//             color: isTotal
//                 ? (isDark ? AppColors.lightwhite : AppColors.textPrimaryLight)
//                 : Colors.grey[400],
//           ),
//         ),
//         Text(
//           "\$${amount.toStringAsFixed(2)}",
//           style: TextStyle(
//             fontSize: isTotal ? 18 : 14,
//             fontWeight: FontWeight.bold,
//             color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//           ),
//         ),
//       ],
//     );
//   }
// }
