import 'package:flutter/material.dart'; // Dynamic detail screen ka import
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/productscreen.dart';
import 'package:get/get.dart';

// Global list jo saare favorite items ko store karegi
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

class ProductCard extends StatelessWidget {
  final FoodModel food;

  const ProductCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    // MediaQueryu utility se screen width & height nikalna
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    String displayName = food.subtitle.isNotEmpty
        ? food.subtitle
        : food.productname;

    return GestureDetector(
      onTap: () {
        print("Card Clicked Index: ${food.id}");
        Get.to(() => ProductDetailScreen(food: food));
      },
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                food.image,
                height: screenHeight * 0.11,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.fastfood,
                    size: 60,
                    color: AppColors.lightgrey,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: screenHeight * 0.11,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkpink,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.012),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: screenHeight * 0.003),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.lightgrey,
                    fontSize: screenWidth * 0.032,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                SizedBox(width: screenWidth * 0.01),
                Text(
                  "\$${food.price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.035,
                  ),
                ),
                const Spacer(),
                StatefulBuilder(
                  builder: (context, setStateCard) {
                    return GestureDetector(
                      onTap: () {
                        setStateCard(() {
                          food.isFavorite = !food.isFavorite;

                          if (food.isFavorite) {
                            if (!globalFavoriteList.contains(food)) {
                              globalFavoriteList.add(food);
                            }
                          } else {
                            globalFavoriteList.remove(food);
                          }
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(screenWidth * 0.01),
                        child: Icon(
                          food.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: food.isFavorite
                              ? Colors.red
                              : AppColors.lightgrey,
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
