import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/profile_screen.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/widgets/product_card.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foodgo',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                const Text(
                  'Order Your Favorite Food!',
                  style: TextStyle(
                    color: AppColors.lightgrey,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.to(() => const ProfileScreen());
              },
              child: CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(ImagePath.appbarpic),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.05,
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field & Filter button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for food...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkpink,
                    minimumSize: const Size(50, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Handle filter button press
                  },
                  child: const Icon(Icons.tune, size: 22, color: Colors.white),
                ),
              ],
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.05),

            // Horizontal Categories Scroll
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      print("All tapped");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.09,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.darkpink,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'All',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                  GestureDetector(
                    onTap: () {
                      print("Combos tapped");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.09,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Combos',
                        style: TextStyle(
                          color: AppColors.lightgrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                  GestureDetector(
                    onTap: () {
                      print("Sliders tapped");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.09,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Sliders',
                        style: TextStyle(
                          color: AppColors.lightgrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                  GestureDetector(
                    onTap: () {
                      print("Classic tapped");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.09,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Classic',
                        style: TextStyle(
                          color: AppColors.lightgrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                  GestureDetector(
                    onTap: () {
                      print("Spicy tapped");
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.09,
                        vertical: MediaQuery.of(context).size.height * 0.01,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightwhite,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Spicy',
                        style: TextStyle(
                          color: AppColors.lightgrey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.06),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.05),

            // Firebase Firestore StreamBuilder GridView
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('product').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.darkpink),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Firebase mein koi product nahi milaa!'),
                  );
                }

                final docs = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 15),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    FoodModel food = FoodModel(
                      id: index,
                      image: data['imageUrl'] ?? '',
                      title: data['title'] ?? '',
                      name: data['name'] ?? '',
                      price: (data['price'] ?? 4.5).toDouble(),
                    );

                    return ProductCard(food: food);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
