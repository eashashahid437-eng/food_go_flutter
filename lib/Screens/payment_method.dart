import 'package:flutter/material.dart';
import 'package:food_go/Controllers/paymentmethodcontroller.dart';
import 'package:get/get.dart';

class PaymentMethodScreen extends StatelessWidget {
  final double totalPrice; // Pichli screen se aane wali real price
  
  const PaymentMethodScreen({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    final PaymentController controller = Get.put(PaymentController(totalPrice));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 15),
            
            // Dynamic Order Price Calculation
            Obx(() => _buildSummaryRow("Order", "\$${controller.orderAmount.value.toStringAsFixed(2)}")),
            const SizedBox(height: 8),
            Obx(() => _buildSummaryRow("Taxes", "\$${controller.taxes.value.toStringAsFixed(2)}")),
            const SizedBox(height: 8),
            Obx(() => _buildSummaryRow("Delivery fees", "\$${controller.deliveryFees.value.toStringAsFixed(2)}")),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(color: Colors.grey, thickness: 0.5),
            ),

            Obx(() => _buildSummaryRow("Total:", "\$${controller.totalAmount.toStringAsFixed(2)}", isTotal: true)),
            const SizedBox(height: 10),
            
            const Text(
              "Estimated delivery time:        15 - 30mins",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            
            const SizedBox(height: 30),
            const Text(
              "Payment methods",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 15),

            // Payment Cards with Assets Images (account.jpg & visa.jpg)
            Obx(() => Column(
              children: [
                _buildPaymentCard(
                  title: 'Credit card',
                  subtitle: '5105 **** **** 0505',
                  imagePath: "assets/images/account.jpg",
                  isSelected: controller.selectedMethod.value == 'mastercard',
                  onTap: () => controller.selectedMethod.value = 'mastercard',
                ),
                const SizedBox(height: 12),
                _buildPaymentCard(
                  title: 'Debit card',
                  subtitle: '3566 **** **** 0505',
                  imagePath: "assets/images/visa.jpg",
                  isSelected: controller.selectedMethod.value == 'visa',
                  onTap: () => controller.selectedMethod.value = 'visa',
                ),
              ],
            )),

            const SizedBox(height: 15),

            Obx(() => Row(
              children: [
                Checkbox(
                  value: controller.saveCard.value,
                  activeColor: Colors.red,
                  onChanged: (val) => controller.saveCard.value = val ?? true,
                ),
                const Text(
                  "Save card details for future payments",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            )),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Total price", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Obx(() => Text(
                      "\$${controller.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    )),
                  ],
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2424),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => controller.processPayment(context),
                    child: Obx(() => controller.isProcessing.value
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Pay Now", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold))),
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

  Widget _buildSummaryRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.black : Colors.grey[700])),
        Text(amount, style: TextStyle(fontSize: isTotal ? 18 : 14, fontWeight: FontWeight.bold, color: isTotal ? Colors.black : Colors.black87)),
      ],
    );
  }

  Widget _buildPaymentCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2424) : Colors.grey[100],
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
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
