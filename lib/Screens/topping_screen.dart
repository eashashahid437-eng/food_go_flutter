import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Screens/payment_method.dart';
import 'package:get/get.dart';

class BurgerCustomizationScreen extends StatefulWidget {
  final double basePrice;
  const BurgerCustomizationScreen({super.key, this.basePrice = 10.0});

  @override
  State<BurgerCustomizationScreen> createState() =>
      _BurgerCustomizationScreenState();
}

class _BurgerCustomizationScreenState extends State<BurgerCustomizationScreen> {
  double _spicyLevel = 0.2; // 0.0 (Mild) to 1.0 (Hot)
  int _portionCount = 1;
  final List<Map<String, dynamic>> _selectedItems = [];

  double get _calculatedTotal {
    double itemsTotal = _selectedItems.fold(
      0.0,
      (sum, item) => sum + (item['price'] ?? 0.0),
    );
    return (widget.basePrice + itemsTotal) * _portionCount;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOP SECTION (Figma Style) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Burger Image (Cleaner)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Image.asset(
                        "assets/images/topping.jpg", // Asset path should be correct
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Icon(
                            Icons.fastfood,
                            color: Colors.orange,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Controls Section
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Customize Your Burger",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "to Your Tastes. Ultimate Experience",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Spicy",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.darkpink,
                            inactiveTrackColor: Colors.red.shade100,
                            thumbColor: AppColors.darkpink,
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _spicyLevel,
                            onChanged: (v) => setState(() => _spicyLevel = v),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Mild",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ), // Green for Mild
                            Text(
                              "Hot",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ), // Red for Hot
                          ],
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Portion",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildCounterBtn(
                              Icons.remove,
                              () => setState(
                                () =>
                                    _portionCount > 1 ? _portionCount-- : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                "$_portionCount",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            _buildCounterBtn(
                              Icons.add,
                              () => setState(() => _portionCount++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),

              // --- TOPPINGS SECTION ---
              _buildStreamSection("Toppings", 'topping'),
              const SizedBox(height: 25),

              // --- SIDE OPTIONS SECTION ---
              _buildStreamSection("Side options", 'side'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildCounterBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.darkpink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildStreamSection(String title, String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('toppings')
              .where('category', isEqualTo: category)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "No items available yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              );
            }
            return SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  data['docId'] = snapshot
                      .data!
                      .docs[index]
                      .id; // Document ID save kar lein
                  bool isSelected = _selectedItems.any(
                    (i) => i['docId'] == data['docId'],
                  );
                  return _buildItemCard(data, isSelected);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildItemCard(Map<String, dynamic> data, bool isSelected) {
    String name = data['name'] ?? 'Item';
    String imageUrl = data['imageUrl'] ?? '';

    return GestureDetector(
      onTap: () => setState(() {
        if (isSelected) {
          _selectedItems.removeWhere((i) => i['docId'] == data['docId']);
        } else {
          _selectedItems.add(data);
        }
      }),
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.darkpink : Colors.grey.shade200,
            width: 2,
          ), // Thicker border on selection
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.darkpink.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          children: [
            // Image Container
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => const Icon(
                      Icons.fastfood_rounded,
                      size: 30,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),
              ),
            ),
            // Dark Label Container with '+' Icon
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Item Name
                    Flexible(
                      child: Text(
                        name,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Red '+' Icon (Figma Style)
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.red,
                        shape: BoxShape.circle,
                      ), // Icon background changes color
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: isSelected ? AppColors.darkpink : Colors.white,
                      ), // Icon color changes
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Total Price
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total",
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
              Text(
                "\$${_calculatedTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // Order Now Button
          SizedBox(
            width: 160,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkpink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),

              onPressed: () {
                if (_selectedItems.isEmpty) {
                  Get.snackbar(
                    "Oops!",
                    "Please select at least one topping.",
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    "Success!",
                    "Order placed successfully!",
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                    snackPosition: SnackPosition.TOP,
                  );

                  Future.delayed(const Duration(seconds: 1), () {
                    Get.to(() => PaymentMethodScreen(totalPrice: _calculatedTotal));
                  });
                }
              },

              child: const Text(
                "Order Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // child: ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: AppColors.darkpink,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(16),
            //     ),
            //     elevation: 2,
            //   ),
            //   onPressed: () {

            //     if (_selectedItems.isEmpty) {
            //       Get.snackbar(
            //         "Oops!",
            //         "Please select at least one topping.",
            //         backgroundColor: Colors.orange,
            //         colorText: Colors.white,
            //       );
            //     } else {
            //       Get.snackbar(
            //         "Success!",
            //         "Order Placed! Total: \$${_calculatedTotal.toStringAsFixed(2)}",
            //         backgroundColor: Colors.green,
            //         colorText: Colors.white,
            //       );
            //     }
            //     },

            //   child: const Text(
            //     "Order Now",
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
