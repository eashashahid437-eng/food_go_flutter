import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/productscreen.dart'; // ProductDetailScreen ke liye
import 'package:food_go/widgets/product_card.dart'; // FoodModel aur globalFavoriteList ke liye
import 'package:get/get.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    // MediaQueryu utility se screen width & height nikalna
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Favorite Products",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: globalFavoriteList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: AppColors.lightgrey,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  const Text(
                    "No favorite products yet!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const Text(
                    "Add products to your favorites .",
                    style: TextStyle(color: AppColors.lightgrey, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(screenWidth * 0.05),
              itemCount: globalFavoriteList.length,
              itemBuilder: (context, index) {
                final food = globalFavoriteList[index];

                // Favorite item par click karne se Product Detail Screen khulegi
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ProductDetailScreen(food: food));
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Food Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            food.image,
                            width: screenWidth * 0.18,
                            height: screenWidth * 0.18,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.fastfood, size: 50, color: AppColors.lightgrey),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),

                        // Title & Price
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
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                food.productname,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.lightgrey,
                                  fontSize: screenWidth * 0.032,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                "\$${food.price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: AppColors.darkpink,
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.038,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Remove / Unfavorite Button (StatefulBuilder taake UI foran update ho)
                        StatefulBuilder(
                          builder: (context, setStateItem) {
                            return IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: AppColors.darkpink,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  food.isFavorite = false;
                                  globalFavoriteList.remove(food); 
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
