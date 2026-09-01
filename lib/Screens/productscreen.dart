

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/cartcontroller.dart';
import 'package:food_go/Controllers/productscreencontroller.dart';
import 'package:food_go/Screens/cartscreen.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/widgets/product_card.dart';
import 'package:get/get.dart';

class ProductDetailScreen extends StatelessWidget {
  final FoodModel food;

  const ProductDetailScreen({
    super.key,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    final bool isDark = Get.isDarkMode;

    final ProductDetailController controller = Get.put(
      ProductDetailController(
        food: food,
      ),
    );

    final CartController cartController = Get.put(
      CartController(),
      permanent: true,
    );

    final Color bgColor = isDark ? Colors.black : Colors.white;

    // Figma matching display height
    final double heroImageHeight = screenHeight * 0.28;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.lightwhite : Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                  onPressed: () {
                    Get.to(() => CartScreen());
                  },
                ),
                if (cartController.cartItems.isNotEmpty)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.darkpink,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartController.cartItems.length}',
                        style: const TextStyle(
                          color: AppColors.lightwhite,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.01,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: heroImageHeight,
                width: screenWidth,
                child: CachedNetworkImage(
                  imageUrl: food.image,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => SizedBox(
                    height: heroImageHeight,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkpink,
                      ),
                    ),
                  ),
                  errorWidget: (context, error, stackTrace) {
                    return SizedBox(
                      height: heroImageHeight,
                      child: const Icon(
                        Icons.fastfood,
                        size: 80,
                        color: AppColors.lightgrey,
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              food.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : Colors.black,
              ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Text(
              food.productname,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.lightgrey,
              ),
            ),
            SizedBox(height: screenHeight * 0.015),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  food.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "(${food.reviewCount} reviews)",
                  style: const TextStyle(
                    color: AppColors.lightgrey,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                const Text(
                  "14 mins",
                  style: TextStyle(
                    color: AppColors.lightgrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              food.description,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.lightwhite.withOpacity(0.7) : Colors.black54,
                height: 1.4,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Spicy",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                ),
                Text(
                  "Portion",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.lightwhite : Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor: AppColors.darkpink,
                          inactiveTrackColor: isDark ? Colors.grey[800] : AppColors.lightPink,
                          thumbColor: AppColors.darkpink,
                          overlayColor: AppColors.darkpink.withOpacity(0.10),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 15,
                          ),
                        ),
                        child: Obx(
                          () => Slider(
                            value: controller.spicyVal.value.clamp(0.0, 5.0),
                            min: 0,
                            max: 5,
                            onChanged: controller.changeSpicy,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Mild",
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Hot",
                              style: TextStyle(
                                color: AppColors.darkpink,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: screenWidth * 0.05),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.darkpink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.remove,
                          color: AppColors.lightwhite,
                          size: 20,
                        ),
                        onPressed: controller.decreasePortion,
                      ),
                    ),
                    Container(
                      width: 35,
                      alignment: Alignment.center,
                      child: Obx(
                        () => Text(
                          "${controller.portionCount.value}",
                          style: TextStyle(
                            color: isDark ? AppColors.lightwhite : Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.darkpink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.lightwhite,
                          size: 20,
                        ),
                        onPressed: controller.increasePortion,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04),
            Row(
              children: [
                Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkpink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "\$${controller.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightwhite,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
                        foregroundColor: AppColors.lightwhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        final Map<String, dynamic> item = {
                          'cartId':
                              '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
                          'productId': food.id.toString(),
                          'productName': food.title,
                          'subtitle': food.productname,
                          'image': food.image,
                          'price': food.price,
                          'quantity': controller.portionCount.value,
                          'spicyLevel': controller.spicyVal.value,
                          'itemTotal': controller.totalPrice,
                        };

                        cartController.addToCart(item);

                        Get.snackbar(
                          "Added to Cart",
                          "${food.title} added to your cart.",
                          backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
                          colorText: AppColors.lightwhite,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "ADD TO CART",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Obx(
              () {
                if (cartController.cartItems.isEmpty) {
                  return const SizedBox();
                }

                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.to(() => CartScreen());
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.darkpink,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "VIEW CART (${cartController.cartItems.length})",
                      style: const TextStyle(
                        color: AppColors.darkpink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}


// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Controllers/cartcontroller.dart';
// import 'package:food_go/Controllers/productscreencontroller.dart';
// import 'package:food_go/Screens/cartscreen.dart';
// import 'package:food_go/utility/responsive.dart';
// import 'package:food_go/widgets/product_card.dart';
// import 'package:get/get.dart';

// class ProductDetailScreen extends StatelessWidget {
//   final FoodModel food;

//   const ProductDetailScreen({
//     super.key,
//     required this.food,
//   });

//   // Cloudinary transparent space trimmer
//   String _getOptimizedImageUrl(String url) {
//     if (url.contains('/upload/')) {
//       return url.replaceAll(
//         '/upload/',
//         '/upload/c_trim,q_auto,f_auto/',
//       );
//     }
//     return url;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQueryu.getScreenWidth(context);
//     final double screenHeight = MediaQueryu.getScreenHeight(context);
//     final bool isDark = Get.isDarkMode;

//     final ProductDetailController controller = Get.put(
//       ProductDetailController(
//         food: food,
//       ),
//     );

//     final CartController cartController = Get.put(
//       CartController(),
//       permanent: true,
//     );

//     final Color bgColor = isDark ? Colors.black : Colors.white;

//     // Figma ke hisab se larger hero height
//     final double imageSize = screenHeight * 0.32;

//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         backgroundColor: bgColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back,
//             color: isDark ? AppColors.lightwhite : Colors.black,
//           ),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//         actions: [
//           Obx(
//             () => Stack(
//               children: [
//                 IconButton(
//                   icon: Icon(
//                     Icons.shopping_cart_outlined,
//                     color: isDark ? AppColors.lightwhite : Colors.black,
//                   ),
//                   onPressed: () {
//                     Get.to(() => CartScreen());
//                   },
//                 ),
//                 if (cartController.cartItems.isNotEmpty)
//                   Positioned(
//                     right: 5,
//                     top: 5,
//                     child: Container(
//                       padding: const EdgeInsets.all(4),
//                       decoration: const BoxDecoration(
//                         color: AppColors.darkpink,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Text(
//                         '${cartController.cartItems.length}',
//                         style: const TextStyle(
//                           color: AppColors.lightwhite,
//                           fontSize: 9,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.symmetric(
//           horizontal: screenWidth * 0.05,
//           vertical: screenHeight * 0.01,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: SizedBox(
//                 height: imageSize,
//                 width: screenWidth,
//                 child: CachedNetworkImage(
//                   imageUrl: _getOptimizedImageUrl(food.image),
//                   fit: BoxFit.contain,
//                   placeholder: (context, url) => Center(
//                     child: SizedBox(
//                       height: imageSize,
//                       width: imageSize,
//                       child: const Center(
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: AppColors.darkpink,
//                         ),
//                       ),
//                     ),
//                   ),
//                   errorWidget: (context, error, stackTrace) {
//                     return SizedBox(
//                       height: imageSize,
//                       width: imageSize,
//                       child: const Icon(
//                         Icons.fastfood,
//                         size: 100,
//                         color: AppColors.lightgrey,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Text(
//               food.title,
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? AppColors.lightwhite : Colors.black,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.005),
//             Text(
//               food.productname,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: AppColors.lightgrey,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.015),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.star,
//                   color: Colors.orange,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 4),
//                 Text(
//                   food.rating.toStringAsFixed(1),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: isDark ? AppColors.lightwhite : Colors.black,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   "(${food.reviewCount} reviews)",
//                   style: const TextStyle(
//                     color: AppColors.lightgrey,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const Spacer(),
//                 const Text(
//                   "14 mins",
//                   style: TextStyle(
//                     color: AppColors.lightgrey,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Text(
//               food.description,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isDark ? AppColors.lightwhite.withOpacity(0.7) : Colors.black54,
//                 height: 1.4,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.03),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Spicy",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: isDark ? AppColors.lightwhite : Colors.black,
//                   ),
//                 ),
//                 Text(
//                   "Portion",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: isDark ? AppColors.lightwhite : Colors.black,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.01),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SliderTheme(
//                         data: SliderTheme.of(context).copyWith(
//                           trackHeight: 4,
//                           activeTrackColor: AppColors.darkpink,
//                           inactiveTrackColor: isDark ? Colors.grey[800] : AppColors.lightPink,
//                           thumbColor: AppColors.darkpink,
//                           overlayColor: AppColors.darkpink.withOpacity(0.10),
//                           thumbShape: const RoundSliderThumbShape(
//                             enabledThumbRadius: 7,
//                           ),
//                           overlayShape: const RoundSliderOverlayShape(
//                             overlayRadius: 15,
//                           ),
//                         ),
//                         child: Obx(
//                           () => Slider(
//                             value: controller.spicyVal.value.clamp(0.0, 5.0),
//                             min: 0,
//                             max: 5,
//                             onChanged: controller.changeSpicy,
//                           ),
//                         ),
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 5,
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Mild",
//                               style: TextStyle(
//                                 color: Color(0xFF4CAF50),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             Text(
//                               "Hot",
//                               style: TextStyle(
//                                 color: AppColors.darkpink,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.05),
//                 Row(
//                   children: [
//                     Container(
//                       width: 42,
//                       height: 42,
//                       decoration: BoxDecoration(
//                         color: AppColors.darkpink,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: IconButton(
//                         padding: EdgeInsets.zero,
//                         icon: const Icon(
//                           Icons.remove,
//                           color: AppColors.lightwhite,
//                           size: 20,
//                         ),
//                         onPressed: controller.decreasePortion,
//                       ),
//                     ),
//                     Container(
//                       width: 35,
//                       alignment: Alignment.center,
//                       child: Obx(
//                         () => Text(
//                           "${controller.portionCount.value}",
//                           style: TextStyle(
//                             color: isDark ? AppColors.lightwhite : Colors.black87,
//                             fontSize: 17,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(
//                       width: 42,
//                       height: 42,
//                       decoration: BoxDecoration(
//                         color: AppColors.darkpink,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: IconButton(
//                         padding: EdgeInsets.zero,
//                         icon: const Icon(
//                           Icons.add,
//                           color: AppColors.lightwhite,
//                           size: 20,
//                         ),
//                         onPressed: controller.increasePortion,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.04),
//             Row(
//               children: [
//                 Obx(
//                   () => Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.05,
//                       vertical: screenHeight * 0.015,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.darkpink,
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Text(
//                       "\$${controller.totalPrice.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.lightwhite,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 15),
//                 Expanded(
//                   child: SizedBox(
//                     height: 52,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
//                         foregroundColor: AppColors.lightwhite,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                       ),
//                       onPressed: () {
//                         final Map<String, dynamic> item = {
//                           'cartId':
//                               '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
//                           'productId': food.id.toString(),
//                           'productName': food.title,
//                           'subtitle': food.productname,
//                           'image': food.image,
//                           'price': food.price,
//                           'quantity': controller.portionCount.value,
//                           'spicyLevel': controller.spicyVal.value,
//                           'itemTotal': controller.totalPrice,
//                         };

//                         cartController.addToCart(item);

//                         Get.snackbar(
//                           "Added to Cart",
//                           "${food.title} added to your cart.",
//                           backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
//                           colorText: AppColors.lightwhite,
//                           snackPosition: SnackPosition.BOTTOM,
//                           duration: const Duration(seconds: 2),
//                         );
//                       },
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.shopping_cart_outlined,
//                             size: 20,
//                           ),
//                           SizedBox(width: 8),
//                           Text(
//                             "ADD TO CART",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Obx(
//               () {
//                 if (cartController.cartItems.isEmpty) {
//                   return const SizedBox();
//                 }

//                 return SizedBox(
//                   width: double.infinity,
//                   height: 48,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Get.to(() => CartScreen());
//                     },
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(
//                         color: AppColors.darkpink,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       "VIEW CART (${cartController.cartItems.length})",
//                       style: const TextStyle(
//                         color: AppColors.darkpink,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             SizedBox(height: screenHeight * 0.02),
//           ],
//         ),
//       ),
//     );
//   }
// }
// // import 'package:flutter/material.dart';
// // import 'package:food_go/Constants/app_colors.dart';
// // import 'package:food_go/Controllers/cartcontroller.dart';
// // import 'package:food_go/Controllers/productscreencontroller.dart';
// // import 'package:food_go/Screens/cartscreen.dart';
// // import 'package:food_go/utility/responsive.dart';
// // import 'package:food_go/widgets/product_card.dart';
// // import 'package:get/get.dart';
// // import 'package:cached_network_image/cached_network_image.dart';

// // class ProductDetailScreen extends StatelessWidget {
// //   final FoodModel food;

// //   const ProductDetailScreen({
// //     super.key,
// //     required this.food,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQueryu.getScreenWidth(context);
// //     final double screenHeight = MediaQueryu.getScreenHeight(context);
// //     final bool isDark = Get.isDarkMode;

// //     final ProductDetailController controller = Get.put(
// //       ProductDetailController(
// //         food: food,
// //       ),
// //     );

// //     final CartController cartController = Get.put(
// //       CartController(),
// //       permanent: true,
// //     );

// //     final Color bgColor = isDark ? Colors.black : Colors.white;

// //     return Scaffold(
// //       backgroundColor: bgColor,
// //       appBar: AppBar(
// //         backgroundColor: bgColor,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(
// //             Icons.arrow_back,
// //             color: isDark ? AppColors.lightwhite : Colors.black,
// //           ),
// //           onPressed: () {
// //             Get.back();
// //           },
// //         ),
// //         actions: [
// //           Obx(
// //             () => Stack(
// //               children: [
// //                 IconButton(
// //                   icon: Icon(
// //                     Icons.shopping_cart_outlined,
// //                     color: isDark ? AppColors.lightwhite : Colors.black,
// //                   ),
// //                   onPressed: () {
// //                     Get.to(() => CartScreen());
// //                   },
// //                 ),
// //                 if (cartController.cartItems.isNotEmpty)
// //                   Positioned(
// //                     right: 5,
// //                     top: 5,
// //                     child: Container(
// //                       padding: const EdgeInsets.all(4),
// //                       decoration: const BoxDecoration(
// //                         color: AppColors.darkpink,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child: Text(
// //                         '${cartController.cartItems.length}',
// //                         style: const TextStyle(
// //                           color: AppColors.lightwhite,
// //                           fontSize: 9,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.symmetric(
// //           horizontal: screenWidth * 0.05,
// //           vertical: screenHeight * 0.02,
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Center(
// //               child: Container(
// //                 padding: const EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.transparent,
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: ClipRRect(
// //                   borderRadius: BorderRadius.circular(16),
// //                   child: CachedNetworkImage(
// //                     imageUrl: food.image,
// //                     height: screenHeight * 0.22,
// //                     width: screenHeight * 0.22,
// //                     fit: BoxFit.contain,
// //                     placeholder: (context, url) => SizedBox(
// //                       height: screenHeight * 0.22,
// //                       width: screenHeight * 0.22,
// //                       child: const Center(
// //                         child: CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           color: AppColors.darkpink,
// //                         ),
// //                       ),
// //                     ),
// //                     errorWidget: (context, error, stackTrace) {
// //                       return const SizedBox(
// //                         height: 220,
// //                         width: 220,
// //                         child: Icon(
// //                           Icons.fastfood,
// //                           size: 80,
// //                           color: AppColors.lightgrey,
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: screenHeight * 0.03),
// //             Text(
// //               food.title,
// //               style: TextStyle(
// //                 fontSize: 22,
// //                 fontWeight: FontWeight.bold,
// //                 color: isDark ? AppColors.lightwhite : Colors.black,
// //               ),
// //             ),
// //             SizedBox(height: screenHeight * 0.005),
// //             Text(
// //               food.productname,
// //               style: const TextStyle(
// //                 fontSize: 16,
// //                 color: AppColors.lightgrey,
// //               ),
// //             ),
// //             SizedBox(height: screenHeight * 0.015),
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.star,
// //                   color: Colors.orange,
// //                   size: 18,
// //                 ),
// //                 const SizedBox(width: 4),
// //                 Text(
// //                   food.rating.toStringAsFixed(1),
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14,
// //                     color: isDark ? AppColors.lightwhite : Colors.black,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   "(${food.reviewCount} reviews)",
// //                   style: const TextStyle(
// //                     color: AppColors.lightgrey,
// //                     fontSize: 13,
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 const Text(
// //                   "14 mins",
// //                   style: TextStyle(
// //                     color: AppColors.lightgrey,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: screenHeight * 0.02),
// //             Text(
// //               food.description,
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: isDark ? AppColors.lightwhite.withOpacity(0.7) : Colors.black54,
// //                 height: 1.4,
// //               ),
// //             ),
// //             SizedBox(height: screenHeight * 0.03),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   "Spicy",
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: isDark ? AppColors.lightwhite : Colors.black,
// //                   ),
// //                 ),
// //                 Text(
// //                   "Portion",
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: isDark ? AppColors.lightwhite : Colors.black,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: screenHeight * 0.01),
// //             Row(
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: [
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       SliderTheme(
// //                         data: SliderTheme.of(context).copyWith(
// //                           trackHeight: 4,
// //                           activeTrackColor: AppColors.darkpink,
// //                           inactiveTrackColor: isDark ? Colors.grey[800] : AppColors.lightPink,
// //                           thumbColor: AppColors.darkpink,
// //                           overlayColor: AppColors.darkpink.withOpacity(0.10),
// //                           thumbShape: const RoundSliderThumbShape(
// //                             enabledThumbRadius: 7,
// //                           ),
// //                           overlayShape: const RoundSliderOverlayShape(
// //                             overlayRadius: 15,
// //                           ),
// //                         ),
// //                         child: Obx(
// //                           () => Slider(
// //                             value: controller.spicyVal.value.clamp(0.0, 5.0),
// //                             min: 0,
// //                             max: 5,
// //                             onChanged: controller.changeSpicy,
// //                           ),
// //                         ),
// //                       ),
// //                       const Padding(
// //                         padding: EdgeInsets.symmetric(
// //                           horizontal: 5,
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             Text(
// //                               "Mild",
// //                               style: TextStyle(
// //                                 color: Color(0xFF4CAF50),
// //                                 fontSize: 13,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                             Text(
// //                               "Hot",
// //                               style: TextStyle(
// //                                 color: AppColors.darkpink,
// //                                 fontSize: 13,
// //                                 fontWeight: FontWeight.w500,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 SizedBox(width: screenWidth * 0.05),
// //                 Row(
// //                   children: [
// //                     Container(
// //                       width: 42,
// //                       height: 42,
// //                       decoration: BoxDecoration(
// //                         color: AppColors.darkpink,
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       child: IconButton(
// //                         padding: EdgeInsets.zero,
// //                         icon: const Icon(
// //                           Icons.remove,
// //                           color: AppColors.lightwhite,
// //                           size: 20,
// //                         ),
// //                         onPressed: controller.decreasePortion,
// //                       ),
// //                     ),
// //                     Container(
// //                       width: 35,
// //                       alignment: Alignment.center,
// //                       child: Obx(
// //                         () => Text(
// //                           "${controller.portionCount.value}",
// //                           style: TextStyle(
// //                             color: isDark ? AppColors.lightwhite : Colors.black87,
// //                             fontSize: 17,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                     Container(
// //                       width: 42,
// //                       height: 42,
// //                       decoration: BoxDecoration(
// //                         color: AppColors.darkpink,
// //                         borderRadius: BorderRadius.circular(10),
// //                       ),
// //                       child: IconButton(
// //                         padding: EdgeInsets.zero,
// //                         icon: const Icon(
// //                           Icons.add,
// //                           color: AppColors.lightwhite,
// //                           size: 20,
// //                         ),
// //                         onPressed: controller.increasePortion,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: screenHeight * 0.04),
// //             Row(
// //               children: [
// //                 Obx(
// //                   () => Container(
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: screenWidth * 0.05,
// //                       vertical: screenHeight * 0.015,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: AppColors.darkpink,
// //                       borderRadius: BorderRadius.circular(14),
// //                     ),
// //                     child: Text(
// //                       "\$${controller.totalPrice.toStringAsFixed(2)}",
// //                       style: const TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                         color: AppColors.lightwhite,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 15),
// //                 Expanded(
// //                   child: SizedBox(
// //                     height: 52,
// //                     child: ElevatedButton(
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
// //                         foregroundColor: AppColors.lightwhite,
// //                         elevation: 0,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(14),
// //                         ),
// //                       ),
// //                       onPressed: () {
// //                         final Map<String, dynamic> item = {
// //                           'cartId':
// //                               '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
// //                           'productId': food.id.toString(),
// //                           'productName': food.title,
// //                           'subtitle': food.productname,
// //                           'image': food.image,
// //                           'price': food.price,
// //                           'quantity': controller.portionCount.value,
// //                           'spicyLevel': controller.spicyVal.value,
// //                           'itemTotal': controller.totalPrice,
// //                         };

// //                         cartController.addToCart(item);

// //                         Get.snackbar(
// //                           "Added to Cart",
// //                           "${food.title} added to your cart.",
// //                           backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
// //                           colorText: AppColors.lightwhite,
// //                           snackPosition: SnackPosition.BOTTOM,
// //                           duration: const Duration(seconds: 2),
// //                         );
// //                       },
// //                       child: const Row(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Icon(
// //                             Icons.shopping_cart_outlined,
// //                             size: 20,
// //                           ),
// //                           SizedBox(width: 8),
// //                           Text(
// //                             "ADD TO CART",
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             SizedBox(height: screenHeight * 0.02),
// //             Obx(
// //               () {
// //                 if (cartController.cartItems.isEmpty) {
// //                   return const SizedBox();
// //                 }

// //                 return SizedBox(
// //                   width: double.infinity,
// //                   height: 48,
// //                   child: OutlinedButton(
// //                     onPressed: () {
// //                       Get.to(() => CartScreen());
// //                     },
// //                     style: OutlinedButton.styleFrom(
// //                       side: const BorderSide(
// //                         color: AppColors.darkpink,
// //                       ),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                     ),
// //                     child: Text(
// //                       "VIEW CART (${cartController.cartItems.length})",
// //                       style: const TextStyle(
// //                         color: AppColors.darkpink,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //             SizedBox(height: screenHeight * 0.02),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // import 'package:food_go/Constants/app_colors.dart';
// // // import 'package:food_go/Controllers/cartcontroller.dart';
// // // import 'package:food_go/Controllers/productscreencontroller.dart';
// // // import 'package:food_go/Screens/cartscreen.dart';
// // // import 'package:food_go/utility/responsive.dart';
// // // import 'package:food_go/widgets/product_card.dart';
// // // import 'package:get/get.dart';
// // // import 'package:cached_network_image/cached_network_image.dart';

// // // class ProductDetailScreen extends StatelessWidget {
// // //   final FoodModel food;

// // //   const ProductDetailScreen({
// // //     super.key,
// // //     required this.food,
// // //   });

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final double screenWidth = MediaQueryu.getScreenWidth(context);
// // //     final double screenHeight = MediaQueryu.getScreenHeight(context);
// // //     final bool isDark = Get.isDarkMode;

// // //     final ProductDetailController controller = Get.put(
// // //       ProductDetailController(
// // //         food: food,
// // //       ),
// // //     );

// // //     final CartController cartController = Get.put(
// // //       CartController(),
// // //       permanent: true,
// // //     );

// // //     return Scaffold(
// // //       backgroundColor: isDark ? Colors.black : Colors.white,
// // //       appBar: AppBar(
// // //         backgroundColor: isDark ? Colors.black : Colors.white,
// // //         elevation: 0,
// // //         leading: IconButton(
// // //           icon: Icon(
// // //             Icons.arrow_back,
// // //             color: isDark ? AppColors.lightwhite : Colors.black,
// // //           ),
// // //           onPressed: () {
// // //             Get.back();
// // //           },
// // //         ),
// // //         actions: [
// // //           Obx(
// // //             () => Stack(
// // //               children: [
// // //                 IconButton(
// // //                   icon: Icon(
// // //                     Icons.shopping_cart_outlined,
// // //                     color: isDark ? AppColors.lightwhite : Colors.black,
// // //                   ),
// // //                   onPressed: () {
// // //                     Get.to(() => CartScreen());
// // //                   },
// // //                 ),
// // //                 if (cartController.cartItems.isNotEmpty)
// // //                   Positioned(
// // //                     right: 5,
// // //                     top: 5,
// // //                     child: Container(
// // //                       padding: const EdgeInsets.all(4),
// // //                       decoration: const BoxDecoration(
// // //                         color: AppColors.darkpink,
// // //                         shape: BoxShape.circle,
// // //                       ),
// // //                       child: Text(
// // //                         '${cartController.cartItems.length}',
// // //                         style: const TextStyle(
// // //                           color: AppColors.lightwhite,
// // //                           fontSize: 9,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //       body: SingleChildScrollView(
// // //         padding: EdgeInsets.symmetric(
// // //           horizontal: screenWidth * 0.05,
// // //           vertical: screenHeight * 0.02,
// // //         ),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Center(
// // //               child: Container(
// // //                 padding: const EdgeInsets.all(12),
// // //                 decoration: BoxDecoration(
// // //                   // Shadow aur border bilkul khatam kar diye hain
// // //                   color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// // //                   borderRadius: BorderRadius.circular(20),
// // //                 ),
// // //                 child: ClipRRect(
// // //                   borderRadius: BorderRadius.circular(16),
// // //                   child: CachedNetworkImage(
// // //                     imageUrl: food.image,
// // //                     height: screenHeight * 0.22,
// // //                     width: screenHeight * 0.22,
// // //                     fit: BoxFit.cover,
// // //                     placeholder: (context, url) => SizedBox(
// // //                       height: screenHeight * 0.22,
// // //                       width: screenHeight * 0.22,
// // //                       child: const Center(
// // //                         child: CircularProgressIndicator(
// // //                           strokeWidth: 2,
// // //                           color: AppColors.darkpink,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     errorWidget: (context, error, stackTrace) {
// // //                       return const SizedBox(
// // //                         height: 220,
// // //                         width: 220,
// // //                         child: Icon(
// // //                           Icons.fastfood,
// // //                           size: 80,
// // //                           color: AppColors.lightgrey,
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             SizedBox(height: screenHeight * 0.03),
// // //             Text(
// // //               food.title,
// // //               style: TextStyle(
// // //                 fontSize: 22,
// // //                 fontWeight: FontWeight.bold,
// // //                 color: isDark ? AppColors.lightwhite : Colors.black,
// // //               ),
// // //             ),
// // //             SizedBox(height: screenHeight * 0.005),
// // //             Text(
// // //               food.productname,
// // //               style: TextStyle(
// // //                 fontSize: 16,
// // //                 color: AppColors.lightgrey,
// // //               ),
// // //             ),
// // //             SizedBox(height: screenHeight * 0.015),
// // //             Row(
// // //               children: [
// // //                 const Icon(
// // //                   Icons.star,
// // //                   color: Colors.orange,
// // //                   size: 18,
// // //                 ),
// // //                 const SizedBox(width: 4),
// // //                 Text(
// // //                   food.rating.toStringAsFixed(1),
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 14,
// // //                     color: isDark ? AppColors.lightwhite : Colors.black,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 8),
// // //                 Text(
// // //                   "(${food.reviewCount} reviews)",
// // //                   style: TextStyle(
// // //                     color: AppColors.lightgrey,
// // //                     fontSize: 13,
// // //                   ),
// // //                 ),
// // //                 const Spacer(),
// // //                 const Text(
// // //                   "14 mins",
// // //                   style: TextStyle(
// // //                     color: AppColors.lightgrey,
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.w500,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             SizedBox(height: screenHeight * 0.02),
// // //             Text(
// // //               food.description,
// // //               style: TextStyle(
// // //                 fontSize: 14,
// // //                 color: isDark ? AppColors.lightwhite.withOpacity(0.7) : Colors.black54,
// // //                 height: 1.4,
// // //               ),
// // //             ),
// // //             SizedBox(height: screenHeight * 0.03),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Text(
// // //                   "Spicy",
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 16,
// // //                     color: isDark ? AppColors.lightwhite : Colors.black,
// // //                   ),
// // //                 ),
// // //                 Text(
// // //                   "Portion",
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 16,
// // //                     color: isDark ? AppColors.lightwhite : Colors.black,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             SizedBox(height: screenHeight * 0.01),
// // //             Row(
// // //               crossAxisAlignment: CrossAxisAlignment.center,
// // //               children: [
// // //                 Expanded(
// // //                   child: Column(
// // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // //                     children: [
// // //                       SliderTheme(
// // //                         data: SliderTheme.of(context).copyWith(
// // //                           trackHeight: 4,
// // //                           activeTrackColor: AppColors.darkpink,
// // //                           inactiveTrackColor: isDark ? Colors.grey[800] : AppColors.lightPink,
// // //                           thumbColor: AppColors.darkpink,
// // //                           overlayColor: AppColors.darkpink.withOpacity(0.10),
// // //                           thumbShape: const RoundSliderThumbShape(
// // //                             enabledThumbRadius: 7,
// // //                           ),
// // //                           overlayShape: const RoundSliderOverlayShape(
// // //                             overlayRadius: 15,
// // //                           ),
// // //                         ),
// // //                         child: Obx(
// // //                           () => Slider(
// // //                             value: controller.spicyVal.value.clamp(0.0, 5.0),
// // //                             min: 0,
// // //                             max: 5,
// // //                             onChanged: controller.changeSpicy,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                       const Padding(
// // //                         padding: EdgeInsets.symmetric(
// // //                           horizontal: 5,
// // //                         ),
// // //                         child: Row(
// // //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                           children: [
// // //                             Text(
// // //                               "Mild",
// // //                               style: TextStyle(
// // //                                 color: Color(0xFF4CAF50),
// // //                                 fontSize: 13,
// // //                                 fontWeight: FontWeight.w500,
// // //                               ),
// // //                             ),
// // //                             Text(
// // //                               "Hot",
// // //                               style: TextStyle(
// // //                                 color: AppColors.darkpink,
// // //                                 fontSize: 13,
// // //                                 fontWeight: FontWeight.w500,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //                 SizedBox(width: screenWidth * 0.05),
// // //                 Row(
// // //                   children: [
// // //                     Container(
// // //                       width: 42,
// // //                       height: 42,
// // //                       decoration: BoxDecoration(
// // //                         color: AppColors.darkpink,
// // //                         borderRadius: BorderRadius.circular(10),
// // //                       ),
// // //                       child: IconButton(
// // //                         padding: EdgeInsets.zero,
// // //                         icon: const Icon(
// // //                           Icons.remove,
// // //                           color: AppColors.lightwhite,
// // //                           size: 20,
// // //                         ),
// // //                         onPressed: controller.decreasePortion,
// // //                       ),
// // //                     ),
// // //                     Container(
// // //                       width: 35,
// // //                       alignment: Alignment.center,
// // //                       child: Obx(
// // //                         () => Text(
// // //                           "${controller.portionCount.value}",
// // //                           style: TextStyle(
// // //                             color: isDark ? AppColors.lightwhite : Colors.black87,
// // //                             fontSize: 17,
// // //                             fontWeight: FontWeight.w500,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     Container(
// // //                       width: 42,
// // //                       height: 42,
// // //                       decoration: BoxDecoration(
// // //                         color: AppColors.darkpink,
// // //                         borderRadius: BorderRadius.circular(10),
// // //                       ),
// // //                       child: IconButton(
// // //                         padding: EdgeInsets.zero,
// // //                         icon: const Icon(
// // //                           Icons.add,
// // //                           color: AppColors.lightwhite,
// // //                           size: 20,
// // //                         ),
// // //                         onPressed: controller.increasePortion,
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //             SizedBox(height: screenHeight * 0.04),
// // //             Row(
// // //               children: [
// // //                 Obx(
// // //                   () => Container(
// // //                     padding: EdgeInsets.symmetric(
// // //                       horizontal: screenWidth * 0.05,
// // //                       vertical: screenHeight * 0.015,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       color: AppColors.darkpink,
// // //                       borderRadius: BorderRadius.circular(14),
// // //                     ),
// // //                     child: Text(
// // //                       "\$${controller.totalPrice.toStringAsFixed(2)}",
// // //                       style: const TextStyle(
// // //                         fontSize: 20,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: AppColors.lightwhite,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 15),
// // //                 Expanded(
// // //                   child: SizedBox(
// // //                     height: 52,
// // //                     child: ElevatedButton(
// // //                       style: ElevatedButton.styleFrom(
// // //                         backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
// // //                         foregroundColor: AppColors.lightwhite,
// // //                         elevation: 0,
// // //                         shape: RoundedRectangleBorder(
// // //                           borderRadius: BorderRadius.circular(14),
// // //                         ),
// // //                       ),
// // //                       onPressed: () {
// // //                         final Map<String, dynamic> item = {
// // //                           'cartId':
// // //                               '${food.id}_${DateTime.now().millisecondsSinceEpoch}',
// // //                           'productId': food.id.toString(),
// // //                           'productName': food.title,
// // //                           'subtitle': food.productname,
// // //                           'image': food.image,
// // //                           'price': food.price,
// // //                           'quantity': controller.portionCount.value,
// // //                           'spicyLevel': controller.spicyVal.value,
// // //                           'itemTotal': controller.totalPrice,
// // //                         };

// // //                         cartController.addToCart(item);

// // //                         Get.snackbar(
// // //                           "Added to Cart",
// // //                           "${food.title} added to your cart.",
// // //                           backgroundColor: isDark ? Colors.grey[800] : const Color(0xFF30252F),
// // //                           colorText: AppColors.lightwhite,
// // //                           snackPosition: SnackPosition.BOTTOM,
// // //                           duration: const Duration(seconds: 2),
// // //                         );
// // //                       },
// // //                       child: const Row(
// // //                         mainAxisAlignment: MainAxisAlignment.center,
// // //                         children: [
// // //                           Icon(
// // //                             Icons.shopping_cart_outlined,
// // //                             size: 20,
// // //                           ),
// // //                           SizedBox(width: 8),
// // //                           Text(
// // //                             "ADD TO CART",
// // //                             style: TextStyle(
// // //                               fontWeight: FontWeight.bold,
// // //                               fontSize: 14,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             SizedBox(height: screenHeight * 0.02),
// // //             Obx(
// // //               () {
// // //                 if (cartController.cartItems.isEmpty) {
// // //                   return const SizedBox();
// // //                 }

// // //                 return SizedBox(
// // //                   width: double.infinity,
// // //                   height: 48,
// // //                   child: OutlinedButton(
// // //                     onPressed: () {
// // //                       Get.to(() => CartScreen());
// // //                     },
// // //                     style: OutlinedButton.styleFrom(
// // //                       side: const BorderSide(
// // //                         color: AppColors.darkpink,
// // //                       ),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(12),
// // //                       ),
// // //                     ),
// // //                     child: Text(
// // //                       "VIEW CART (${cartController.cartItems.length})",
// // //                       style: const TextStyle(
// // //                         color: AppColors.darkpink,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //             SizedBox(height: screenHeight * 0.02),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
