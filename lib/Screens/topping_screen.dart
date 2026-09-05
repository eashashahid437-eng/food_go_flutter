import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/cartcontroller.dart';
import 'package:food_go/Screens/cartscreen.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:get/get.dart';

class BurgerCustomizationScreen extends StatefulWidget {
  final double basePrice;

  const BurgerCustomizationScreen({super.key, this.basePrice = 10.0});

  @override
  State<BurgerCustomizationScreen> createState() =>
      _BurgerCustomizationScreenState();
}

class _BurgerCustomizationScreenState extends State<BurgerCustomizationScreen> {
  double _spicyLevel = 0.2;
  int _portionCount = 1;

  final List<Map<String, dynamic>> _selectedItems = [];

  final CartController cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  double get itemsTotal {
    final itemsSum = _selectedItems.fold(
      0.0,
      (sum, item) => sum + ((item['price'] ?? 0) as num).toDouble(),
    );

    return (widget.basePrice + itemsSum) * _portionCount;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final screenWidth = MediaQueryu.getScreenWidth(context);
    final screenHeight = MediaQueryu.getScreenHeight(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.lightwhite : Colors.black87,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.lightwhite : Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: isDark ? AppColors.lightwhite : Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
        title: Text(
          "Customize Burger",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.04),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          "assets/images/topping.111.jpg",
                          height: screenHeight * 0.22,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: screenHeight * 0.22,
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.grey.shade100,
                              child: const Icon(
                                Icons.fastfood,
                                color: AppColors.darkpink,
                                size: 80,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
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
                            color: isDark
                                ? AppColors.lightwhite
                                : Colors.black87,
                          ),
                        ),
                        Text(
                          "to Your Tastes. Ultimate Experience",
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.018),
                        Text(
                          "Spicy",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.lightwhite
                                : Colors.black87,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.darkpink,
                            inactiveTrackColor: isDark
                                ? Colors.grey.shade800
                                : Colors.red.shade100,
                            thumbColor: AppColors.darkpink,
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _spicyLevel,
                            min: 0.0,
                            max: 5.0,
                            onChanged: (v) {
                              setState(() {
                                _spicyLevel = v;
                              });
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
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
                        SizedBox(height: screenHeight * 0.018),
                        Text(
                          "Portion",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.lightwhite
                                : Colors.black87,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.007),
                        Row(
                          children: [
                            _buildCounterBtn(Icons.remove, () {
                              setState(() {
                                if (_portionCount > 1) {
                                  _portionCount--;
                                }
                              });
                            }),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              child: Text(
                                "$_portionCount",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: isDark
                                      ? AppColors.lightwhite
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            _buildCounterBtn(Icons.add, () {
                              setState(() {
                                _portionCount++;
                              });
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.04),
              _buildStreamSection("Toppings", "topping", isDark),
              SizedBox(height: screenHeight * 0.03),
              _buildStreamSection("Side options", "side", isDark),
              SizedBox(height: screenHeight * 0.025),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark),
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

  Widget _buildStreamSection(String title, String category, bool isDark) {
    return Builder(
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;

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
            SizedBox(height: screenHeight * 0.015),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('toppings')
                  .where('category', isEqualTo: category)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.darkpink),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      "Error loading items.",
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 11,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "No items available yet.",
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: screenHeight * 0.135,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data =
                          snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;

                      final itemData = Map<String, dynamic>.from(data);
                      itemData['docId'] = snapshot.data!.docs[index].id;

                      final bool isSelected = _selectedItems.any(
                        (i) => i['docId'] == itemData['docId'],
                      );

                      return _buildItemCard(itemData, isSelected, isDark);
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> data,
    bool isSelected,
    bool isDark,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final String name = (data['name'] ?? 'Item').toString();
    final String imageUrl = (data['imageUrl'] ?? '').toString();

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedItems.removeWhere((i) => i['docId'] == data['docId']);
          } else {
            _selectedItems.add(data);
          }
        });
      },
      child: Container(
        width: screenWidth * 0.25,
        margin: EdgeInsets.only(right: screenWidth * 0.04),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.darkpink
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: 2,
          ),
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
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) {
                      return const Icon(
                        Icons.fastfood_rounded,
                        size: 30,
                        color: AppColors.darkpink,
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.backgroundDark : Colors.black87,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: isSelected ? AppColors.darkpink : Colors.white,
                      ),
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

  void addToCart() {
    if (_selectedItems.isEmpty) {
      Get.snackbar(
        "Oops!",
        "Please select at least one topping.",
        backgroundColor: Colors.white,
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final double toppingsTotal = _selectedItems.fold(
      0.0,
      (sum, item) => sum + ((item['price'] ?? 0) as num).toDouble(),
    );

    final double total = (widget.basePrice + toppingsTotal) * _portionCount;

    final Map<String, dynamic> cartItem = {
      'cartId': 'custom_burger_${DateTime.now().millisecondsSinceEpoch}',
      'productId': 'custom_burger',
      'productName': 'Customized Burger',
      'subtitle': 'Customized Burger',
      'image': 'assets/images/topping.jpg',
      'price': widget.basePrice + toppingsTotal,
      'quantity': _portionCount,
      'spicyLevel': _spicyLevel,
      'itemTotal': total,
      'customizations': _selectedItems
          .map(
            (item) => {
              'name': item['name'] ?? '',
              'price': ((item['price'] ?? 0) as num).toDouble(),
              'docId': item['docId'] ?? '',
            },
          )
          .toList(),
    };

    cartController.addToCart(cartItem);

    Get.snackbar(
      "Success!",
      "Burger added to cart.",
      backgroundColor: Colors.white,
      colorText: Colors.black,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Get.off(() => CartScreen());
    });
  }

  Widget _buildBottomBar(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.018,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
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
              Text(
                "Total",
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                  fontSize: 11,
                ),
              ),
              Text(
                "\$${itemsTotal.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(
            width: screenWidth * 0.4,
            height: screenHeight * 0.062,
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