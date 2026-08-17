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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Order summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
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
              () => _summaryRow(
                "Taxes",
                controller.taxes.value,
                isDark: isDark,
              ),
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
              padding: EdgeInsets.symmetric(
                vertical: 12,
              ),
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
            const Text(
              "Estimated delivery time: 15 - 30 mins",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Payment methods",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 15),
            Obx(
              () => Column(
                children: [
                  _buildPaymentCard(
                    title: "Credit card",
                    subtitle: "5105 **** **** 0505",
                    imagePath: "assets/images/account.jpg",
                    isSelected:
                        controller.selectedMethod.value == "credit_card",
                    isDark: isDark,
                    onTap: () {
                      controller.selectPaymentMethod("credit_card");
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentCard(
                    title: "Debit card",
                    subtitle: "3566 **** **** 0505",
                    imagePath: "assets/images/visa.jpg",
                    isSelected: controller.selectedMethod.value == "debit_card",
                    isDark: isDark,
                    onTap: () {
                      controller.selectPaymentMethod("debit_card");
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Obx(
              () => Row(
                children: [
                  Checkbox(
                    value: controller.saveCard.value,
                    activeColor: AppColors.primaryLight,
                    onChanged: (value) {
                      controller.saveCard.value = value ?? false;
                    },
                  ),
                  Expanded(
                    child: Text(
                      "Save card details for future payments",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total price",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(
                      () => Text(
                        "\$${controller.totalAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
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
                        backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFF2C2424),
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

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryLight : const Color(0xFF2C2424))
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 30,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.credit_card,
                    color: Colors.grey,
                    size: 22,
                  );
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.lightwhite : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
