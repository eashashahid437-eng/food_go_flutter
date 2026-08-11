import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Screens/BottomNavbar/person_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/widgets/product_card.dart';
import 'package:food_go/Controllers/profile_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Combos', 'Sliders', 'Classic', 'Spicy'];

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  
  // Filter state variable ('none', 'low', 'high', 'rating')
  String selectedFilter = 'none'; 

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    
    // Yahan Get.find ki jagah Get.put use kiya hai taake error na aaye aur controller lazmi initialize ho jaye
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Foodgo',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
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
            // Obx se wrap kiya taake image change hone par foran yahan bhi update ho jaye
            Obx(() {
              return GestureDetector(
                onTap: () => Get.to(() => const PersonScreen()),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: controller.profileImageUrl.value.isNotEmpty
                      ? NetworkImage(controller.profileImageUrl.value) as ImageProvider
                      : AssetImage(ImagePath.appbarpic),
                ),
              );
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field & Filter Icon Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase().trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for food...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.02),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkpink,
                    minimumSize: const Size(50, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 20,
                                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Filter Products",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Sort By",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                      spacing: 10,
                                      children: [
                                        ChoiceChip(
                                          label: const Text("Price: Low to High"),
                                          selected: selectedFilter == 'low',
                                          onSelected: (selected) {
                                            setModalState(() {
                                              selectedFilter = 'low';
                                            });
                                          },
                                        ),
                                        ChoiceChip(
                                          label: const Text("Price: High to Low"),
                                          selected: selectedFilter == 'high',
                                          onSelected: (selected) {
                                            setModalState(() {
                                              selectedFilter = 'high';
                                            });
                                          },
                                        ),
                                        ChoiceChip(
                                          label: const Text("Top Rated"),
                                          selected: selectedFilter == 'rating',
                                          onSelected: (selected) {
                                            setModalState(() {
                                              selectedFilter = 'rating';
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.darkpink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {}); 
                                        Navigator.pop(context); 
                                      },
                                      child: const Text(
                                        "Apply Filters",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.tune, size: 22, color: Colors.white),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.04),

            // Horizontal Categories Scroll
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];
                  bool isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.07,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.darkpink : AppColors.lightwhite,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.lightgrey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: screenHeight * 0.04),

            // StreamBuilder for Firebase Data with Flexible Filtering & Sorting
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('product').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(color: AppColors.darkpink),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Text(
                        'Koi product nahi mila!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

                // 1. Flexible Category Filtering (Handles singular/plural mismatch like Combo / Combos automatically)
                if (selectedCategory != 'All') {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String dbCategory = (data['category'] ?? '').toString().toLowerCase().trim();
                    String currentCategory = selectedCategory.toLowerCase().trim();
                    
                    if (currentCategory.endsWith('s') && currentCategory.substring(0, currentCategory.length - 1) == dbCategory) {
                      return true;
                    }
                    if (dbCategory.endsWith('s') && dbCategory.substring(0, dbCategory.length - 1) == currentCategory) {
                      return true;
                    }
                    
                    return dbCategory == currentCategory;
                  }).toList();
                }

                // 2. Search Query Filtering
                if (searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String title = (data['title'] ?? '').toString().toLowerCase();
                    String productName = (data['productname'] ?? '').toString().toLowerCase();
                    return title.contains(searchQuery) || productName.contains(searchQuery);
                  }).toList();
                }

                // 3. Sorting (Low to High, High to Low, Top Rated)
                if (selectedFilter == 'low') {
                  docs.sort((a, b) => ((a.data() as Map<String, dynamic>)['price'] ?? 0)
                      .compareTo((b.data() as Map<String, dynamic>)['price'] ?? 0));
                } else if (selectedFilter == 'high') {
                  docs.sort((a, b) => ((b.data() as Map<String, dynamic>)['price'] ?? 0)
                      .compareTo((a.data() as Map<String, dynamic>)['price'] ?? 0));
                } else if (selectedFilter == 'rating') {
                  docs.sort((a, b) => ((b.data() as Map<String, dynamic>)['rating'] ?? 0)
                      .compareTo((a.data() as Map<String, dynamic>)['rating'] ?? 0));
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: Text(
                        'no food found!',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: docs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.70,
                  ),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    FoodModel food = FoodModel(
                      id: index,
                      image: data['image'] ?? data['imageUrl'] ?? '',
                      title: data['title'] ?? '',
                      subtitle: data['subtitle'] ?? '',
                      productname: data['productname'] ?? '',
                      price: (data['price'] ?? 4.5).toDouble(),
                      description: data['description'] ?? 'No description available.',
                      spicyLevel: (data['spicyLevel'] ?? 2.0).toDouble(),
                      rating: (data['rating'] ?? 4.5).toDouble(),
                      reviewCount: (data['reviewCount'] ?? 10).toInt(),
                      isFavorite: data['isFavorite'] ?? false,
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
