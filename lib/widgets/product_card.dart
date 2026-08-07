
import 'package:flutter/material.dart';
import 'package:food_go/Screens/Products/Product1.dart';
import 'package:food_go/Screens/Products/Product4.dart';
import 'package:food_go/Screens/Products/product2.dart';
import 'package:food_go/Screens/Products/product3.dart';
import 'package:get/get.dart';

class FoodModel {
  final String image;
  final String title;
  final String name; // <--- Yeh nayi field add kar di hai
  final double price;
  final int id;

  FoodModel({
    required this.image,
    required this.title,
    required this.name, // <--- Constructor mein bhi add kar diya
    required this.price,
    required this.id,
  });
}

class ProductCard extends StatelessWidget {
  final FoodModel food;

  const ProductCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("Card Clicked Index: ${food.id}");
        // Firebase indices 0, 1, 2, 3 hotay hain
        switch (food.id) {
          case 0:
            Get.to(() => const Product1());
            break;
          case 1:
            Get.to(() => const Product2());
            break;
          case 2:
            Get.to(() => const Product3());
            break;
          case 3:
            Get.to(() => const Product4());
            break;
          default:
            Get.to(() => const Product1());
        }
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
              child: Image.network(
                food.image,
                height: 90,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.fastfood,
                    size: 60,
                    color: Colors.grey,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 90,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Yahan par Column laga diya hai taaki title upar aur subtitle neeche aaye
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, // Pehli line Bold
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  food.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey, // Doosri line Grey aur normal
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  food.price.toStringAsFixed(2),
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