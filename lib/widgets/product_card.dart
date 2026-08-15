import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/favouritescreencontroller.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/Screens/productscreen.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart'; 

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

    favoriteController = Get.put(
      FavoriteController(),
      permanent: true,
    );
  }

  Future<void> _toggleFavorite() async {
    await favoriteController.toggleFavorite(widget.food);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    final FoodModel food = widget.food;

    final String displayName =
        food.subtitle.isNotEmpty ? food.subtitle : food.productname;

    return Obx(() {
      final bool isFavorite =
          favoriteController.isFavorite(food) || food.isFavorite;

      return GestureDetector(
        onTap: () {
          debugPrint("Product Card Clicked: ${food.title}");
          Get.to(
            () => ProductDetailScreen(
              food: food,
            ),
          );
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
                child: CachedNetworkImage(
                  imageUrl: food.image,
                  height: screenHeight * 0.11,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => SizedBox(
                    height: screenHeight * 0.11,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.darkpink,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.fastfood,
                    size: 60,
                    color: AppColors.lightgrey,
                  ),
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
                  const Icon(
                    Icons.star,
                    color: Colors.orange,
                    size: 16,
                  ),

                  SizedBox(width: screenWidth * 0.01),

                  Text(
                    "\$${food.price.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.035,
                    ),
                  ),

                  const Spacer(),

                  GestureDetector(
                    onTap: () async {
                      await _toggleFavorite();
                    },

                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.01),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : AppColors.lightgrey,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
