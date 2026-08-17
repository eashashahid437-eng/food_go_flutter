import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/cartcontroller.dart';
import 'package:food_go/Screens/cartscreen.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/widgets/customized.dart';
import 'package:food_go/widgets/toppingscreen.dart';
import 'package:get/get.dart';

class BurgerCustomizationScreen extends StatefulWidget {
  final double basePrice;

  const BurgerCustomizationScreen({super.key, this.basePrice = 10.0});

  @override
  State<BurgerCustomizationScreen> createState() =>
      _BurgerCustomizationScreenState();
}

class _BurgerCustomizationScreenState extends State<BurgerCustomizationScreen> {
  double spicyLevel = 0.2;
  int portionCount = 1;

  final List<Map<String, dynamic>> selectedItems = [];

  final CartController cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  double get itemsTotal {
    return selectedItems.fold(
      0.0,
      (sum, item) => sum + ((item['price'] ?? 0) as num).toDouble(),
    );
  }

  double get totalPrice {
    return (widget.basePrice + itemsTotal) * portionCount;
  }

  void toggleItem(Map<String, dynamic> item) {
    final id = item['docId'];

    setState(() {
      final exists = selectedItems.any((element) => element['docId'] == id);

      if (exists) {
        selectedItems.removeWhere((element) => element['docId'] == id);
      } else {
        selectedItems.add(item);
      }
    });
  }

  bool isSelected(String id) {
    return selectedItems.any((item) => item['docId'] == id);
  }

  void addToCart() {
    final bool isDark = Get.isDarkMode;

    if (selectedItems.isEmpty) {
      Get.snackbar(
        "Select toppings",
        "Please select at least one topping.",
        backgroundColor: Colors.orange,
        colorText: AppColors.lightwhite,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final String toppingsString = selectedItems
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    final cartItem = {
      'cartId': 'custom_burger_${DateTime.now().millisecondsSinceEpoch}',
      'productId': 'custom_burger',
      'productName': 'Customized Burger',
      'subtitle': toppingsString.isNotEmpty
          ? "Toppings: $toppingsString"
          : "Custom Burger",
      'image': 'assets/images/topping.jpg',
      'price': widget.basePrice,
      'quantity': portionCount,
      'spicyLevel': spicyLevel,
      'isCustomized': true,
      'toppings': selectedItems.map((item) {
        return {
          'id': item['docId'],
          'name': item['name'],
          'price': item['price'] ?? 0,
        };
      }).toList(),
      'itemTotal': totalPrice,
    };

    cartController.addToCart(cartItem);

    Get.snackbar(
      "Added to Cart",
      "Customized burger added to your cart.",
      backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
      colorText: AppColors.lightwhite,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );

    Get.to(() => CartScreen());
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white, // Yahan background white kar diya hai
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white, // AppBar bhi white kar di hai
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
          onPressed: Get.back,
        ),
        title: Text(
          "Customize Burger",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    "assets/images/topping.jpg",
                    height: screenHeight * 0.22,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Customize Your Burger",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        "Spicy",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.darkpink,
                          inactiveTrackColor:
                              isDark ? Colors.grey[800] : AppColors.lightPink,
                          thumbColor: AppColors.darkpink,
                          overlayColor: AppColors.darkpink.withOpacity(0.10),
                        ),
                        child: Slider(
                          value: spicyLevel,
                          min: 0,
                          max: 1,
                          onChanged: (value) {
                            setState(() {
                              spicyLevel = value;
                            });
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Mild",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Hot",
                              style: TextStyle(
                                color: AppColors.darkpink,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Text(
                        "Portion",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.lightwhite : Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      CustomCounter(
                        value: portionCount,
                        onMinus: () {
                          if (portionCount > 1) {
                            setState(() {
                              portionCount--;
                            });
                          }
                        },
                        onPlus: () {
                          setState(() {
                            portionCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            _buildOptions(title: "Toppings", category: "topping", isDark: isDark),
            SizedBox(height: screenHeight * 0.03),
            _buildOptions(title: "Side options", category: "side", isDark: isDark),
            SizedBox(height: screenHeight * 0.1),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark, screenWidth),
    );
  }

  Widget _buildOptions({
    required String title,
    required String category,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('toppings')
                .where('category', isEqualTo: category)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkpink,
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  "No items available.",
                  style: TextStyle(color: AppColors.lightgrey),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final item = {...data, 'docId': doc.id};

                  return CustomOptionCard(
                    name: data['name'] ?? 'Item',
                    imageUrl: data['imageUrl'] ?? '',
                    isSelected: isSelected(doc.id),
                    onTap: () {
                      toggleItem(item);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.045),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  color: AppColors.lightgrey,
                  fontSize: 12,
                ),
              ),
              Text(
                "\$${totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 160,
            height: 50,
            child: ElevatedButton(
              onPressed: addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkpink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "ADD TO CART",
                style: TextStyle(
                  color: AppColors.lightwhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
