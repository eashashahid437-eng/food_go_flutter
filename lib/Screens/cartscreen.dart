import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/cartcontroller.dart';
import 'package:food_go/Screens/payment_method.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode;
    final Size screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        title: Text(
          "My Cart",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
            fontSize: screenSize.width * 0.05,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Obx(
            () => controller.cartItems.isEmpty
                ? const SizedBox()
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              backgroundColor:
                                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Text(
                                "Clear Cart?",
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.lightwhite
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              content: Text(
                                "Are you sure you want to remove all items from your cart?",
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.darkpink,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.clearCart();
                                    Get.back();
                                  },
                                  child: const Text(
                                    "Clear All",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkpink.withOpacity(0.2)
                                : AppColors.darkpink.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.delete_sweep_rounded,
                                color: AppColors.darkpink,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Clear",
                                style: TextStyle(
                                  color: AppColors.darkpink,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.cartItems.isEmpty) {
          return _buildEmptyCart(isDark);
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                itemCount: controller.cartItems.length,
                itemBuilder: (context, index) {
                  final item = controller.cartItems[index];
                  return _buildStylishCartItem(context, item, index, isDark);
                },
              ),
            ),
            _buildStylishBottomSection(isDark),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkpink.withOpacity(0.2)
                    : AppColors.darkpink.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 64,
                color: AppColors.darkpink,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Explore our menu and add your favorite meals!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylishCartItem(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    bool isDark,
  ) {
    final String image = (item['image'] ?? '').toString();
    final String productName =
        (item['productName'] ?? item['title'] ?? 'Product').toString();
    final String subtitle =
        (item['subtitle'] ?? item['productname'] ?? '').toString();
    final double itemTotal = _toDouble(item['itemTotal']);
    final int quantity = _safeInt(item['quantity']);
    final bool isCustomized = item['isCustomized'] == true;

    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.darkpink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        if (index < controller.cartItems.length) {
          controller.removeItem(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildProductImage(image, isDark),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.lightwhite
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                        height: 1.2,
                      ),
                    ),
                  ],
                  if (isCustomized)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkpink.withOpacity(0.2)
                            : AppColors.darkpink.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Customized",
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.darkpink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${itemTotal.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkpink.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _qtyButton(
                              icon: Icons.remove,
                              onTap: () => controller.decreaseQuantity(index),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 30),
                              child: Text(
                                "$quantity",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.darkpink,
                                ),
                              ),
                            ),
                            _qtyButton(
                              icon: Icons.add,
                              onTap: () => controller.increaseQuantity(index),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String image, bool isDark) {
    if (image.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.transparent,
        child: const Icon(Icons.fastfood, color: Colors.grey, size: 30),
      );
    } else if (image.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: image,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: 80,
          height: 80,
          color: Colors.transparent,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.darkpink,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 80,
          height: 80,
          color: Colors.transparent,
          child: const Icon(Icons.fastfood, color: Colors.grey),
        ),
      );
    } else {
      return Image.asset(
        image,
        width: 80,
        height: 80,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Container(
          width: 80,
          height: 80,
          color: Colors.transparent,
          child: const Icon(Icons.fastfood, color: Colors.grey),
        ),
      );
    }
  }

  Widget _qtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.darkpink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }

  Widget _buildStylishBottomSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Items Price",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                "\$${controller.subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkpink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryLight : const Color(0xFF2B1E2B),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _checkout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "PROCEED TO CHECKOUT",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _checkout() {
    if (controller.cartItems.isEmpty) {
      Get.snackbar(
        "Cart Empty",
        "Please add something to your cart first.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
      () => PaymentMethodScreen(
        totalPrice: controller.subtotal,
        orderItems: controller.cartItems
            .map((item) => Map<String, dynamic>.from(item))
            .toList(),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _safeInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }
}
// import 'package:flutter/material.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Controllers/cartcontroller.dart';
// import 'package:food_go/Screens/payment_method.dart';
// import 'package:get/get.dart';
// import 'package:cached_network_image/cached_network_image.dart';

// class CartScreen extends StatelessWidget {
//   CartScreen({super.key});

//   final CartController controller = Get.isRegistered<CartController>()
//       ? Get.find<CartController>()
//       : Get.put(CartController());

//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = Get.isDarkMode;
//     final Size screenSize = MediaQuery.sizeOf(context);

//     return Scaffold(
//       backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
//       appBar: AppBar(
//         backgroundColor: isDark ? AppColors.backgroundDark : AppColors.surfaceLight,
//         elevation: 0,
//         centerTitle: true,
//         leading: Container(
//           margin: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: IconButton(
//             icon: Icon(
//               Icons.arrow_back_ios_new,
//               color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//               size: 18,
//             ),
//             onPressed: () => Get.back(),
//           ),
//         ),
//         title: Text(
//           "My Cart",
//           style: TextStyle(
//             color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//             fontSize: screenSize.width * 0.05,
//             fontWeight: FontWeight.w700,
//             letterSpacing: 0.5,
//           ),
//         ),
//         actions: [
//           Obx(
//             () => controller.cartItems.isEmpty
//                 ? const SizedBox()
//                 : Center(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 12.0),
//                       child: GestureDetector(
//                         onTap: () {
//                           Get.dialog(
//                             AlertDialog(
//                               backgroundColor:
//                                   isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               title: Text(
//                                 "Clear Cart?",
//                                 style: TextStyle(
//                                   color: isDark
//                                       ? AppColors.lightwhite
//                                       : AppColors.textPrimaryLight,
//                                 ),
//                               ),
//                               content: Text(
//                                 "Are you sure you want to remove all items from your cart?",
//                                 style: TextStyle(
//                                   color: isDark
//                                       ? Colors.grey[300]
//                                       : AppColors.textPrimaryLight,
//                                 ),
//                               ),
//                               actions: [
//                                 TextButton(
//                                   onPressed: () => Get.back(),
//                                   child: const Text(
//                                     "Cancel",
//                                     style: TextStyle(color: Colors.grey),
//                                   ),
//                                 ),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: AppColors.darkpink,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//                                   onPressed: () {
//                                     controller.clearCart();
//                                     Get.back();
//                                   },
//                                   child: const Text(
//                                     "Clear All",
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? AppColors.darkpink.withOpacity(0.2)
//                                 : AppColors.darkpink.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(
//                                 Icons.delete_sweep_rounded,
//                                 color: AppColors.darkpink,
//                                 size: 18,
//                               ),
//                               SizedBox(width: 4),
//                               Text(
//                                 "Clear",
//                                 style: TextStyle(
//                                   color: AppColors.darkpink,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.cartItems.isEmpty) {
//           return _buildEmptyCart(isDark);
//         }

//         return Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
//                 itemCount: controller.cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = controller.cartItems[index];
//                   return _buildStylishCartItem(context, item, index, isDark);
//                 },
//               ),
//             ),
//             _buildStylishBottomSection(isDark),
//           ],
//         );
//       }),
//     );
//   }

//   Widget _buildEmptyCart(bool isDark) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: isDark
//                     ? AppColors.darkpink.withOpacity(0.2)
//                     : AppColors.darkpink.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.shopping_bag_outlined,
//                 size: 64,
//                 color: AppColors.darkpink,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Your cart is empty",
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               "Explore our menu and add your favorite meals!",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isDark ? Colors.grey[400] : Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStylishCartItem(
//     BuildContext context,
//     Map<String, dynamic> item,
//     int index,
//     bool isDark,
//   ) {
//     final String image = (item['image'] ?? '').toString();
//     final String productName =
//         (item['productName'] ?? item['title'] ?? 'Product').toString();
//     final String subtitle =
//         (item['subtitle'] ?? item['productname'] ?? '').toString();
//     final double itemTotal = _toDouble(item['itemTotal']);
//     final int quantity = _safeInt(item['quantity']);
//     final bool isCustomized = item['isCustomized'] == true;

//     return Dismissible(
//       key: ObjectKey(item),
//       direction: DismissDirection.endToStart,
//       background: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.only(right: 20),
//         alignment: Alignment.centerRight,
//         decoration: BoxDecoration(
//           color: AppColors.darkpink,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
//       ),
//       onDismissed: (_) {
//         if (index < controller.cartItems.length) {
//           controller.removeItem(index);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.surfaceDark : Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: isDark
//                   ? Colors.black.withOpacity(0.3)
//                   : Colors.black.withOpacity(0.03),
//               blurRadius: 15,
//               offset: const Offset(0, 6),
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: isDark ? AppColors.surfaceDark : Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: _buildProductImage(image, isDark),
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           productName,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: isDark
//                                 ? AppColors.lightwhite
//                                 : AppColors.textPrimaryLight,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   if (subtitle.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey.shade400,
//                         height: 1.2,
//                       ),
//                     ),
//                   ],
//                   if (isCustomized)
//                     Container(
//                       margin: const EdgeInsets.only(top: 4),
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 6,
//                         vertical: 2,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isDark
//                             ? AppColors.darkpink.withOpacity(0.2)
//                             : AppColors.darkpink.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: const Text(
//                         "Customized",
//                         style: TextStyle(
//                           fontSize: 10,
//                           color: AppColors.darkpink,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "\$${itemTotal.toStringAsFixed(2)}",
//                         style: TextStyle(
//                           color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w800,
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: isDark ? AppColors.surfaceDark : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: AppColors.darkpink.withOpacity(0.2),
//                             width: 1,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             _qtyButton(
//                               icon: Icons.remove,
//                               onTap: () => controller.decreaseQuantity(index),
//                             ),
//                             Container(
//                               constraints: const BoxConstraints(minWidth: 30),
//                               child: Text(
//                                 "$quantity",
//                                 textAlign: TextAlign.center,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 14,
//                                   color: AppColors.darkpink,
//                                 ),
//                               ),
//                             ),
//                             _qtyButton(
//                               icon: Icons.add,
//                               onTap: () => controller.increaseQuantity(index),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductImage(String image, bool isDark) {
//     final Color targetBgColor = isDark ? AppColors.surfaceDark : Colors.white;

//     Widget imageWidget;

//     if (image.isEmpty) {
//       imageWidget = Container(
//         width: 80,
//         height: 80,
//         color: targetBgColor,
//         child: const Icon(Icons.fastfood, color: Colors.grey, size: 30),
//       );
//     } else if (image.startsWith('http')) {
//       imageWidget = CachedNetworkImage(
//         imageUrl: image,
//         width: 80,
//         height: 80,
//         fit: BoxFit.contain,
//         placeholder: (context, url) => Container(
//           width: 80,
//           height: 80,
//           color: targetBgColor,
//           child: const Center(
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: AppColors.darkpink,
//             ),
//           ),
//         ),
//         errorWidget: (context, url, error) => Container(
//           width: 80,
//           height: 80,
//           color: targetBgColor,
//           child: const Icon(Icons.fastfood, color: Colors.grey),
//         ),
//       );
//     } else {
//       imageWidget = Image.asset(
//         image,
//         width: 80,
//         height: 80,
//         fit: BoxFit.contain,
//         errorBuilder: (_, _, _) => Container(
//           width: 80,
//           height: 80,
//           color: targetBgColor,
//           child: const Icon(Icons.fastfood, color: Colors.grey),
//         ),
//       );
//     }

//     return isDark
//         ? ColorFiltered(
//             colorFilter: ColorFilter.mode(
//               targetBgColor,
//               BlendMode.multiply,
//             ),
//             child: imageWidget,
//           )
//         : imageWidget;
//   }

//   Widget _qtyButton({
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: onTap,
//       child: Container(
//         width: 30,
//         height: 30,
//         decoration: BoxDecoration(
//           color: AppColors.darkpink,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(
//           icon,
//           color: Colors.white,
//           size: 14,
//         ),
//       ),
//     );
//   }

//   Widget _buildStylishBottomSection(bool isDark) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 "Total Items Price",
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? AppColors.lightwhite : AppColors.textPrimaryLight,
//                 ),
//               ),
//               Text(
//                 "\$${controller.subtotal.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.darkpink,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isDark ? AppColors.primaryLight : const Color(0xFF2B1E2B),
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//               onPressed: _checkout,
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "PROCEED TO CHECKOUT",
//                     style: TextStyle(
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 0.8,
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Icon(Icons.arrow_forward_rounded, size: 18),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _checkout() {
//     if (controller.cartItems.isEmpty) {
//       Get.snackbar(
//         "Cart Empty",
//         "Please add something to your cart first.",
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     Get.to(
//       () => PaymentMethodScreen(
//         totalPrice: controller.subtotal,
//         orderItems: controller.cartItems
//             .map((item) => Map<String, dynamic>.from(item))
//             .toList(),
//       ),
//     );
//   }

//   double _toDouble(dynamic value) {
//     if (value is num) return value.toDouble();
//     return double.tryParse(value?.toString() ?? '') ?? 0.0;
//   }

//   int _safeInt(dynamic value) {
//     if (value is num) return value.toInt();
//     return int.tryParse(value?.toString() ?? '') ?? 1;
//   }
// }