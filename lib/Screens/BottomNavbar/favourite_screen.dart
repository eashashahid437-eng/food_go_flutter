// import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/favouritescreencontroller.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/Screens/productscreen.dart';
import 'package:food_go/widgets/product_card.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final FavoriteController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<FavoriteController>()
        ? Get.find<FavoriteController>()
        : Get.put(FavoriteController());

    controller.loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : AppColors.lightwhite,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Favorite Products",
          style: TextStyle(
            color: isDark ? AppColors.lightwhite : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.favoriteList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.lightgrey,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "No favorite products yet!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.lightwhite : Colors.black87,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                const Text(
                  "Add products to your favorites.",
                  style: TextStyle(
                    color: AppColors.lightgrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.05),
          itemCount: controller.favoriteList.length,
          itemBuilder: (context, index) {
            final FoodModel food = controller.favoriteList[index];
            final Color cardBgColor = isDark ? Colors.grey[900]! : Colors.white;

            return GestureDetector(
              onTap: () {
                Get.to(() => ProductDetailScreen(food: food));
              },
              child: Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? Colors.black.withOpacity(0.3) 
                          : AppColors.lightgrey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: food.image,
                        width: screenWidth * 0.18,
                        height: screenWidth * 0.18,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => SizedBox(
                          width: screenWidth * 0.18,
                          height: screenWidth * 0.18,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkpink,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.fastfood,
                          size: 50,
                          color: AppColors.lightgrey,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            food.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.04,
                              color: isDark ? AppColors.lightwhite : Colors.black,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),
                          Text(
                            food.subtitle.isNotEmpty
                                ? food.subtitle
                                : food.productname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.lightgrey,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "\$${food.price.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: AppColors.Pink,
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: AppColors.darkpink,
                        size: 24,
                      ),
                      onPressed: () async {
                        await controller.removeFavorite(food);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}





