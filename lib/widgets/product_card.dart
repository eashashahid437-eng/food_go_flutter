  
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/favouritescreencontroller.dart';
import 'package:food_go/Screens/productscreen.dart';
import 'package:get/get.dart';

List<FoodModel> globalFavoriteList = [];

class FoodModel {
  final String image;
  final String title;
  final String productname;
  final double price;
  final int id;
  final String description;
  final double spicyLevel;
  final double rating;
  final int reviewCount;
  final String subtitle;

  bool isFavorite;

  FoodModel({
    required this.image,
    required this.title,
    this.productname = "",
    required this.price,
    required this.id,
    required this.description,
    required this.spicyLevel,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
    this.subtitle = "",
  });
}

class ProductCard extends StatefulWidget {
  final FoodModel food;

  const ProductCard({
    super.key,
    required this.food,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late final FavoriteController favoriteController;

  @override
  void initState() {
    super.initState();

    favoriteController = Get.isRegistered<FavoriteController>()
        ? Get.find<FavoriteController>()
        : Get.put(FavoriteController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final food = widget.food;

    final String displayName =
        food.subtitle.isNotEmpty ? food.subtitle : food.productname;

    final bool isDark = Get.isDarkMode;

    final double imageHeight = screenHeight * 0.12;

    return GestureDetector(
      onTap: () {
        Get.to(
          () => ProductDetailScreen(food: food),
        );
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.35) : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: food.image,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    placeholder: (context, url) {
                      return SizedBox(
                        height: imageHeight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.darkpink,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return SizedBox(
                        height: imageHeight,
                        child: Icon(
                          Icons.fastfood,
                          size: 35,
                          color:
                              isDark ? Colors.grey[400] : AppColors.lightgrey,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: screenHeight * 0.002,
                  ),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : AppColors.lightgrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: screenHeight * 0.006,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    food.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.036,
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                  ),
                ),
                StatefulBuilder(
                  builder: (context, setStateCard) {
                    final bool isFav = favoriteController.isFavorite(food);

                    return GestureDetector(
                      onTap: () async {
                        await favoriteController.toggleFavorite(food);
                        setStateCard(() {});
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                          screenWidth * 0.01,
                        ),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav
                              ? Colors.red
                              : (isDark
                                  ? Colors.grey[400]
                                  : AppColors.lightgrey),
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${food.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.035,
                    color: AppColors.darkpink,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      food.rating.toString(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}





//   import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:food_go/Constants/app_colors.dart';
// import 'package:food_go/Controllers/favouritescreencontroller.dart';
// import 'package:food_go/Screens/productscreen.dart';
// import 'package:get/get.dart';

// List<FoodModel> globalFavoriteList = [];

// class FoodModel {
//   final String image;
//   final String title;
//   final String productname;
//   final double price;
//   final int id;
//   final String description;
//   final double spicyLevel;
//   final double rating;
//   final int reviewCount;
//   final String subtitle;

//   bool isFavorite;

//   FoodModel({
//     required this.image,
//     required this.title,
//     this.productname = "",
//     required this.price,
//     required this.id,
//     required this.description,
//     required this.spicyLevel,
//     required this.rating,
//     required this.reviewCount,
//     this.isFavorite = false,
//     this.subtitle = "",
//   });
// }

// class ProductCard extends StatefulWidget {
//   final FoodModel food;

//   const ProductCard({
//     super.key,
//     required this.food,
//   });

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   late final FavoriteController favoriteController;

//   @override
//   void initState() {
//     super.initState();

//     favoriteController = Get.isRegistered<FavoriteController>()
//         ? Get.find<FavoriteController>()
//         : Get.put(FavoriteController(), permanent: true);
//   }

//   // Cloudinary auto-trim helper method
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
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double screenHeight = MediaQuery.of(context).size.height;

//     final food = widget.food;

//     final String displayName =
//         food.subtitle.isNotEmpty ? food.subtitle : food.productname;

//     final bool isDark = Get.isDarkMode;

//     // Perfectly balanced image height for grid cards
//     final double imageHeight = screenHeight * 0.115;

//     return GestureDetector(
//       onTap: () {
//         print("Card Clicked Index: ${food.id}");

//         Get.to(
//           () => ProductDetailScreen(food: food),
//         );
//       },
//       child: Container(
//         padding: EdgeInsets.all(screenWidth * 0.03),
//         decoration: BoxDecoration(
//           color: isDark ? AppColors.surfaceDark : Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           boxShadow: [
//             BoxShadow(
//               color: isDark ? Colors.black.withOpacity(0.35) : Colors.black12,
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Column(
//                 children: [
//                   CachedNetworkImage(
//                     imageUrl: _getOptimizedImageUrl(food.image),
//                     height: imageHeight,
//                     fit: BoxFit.contain,
//                     placeholder: (context, url) {
//                       return SizedBox(
//                         height: imageHeight,
//                         child: const Center(
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                             color: AppColors.darkpink,
//                           ),
//                         ),
//                       );
//                     },
//                     errorWidget: (context, url, error) {
//                       return SizedBox(
//                         height: imageHeight,
//                         child: Icon(
//                           Icons.fastfood,
//                           size: 35,
//                           color:
//                               isDark ? Colors.grey[400] : AppColors.lightgrey,
//                         ),
//                       );
//                     },
//                   ),
//                   SizedBox(
//                     height: screenHeight * 0.002,
//                   ),
//                   Text(
//                     displayName,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: isDark ? Colors.grey[400] : AppColors.lightgrey,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: screenHeight * 0.006,
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     food.title,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: screenWidth * 0.036,
//                       color: isDark ? AppColors.lightwhite : Colors.black,
//                     ),
//                   ),
//                 ),
//                 StatefulBuilder(
//                   builder: (context, setStateCard) {
//                     final bool isFav = favoriteController.isFavorite(food);

//                     return GestureDetector(
//                       onTap: () async {
//                         await favoriteController.toggleFavorite(food);
//                         setStateCard(() {});
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.all(
//                           screenWidth * 0.01,
//                         ),
//                         child: Icon(
//                           isFav ? Icons.favorite : Icons.favorite_border,
//                           color: isFav
//                               ? Colors.red
//                               : (isDark
//                                   ? Colors.grey[400]
//                                   : AppColors.lightgrey),
//                           size: 20,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             const Spacer(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "\$${food.price.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: screenWidth * 0.035,
//                     color: AppColors.darkpink,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.star,
//                       color: Colors.amber,
//                       size: 14,
//                     ),
//                     const SizedBox(width: 3),
//                     Text(
//                       food.rating.toString(),
//                       style: TextStyle(
//                         fontSize: screenWidth * 0.03,
//                         fontWeight: FontWeight.w600,
//                         color: isDark ? Colors.grey[300] : Colors.grey[700],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//   // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/material.dart';
// // import 'package:food_go/Constants/app_colors.dart';
// // import 'package:food_go/Controllers/favouritescreencontroller.dart';
// // import 'package:food_go/Screens/productscreen.dart';
// // import 'package:get/get.dart';

// // List<FoodModel> globalFavoriteList = [];

// // class FoodModel {
// //   final String image;
// //   final String title;
// //   final String productname;
// //   final double price;
// //   final int id;
// //   final String description;
// //   final double spicyLevel;
// //   final double rating;
// //   final int reviewCount;
// //   final String subtitle;

// //   bool isFavorite;

// //   FoodModel({
// //     required this.image,
// //     required this.title,
// //     this.productname = "",
// //     required this.price,
// //     required this.id,
// //     required this.description,
// //     required this.spicyLevel,
// //     required this.rating,
// //     required this.reviewCount,
// //     this.isFavorite = false,
// //     this.subtitle = "",
// //   });
// // }

// // class ProductCard extends StatefulWidget {
// //   final FoodModel food;

// //   const ProductCard({
// //     super.key,
// //     required this.food,
// //   });

// //   @override
// //   State<ProductCard> createState() => _ProductCardState();
// // }

// // class _ProductCardState extends State<ProductCard> {
// //   late final FavoriteController favoriteController;

// //   @override
// //   void initState() {
// //     super.initState();

// //     favoriteController = Get.isRegistered<FavoriteController>()
// //         ? Get.find<FavoriteController>()
// //         : Get.put(FavoriteController(), permanent: true);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenWidth = MediaQuery.of(context).size.width;
// //     final double screenHeight = MediaQuery.of(context).size.height;

// //     final food = widget.food;

// //     final String displayName =
// //         food.subtitle.isNotEmpty ? food.subtitle : food.productname;

// //     final bool isDark = Get.isDarkMode;

// //     return GestureDetector(
// //       onTap: () {
// //         print("Card Clicked Index: ${food.id}");

// //         Get.to(
// //           () => ProductDetailScreen(food: food),
// //         );
// //       },
// //       child: Container(
// //         padding: EdgeInsets.all(screenWidth * 0.03),
// //         decoration: BoxDecoration(
// //           color: isDark ? AppColors.surfaceDark : Colors.white,
// //           borderRadius: BorderRadius.circular(18),
// //           boxShadow: [
// //             BoxShadow(
// //               color: isDark ? Colors.black.withOpacity(0.35) : Colors.black12,
// //               blurRadius: 8,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Center(
// //               child: Column(
// //                 children: [
// //                   // Direct CachedNetworkImage load without destructive blending
// //                   CachedNetworkImage(
// //                     imageUrl: food.image,
// //                     height: screenHeight * 0.09,
// //                     fit: BoxFit.contain,
// //                     placeholder: (context, url) {
// //                       return SizedBox(
// //                         height: screenHeight * 0.09,
// //                         child: const Center(
// //                           child: CircularProgressIndicator(
// //                             strokeWidth: 2,
// //                             color: AppColors.darkpink,
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                     errorWidget: (context, url, error) {
// //                       return SizedBox(
// //                         height: screenHeight * 0.09,
// //                         child: Icon(
// //                           Icons.fastfood,
// //                           size: 35,
// //                           color:
// //                               isDark ? Colors.grey[400] : AppColors.lightgrey,
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   SizedBox(
// //                     height: screenHeight * 0.002,
// //                   ),
// //                   Text(
// //                     displayName,
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: TextStyle(
// //                       color: isDark ? Colors.grey[400] : AppColors.lightgrey,
// //                       fontSize: 12,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             SizedBox(
// //               height: screenHeight * 0.006,
// //             ),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                     food.title,
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: screenWidth * 0.036,
// //                       color: isDark ? AppColors.lightwhite : Colors.black,
// //                     ),
// //                   ),
// //                 ),
// //                 StatefulBuilder(
// //                   builder: (context, setStateCard) {
// //                     final bool isFav = favoriteController.isFavorite(food);

// //                     return GestureDetector(
// //                       onTap: () async {
// //                         await favoriteController.toggleFavorite(food);
// //                         setStateCard(() {});
// //                       },
// //                       child: Padding(
// //                         padding: EdgeInsets.all(
// //                           screenWidth * 0.01,
// //                         ),
// //                         child: Icon(
// //                           isFav ? Icons.favorite : Icons.favorite_border,
// //                           color: isFav
// //                               ? Colors.red
// //                               : (isDark
// //                                   ? Colors.grey[400]
// //                                   : AppColors.lightgrey),
// //                           size: 20,
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //             const Spacer(),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   "\$${food.price.toStringAsFixed(2)}",
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: screenWidth * 0.035,
// //                     color: AppColors.darkpink,
// //                   ),
// //                 ),
// //                 Row(
// //                   children: [
// //                     const Icon(
// //                       Icons.star,
// //                       color: Colors.amber,
// //                       size: 14,
// //                     ),
// //                     const SizedBox(width: 3),
// //                     Text(
// //                       food.rating.toString(),
// //                       style: TextStyle(
// //                         fontSize: screenWidth * 0.03,
// //                         fontWeight: FontWeight.w600,
// //                         color: isDark ? Colors.grey[300] : Colors.grey[700],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// // // import 'package:cached_network_image/cached_network_image.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:food_go/Constants/app_colors.dart';
// // // import 'package:food_go/Controllers/favouritescreencontroller.dart';
// // // import 'package:food_go/Screens/productscreen.dart';
// // // import 'package:get/get.dart';


// // // List<FoodModel> globalFavoriteList = [];

// // // class FoodModel {
// // //   final String image;
// // //   final String title;
// // //   final String productname;
// // //   final double price;
// // //   final int id;
// // //   final String description;
// // //   final double spicyLevel;
// // //   final double rating;
// // //   final int reviewCount;
// // //   final String subtitle;

// // //   bool isFavorite;

// // //   FoodModel({
// // //     required this.image,
// // //     required this.title,
// // //     this.productname = "",
// // //     required this.price,
// // //     required this.id,
// // //     required this.description,
// // //     required this.spicyLevel,
// // //     required this.rating,
// // //     required this.reviewCount,
// // //     this.isFavorite = false,
// // //     this.subtitle = "",
// // //   });
// // // }

// // // class ProductCard extends StatefulWidget {
// // //   final FoodModel food;

// // //   const ProductCard({
// // //     super.key,
// // //     required this.food,
// // //   });

// // //   @override
// // //   State<ProductCard> createState() => _ProductCardState();
// // // }

// // // class _ProductCardState extends State<ProductCard> {
// // //   late final FavoriteController favoriteController;

// // //   @override
// // //   void initState() {
// // //     super.initState();

// // //     favoriteController = Get.isRegistered<FavoriteController>()
// // //         ? Get.find<FavoriteController>()
// // //         : Get.put(FavoriteController(), permanent: true);
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final double screenWidth = MediaQuery.of(context).size.width;
// // //     final double screenHeight = MediaQuery.of(context).size.height;

// // //     final food = widget.food;

// // //     final String displayName =
// // //         food.subtitle.isNotEmpty ? food.subtitle : food.productname;

// // //     final bool isDark = Get.isDarkMode;

// // //     return GestureDetector(
// // //       onTap: () {
// // //         print("Card Clicked Index: ${food.id}");

// // //         Get.to(
// // //           () => ProductDetailScreen(food: food),
// // //         );
// // //       },
// // //       child: Container(
// // //         padding: EdgeInsets.all(screenWidth * 0.03),
// // //         decoration: BoxDecoration(
// // //           color: isDark ? AppColors.surfaceDark : Colors.white,
// // //           borderRadius: BorderRadius.circular(18),
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: isDark ? Colors.black.withOpacity(0.35) : Colors.black12,
// // //               blurRadius: 8,
// // //               offset: const Offset(0, 4),
// // //             ),
// // //           ],
// // //         ),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Center(
// // //               child: Column(
// // //                 children: [
// // //                   // White background remove karne ke liye ColorFiltered aur BlendMode wrap kia gaya hai
// // //                   ColorFiltered(
// // //                     colorFilter: ColorFilter.mode(
// // //                       isDark ? AppColors.surfaceDark : Colors.white,
// // //                       BlendMode.multiply,
// // //                     ),
// // //                     child: CachedNetworkImage(
// // //                       imageUrl: food.image,
// // //                       height: screenHeight * 0.09,
// // //                       fit: BoxFit.contain,
// // //                       placeholder: (context, url) {
// // //                         return SizedBox(
// // //                           height: screenHeight * 0.09,
// // //                           child: const Center(
// // //                             child: CircularProgressIndicator(
// // //                               strokeWidth: 2,
// // //                               color: AppColors.darkpink,
// // //                             ),
// // //                           ),
// // //                         );
// // //                       },
// // //                       errorWidget: (context, url, error) {
// // //                         return SizedBox(
// // //                           height: screenHeight * 0.09,
// // //                           child: Icon(
// // //                             Icons.fastfood,
// // //                             size: 35,
// // //                             color: isDark ? Colors.grey[400] : AppColors.lightgrey,
// // //                           ),
// // //                         );
// // //                       },
// // //                     ),
// // //                   ),
// // //                   SizedBox(
// // //                     height: screenHeight * 0.002,
// // //                   ),
// // //                   Text(
// // //                     displayName,
// // //                     maxLines: 1,
// // //                     overflow: TextOverflow.ellipsis,
// // //                     style: TextStyle(
// // //                       color: isDark ? Colors.grey[400] : AppColors.lightgrey,
// // //                       fontSize: 12,
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //             SizedBox(
// // //               height: screenHeight * 0.006,
// // //             ),
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Text(
// // //                     food.title,
// // //                     maxLines: 1,
// // //                     overflow: TextOverflow.ellipsis,
// // //                     style: TextStyle(
// // //                       fontWeight: FontWeight.bold,
// // //                       fontSize: screenWidth * 0.036,
// // //                       color: isDark ? AppColors.lightwhite : Colors.black,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 StatefulBuilder(
// // //                   builder: (context, setStateCard) {
// // //                     final bool isFav = favoriteController.isFavorite(food);

// // //                     return GestureDetector(
// // //                       onTap: () async {
// // //                         await favoriteController.toggleFavorite(food);
// // //                         setStateCard(() {});
// // //                       },
// // //                       child: Padding(
// // //                         padding: EdgeInsets.all(
// // //                           screenWidth * 0.01,
// // //                         ),
// // //                         child: Icon(
// // //                           isFav ? Icons.favorite : Icons.favorite_border,
// // //                           color: isFav
// // //                               ? Colors.red
// // //                               : (isDark
// // //                                   ? Colors.grey[400]
// // //                                   : AppColors.lightgrey),
// // //                           size: 20,
// // //                         ),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //               ],
// // //             ),
// // //             const Spacer(),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Text(
// // //                   "\$${food.price.toStringAsFixed(2)}",
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: screenWidth * 0.035,
// // //                     color: AppColors.darkpink,
// // //                   ),
// // //                 ),
// // //                 Row(
// // //                   children: [
// // //                     const Icon(
// // //                       Icons.star,
// // //                       color: Colors.amber,
// // //                       size: 14,
// // //                     ),
// // //                     const SizedBox(width: 3),
// // //                     Text(
// // //                       food.rating.toString(),
// // //                       style: TextStyle(
// // //                         fontSize: screenWidth * 0.03,
// // //                         fontWeight: FontWeight.w600,
// // //                         color: isDark ? Colors.grey[300] : Colors.grey[700],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }