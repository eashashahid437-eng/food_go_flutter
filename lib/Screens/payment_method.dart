import 'package:flutter/material.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/Payment_done.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

// class PaymentMethod extends StatefulWidget {
//   const PaymentMethod({super.key});
class PaymentMethod extends StatefulWidget {
  final double orderTotal;

  const PaymentMethod({super.key, required this.orderTotal});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  int selectedPayment = 0;
  bool saveCard = true;

  double get taxes {
    return widget.orderTotal * 0.02;
  }

  double get deliveryFee {
    return 1.50;
  }

  double get grandTotal {
    return widget.orderTotal + taxes + deliveryFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),

              const Text(
                "Order summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Order
              _summaryRow("Order", "\$16.48"),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Taxes
              _summaryRow("Taxes", "\$0.3"),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Delivery
              _summaryRow("Delivery fees", "\$1.5"),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              const Divider(),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Total:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "\$18.19",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Estimated delivery time:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "15 - 30mins",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              const Text(
                "Payment methods",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Master Card
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPayment = 0;
                  });
                },
                child: _paymentCard(
                  isSelected: selectedPayment == 0,
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                           child: Image.asset(ImagePath.mastercard)
                        ),
                      ),

                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Credit card",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "5105 **** **** 0505",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Radio<int>(
                        value: 0,
                        groupValue: selectedPayment,
                        activeColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            selectedPayment = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Visa
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPayment = 1;
                  });
                },
                child: _paymentCard(
                  isSelected: selectedPayment == 1,
                  // child: Row(
                  //   children: [
                  //     SizedBox(
                  //       child:Center()
                        
                  //       child: Image.asset(ImagePath.visa,
                  //       ),
                  //     ),
                  child: Row(
                    children: [
                      SizedBox(width: MediaQuery.of(context).size.width * 0.03),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Debit card",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "3566 **** **** 0505",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Radio<int>(
                        value: 1,
                        groupValue: selectedPayment,
                        activeColor: Colors.red,
                        onChanged: (value) {
                          setState(() {
                            selectedPayment = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Save card
              Row(
                children: [
                  Checkbox(
                    value: saveCard,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      setState(() {
                        saveCard = value ?? false;
                      });
                    },
                  ),

                  const Text(
                    "Save card details for future payments",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),

              SizedBox(width: MediaQuery.of(context).size.width * 0.03),

              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total price",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),

                        Text(
                          "\$18.19",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: 130,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => PaymentDone());
                        // Get.dialog(
                        //   const PaymentMethod(),
                        //   barrierDismissible: false,
                        // );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3D3030),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        "Pay Now",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _paymentCard({required bool isSelected, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xff3D3030) : const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        child: child,
      ),
    );
  }
}
