
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Screens/payment_method.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:get/get.dart';

class BurgerCustomizationScreen extends StatefulWidget {
  final double basePrice;

  const BurgerCustomizationScreen({
    super.key,
    this.basePrice = 10.0,
  });

  @override
  State<BurgerCustomizationScreen> createState() =>
      _BurgerCustomizationScreenState();
}

class _BurgerCustomizationScreenState
    extends State<BurgerCustomizationScreen> {
  double _spicyLevel = 0.2;
  int _portionCount = 1;
  final List<Map<String, dynamic>> _selectedItems = [];

  final List<Map<String, dynamic>> selectedItems = [];

  final CartController cartController = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  double get itemsTotal {
    return selectedItems.fold(
      0.0,
      (sum, item) => sum + ((item['price'] ?? 0) as num).toDouble(),
    );

    return (widget.basePrice + itemsTotal) * _portionCount;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQueryu.getScreenWidth(context);
    final screenHeight = MediaQueryu.getScreenHeight(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white, // Yahan background white kar diya hai
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white, // AppBar bhi white kar di hai
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.black87,
            ),
            onPressed: () {},
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
                      padding: EdgeInsets.only(
                        right: screenWidth * 0.04,
                      ),
                      child: Image.asset(
                        "assets/images/topping.jpg",
                        height: screenHeight * 0.22,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: screenHeight * 0.22,
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.fastfood,
                              color: Colors.orange,
                              size: 80,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

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
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.018,
                        ),

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
                            thumbShape:
                                const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _spicyLevel,
                            onChanged: (v) {
                              setState(() {
                                _spicyLevel = v;
                              });
                            },
                          ),
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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

                        SizedBox(
                          height: screenHeight * 0.018,
                        ),

                        const Text(
                          "Portion",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),

                        SizedBox(
                          height: screenHeight * 0.007,
                        ),

                        Row(
                          children: [
                            _buildCounterBtn(
                              Icons.remove,
                              () => setState(
                                () {
                                  if (_portionCount > 1) {
                                    _portionCount--;
                                  }
                                },
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
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
                              () => setState(
                                () => _portionCount++,
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
                ],
              ),

              SizedBox(
                height: screenHeight * 0.04,
              ),

              _buildStreamSection(
                "Toppings",
                'topping',
              ),

              SizedBox(
                height: screenHeight * 0.03,
              ),

              _buildStreamSection(
                "Side options",
                'side',
              ),

              SizedBox(
                height: screenHeight * 0.025,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(isDark, screenWidth),
    );
  }

  Widget _buildCounterBtn(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.darkpink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildStreamSection(
    String title,
    String category,
  ) {
    final screenHeight = MediaQueryu.getScreenHeight(context);

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

        SizedBox(
          height: screenHeight * 0.015,
        ),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('toppings')
              .where(
                'category',
                isEqualTo: category,
              )
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "No items available yet.",
                  style: TextStyle(
                    color: Colors.grey,
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
                  var data = snapshot.data!.docs[index]
                      .data() as Map<String, dynamic>;

                  data['docId'] =
                      snapshot.data!.docs[index].id;

                  bool isSelected = _selectedItems.any(
                    (i) => i['docId'] == data['docId'],
                  );

                  return _buildItemCard(
                    data,
                    isSelected,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> data,
    bool isSelected,
  ) {
    final screenWidth = MediaQueryu.getScreenWidth(context);

    String name = data['name'] ?? 'Item';
    String imageUrl = data['imageUrl'] ?? '';

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedItems.removeWhere(
              (i) => i['docId'] == data['docId'],
            );
          } else {
            _selectedItems.add(data);
          }
        });
      },
      child: Container(
        width: screenWidth * 0.25,
        margin: EdgeInsets.only(
          right: screenWidth * 0.04,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.darkpink
                : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color:
                    AppColors.darkpink.withOpacity(0.3),
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
                padding: EdgeInsets.all(
                  screenWidth * 0.02,
                ),
                child: Center(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) {
                      return const Icon(
                        Icons.fastfood_rounded,
                        size: 30,
                        color: Colors.orangeAccent,
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
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.015,
                ),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
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
                        color: isSelected
                            ? Colors.white
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: isSelected
                            ? AppColors.darkpink
                            : Colors.white,
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

  Widget _buildBottomBar() {
    final screenWidth = MediaQueryu.getScreenWidth(context);
    final screenHeight =
        MediaQueryu.getScreenHeight(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.018,
      ),
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
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
              onPressed: () {
                if (_selectedItems.isEmpty) {
                  Get.snackbar(
                    "Oops!",
                    "Please select at least one topping.",
                    backgroundColor: Colors.white,
                    colorText: Colors.white,
                    snackPosition:
                        SnackPosition.BOTTOM,
                  );
                } else {
                  Get.snackbar(
                    "Success!",
                    "Order placed successfully!",
                    backgroundColor: Colors.white,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );

                  Future.delayed(
                    const Duration(seconds: 1),
                    () {
                      Get.to(
                        () => PaymentMethodScreen(
                          totalPrice:
                              _calculatedTotal,
                        ),
                      );
                    },
                  );
                }
              },
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

//  import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Screens/payment_method.dart';
// import 'package:get/get.dart';

// class BurgerCustomizationScreen extends StatefulWidget {
//   final double basePrice;
//   const BurgerCustomizationScreen({super.key, this.basePrice = 10.0});

//   @override
//   State<BurgerCustomizationScreen> createState() =>
//       _BurgerCustomizationScreenState();
// }

// class _BurgerCustomizationScreenState extends State<BurgerCustomizationScreen> {
//   double _spicyLevel = 0.2; // 0.0 (Mild) to 1.0 (Hot)
//   int _portionCount = 1;
//   final List<Map<String, dynamic>> _selectedItems = [];

//   double get _calculatedTotal {
//     double itemsTotal = _selectedItems.fold(
//       0.0,
//       (sum, item) => sum + (item['price'] ?? 0.0),
//     );
//     return (widget.basePrice + itemsTotal) * _portionCount;
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search_rounded, color: Colors.black87),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(screenWidth * 0.05),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Burger Image (Cleaner)
//                   Expanded(
//                     flex: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 20),
//                       child: Image.asset(
//                         "assets/images/topping.jpg", // Asset path should be correct
//                         height: 180,
//                         fit: BoxFit.contain,
//                         errorBuilder: (context, error, stackTrace) => Container(
//                           height: 180,
//                           color: Colors.grey.shade100,
//                           child: const Icon(
//                             Icons.fastfood,
//                             color: Colors.orange,
//                             size: 80,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   // Controls Section
//                   Expanded(
//                     flex: 3,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Customize Your Burger",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const Text(
//                           "to Your Tastes. Ultimate Experience",
//                           style: TextStyle(fontSize: 11, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 15),
//                         const Text(
//                           "Spicy",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         SliderTheme(
//                           data: SliderTheme.of(context).copyWith(
//                             activeTrackColor: AppColors.darkpink,
//                             inactiveTrackColor: Colors.red.shade100,
//                             thumbColor: AppColors.darkpink,
//                             trackHeight: 4,
//                             thumbShape: const RoundSliderThumbShape(
//                               enabledThumbRadius: 6,
//                             ),
//                           ),
//                           child: Slider(
//                             value: _spicyLevel,
//                             onChanged: (v) => setState(() => _spicyLevel = v),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: const [
//                             Text(
//                               "Mild",
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ), // Green for Mild
//                             Text(
//                               "Hot",
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.red,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 15),
//                         const Text(
//                           "Portion",
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 12,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         Row(
//                           children: [
//                             _buildCounterBtn(
//                               Icons.remove,
//                               () => setState(
//                                 () =>
//                                     _portionCount > 1 ? _portionCount-- : null,
//                               ),
//                             ),
//                             Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 15,
//                               ),
//                               child: Text(
//                                 "$_portionCount",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                             ),
//                             _buildCounterBtn(
//                               Icons.add,
//                               () => setState(() => _portionCount++),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 35),

//               // --- TOPPINGS SECTION ---
//               _buildStreamSection("Toppings", 'topping'),
//               const SizedBox(height: 25),

//               // --- SIDE OPTIONS SECTION ---
//               _buildStreamSection("Side options", 'side'),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }

//   Widget _buildCounterBtn(IconData icon, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: AppColors.darkpink,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//     );
//   }

//   Widget _buildStreamSection(String title, String category) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 12),
//         StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('toppings')
//               .where('category', isEqualTo: category)
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return const Padding(
//                 padding: EdgeInsets.only(left: 10),
//                 child: Text(
//                   "No items available yet.",
//                   style: TextStyle(color: Colors.grey, fontSize: 11),
//                 ),
//               );
//             }
//             return SizedBox(
//               height: 110,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   var data =
//                       snapshot.data!.docs[index].data() as Map<String, dynamic>;
//                   data['docId'] = snapshot
//                       .data!
//                       .docs[index]
//                       .id; // Document ID save kar lein
//                   bool isSelected = _selectedItems.any(
//                     (i) => i['docId'] == data['docId'],
//                   );
//                   return _buildItemCard(data, isSelected);
//                 },
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildItemCard(Map<String, dynamic> data, bool isSelected) {
//     String name = data['name'] ?? 'Item';
//     String imageUrl = data['imageUrl'] ?? '';

//     return GestureDetector(
//       onTap: () => setState(() {
//         if (isSelected) {
//           _selectedItems.removeWhere((i) => i['docId'] == data['docId']);
//         } else {
//           _selectedItems.add(data);
//         }
//       }),
//       child: Container(
//         width: 95,
//         margin: const EdgeInsets.only(right: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: isSelected ? AppColors.darkpink : Colors.grey.shade200,
//             width: 2,
//           ), // Thicker border on selection
//           boxShadow: [
//             if (isSelected)
//               BoxShadow(
//                 color: AppColors.darkpink.withOpacity(0.3),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             if (!isSelected)
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 6,
//                 offset: const Offset(0, 3),
//               ),
//           ],
//         ),
//         child: Column(
//           children: [
//             // Image Container
//             Expanded(
//               flex: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Center(
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.contain,
//                     errorBuilder: (c, e, s) => const Icon(
//                       Icons.fastfood_rounded,
//                       size: 30,
//                       color: Colors.orangeAccent,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             // Dark Label Container with '+' Icon
//             Expanded(
//               flex: 1,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 6),
//                 decoration: const BoxDecoration(
//                   color: Colors.black87,
//                   borderRadius: BorderRadius.vertical(
//                     bottom: Radius.circular(14),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Item Name
//                     Flexible(
//                       child: Text(
//                         name,
//                         textAlign: TextAlign.left,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 9,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                     // Red '+' Icon (Figma Style)
//                     Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: isSelected ? Colors.white : Colors.red,
//                         shape: BoxShape.circle,
//                       ), // Icon background changes color
//                       child: Icon(
//                         Icons.add,
//                         size: 12,
//                         color: isSelected ? AppColors.darkpink : Colors.white,
//                       ), // Icon color changes
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Total Price
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Total",
//                 style: TextStyle(color: Colors.grey, fontSize: 11),
//               ),
//               Text(
//                 "\$${_calculatedTotal.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),

//           SizedBox(
//             width: 160,
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.darkpink,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 elevation: 2,
//               ),

//               onPressed: () {
//                 if (_selectedItems.isEmpty) {
//                   Get.snackbar(
//                     "Oops!",
//                     "Please select at least one topping.",
//                     backgroundColor: Colors.orange,
//                     colorText: Colors.white,
//                     snackPosition: SnackPosition.BOTTOM,
//                   );
//                 } else {
//                   Get.snackbar(
//                     "Success!",
//                     "Order placed successfully!",
//                     backgroundColor: Colors.white,
//                     colorText: Colors.black,
//                     snackPosition: SnackPosition.TOP,
//                   );

//                   Future.delayed(const Duration(seconds: 1), () {
//                     Get.to(
//                       () => PaymentMethodScreen(totalPrice: _calculatedTotal),
//                     );
//                   });
//                 }
//               },

//               child: const Text(
//                 "Order Now",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
