import 'package:flutter/material.dart';
import 'package:food_go/Screens/Products/Product1.dart';
import 'package:food_go/Screens/Products/Product4.dart';
import 'package:food_go/Screens/Products/product2.dart';
import 'package:food_go/Screens/Products/product3.dart';
import 'package:get/get.dart';

class FoodModel {
  final String image;
  final String title;
  final double rating;
  final int id;

  FoodModel({required this.image, required this.title, required this.rating, required this.id});
}

class ProductCard extends StatelessWidget {
  final FoodModel food;

  const ProductCard({super.key, required this.food});

  @override 
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
         print("Card Clicked");
            switch (food.id) {
      case 1:
        Get.to(() => const Product1());
        break;

      case 2:
        Get.to(() => const Product2());
        break;

      case 3:
        Get.to(() => const Product3());
        break;

      case 4:
        Get.to(() => const Product4());
        break;
    }
        // if (food.title == "Cheeseburger Wendy's Burger") {
        //   Get.to(() => Product1());
        // } else if (food.title == "Hamburger Veggie Burger") {
        //   Get.to(() => Product2());
        // } else if (food.title == "Hamburger Chicken Burger") {
        //   Get.to(() => Product3());
        // } else {
        //   Get.to(() => Product4());
        // }
      },

      child: Container(
        padding: const EdgeInsets.all(12),
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
              child: Image.asset(food.image, height: 90, fit: BoxFit.contain),
            ),

            const SizedBox(height: 10),

            Text(
              food.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),

            const Spacer(),

            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  food.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                const Icon(Icons.favorite_border, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
