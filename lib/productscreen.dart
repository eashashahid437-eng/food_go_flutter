import 'package:flutter/material.dart';
import 'package:food_go/widgets/product_card.dart'; // Isme FoodModel mojood hai

class ProductDetailScreen extends StatefulWidget {
  final FoodModel food;
  const ProductDetailScreen({super.key, required this.food});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late double spicyVal;
  int portionCount = 1;

  @override
  void initState() {
    super.initState();
    spicyVal = widget.food.spicyLevel; // Firebase se aya hua initial spicy level
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView( // <--- Overflow hatane ke liye scrollable bana diya
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Burger Image from Firebase URL
            Center(
              child: Image.network(
                widget.food.image,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Title & Subtitle/Product Name
            Text(
              widget.food.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.food.productname,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),

            // Rating & Reviews Row
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  widget.food.rating.toStringAsFixed(1),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  "(${widget.food.reviewCount} reviews)",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Spacer(),
                const Text(
                  "14 mins",
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Dynamic Description
            Text(
              widget.food.description,
              style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),

            // Spicy Indicator & Portion Controls
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Spicy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Portion", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: spicyVal,
                    min: 0,
                    max: 5,
                    activeColor: Colors.red,
                    inactiveColor: Colors.red.withOpacity(0.2),
                    onChanged: (val) {
                      setState(() {
                        spicyVal = val; // User apni marzi se slider move kar sakega
                      });
                    },
                  ),
                ),
                const SizedBox(width: 20),
                // Portion Plus Minus Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            if (portionCount > 1) portionCount--;
                          });
                        },
                      ),
                      Text(
                        "$portionCount",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 16),
                        onPressed: () {
                          setState(() {
                            portionCount++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Dynamic Price & Order Now Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${(widget.food.price * portionCount).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F2524),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    // Order action logic here
                  },
                  child: const Text(
                    "ORDER NOW",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
