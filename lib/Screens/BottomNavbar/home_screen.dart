import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_fonts.dart';
import 'package:food_go/Constants/image_path.dart';
import 'package:food_go/Controllers/homescreencontroller.dart';
import 'package:food_go/Screens/BottomNavbar/person_screen.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/widgets/product_card.dart';
import 'package:food_go/Controllers/profile_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController controller;
  late final ProfileController profileController;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    profileController = Get.put(ProfileController());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);
    final bool isDark = Get.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foodgo',
                  style: AppFonts.lobster(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                SizedBox(height: screenHeight * 0.001),
                Text(
                  'Order Your Favorite Food!',
                  style: GoogleFonts.poppins(
                    color: AppColors.lightgrey,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Obx(() {
              return GestureDetector(
                onTap: () {
                  Get.to(() => const PersonScreen());
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      profileController.profileImageUrl.value.isNotEmpty
                          ? NetworkImage(profileController.profileImageUrl.value)
                          : AssetImage(ImagePath.appbarpic) as ImageProvider,
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
            // Search Bar with Red Focus Border & Cursor
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    cursorColor: AppColors.darkpink,
                    onChanged: (value) {
                      controller.setSearchQuery(value);
                    },
                    style: TextStyle(
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for food...',
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        
                      ),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  searchController.clear();
                                  controller.clearSearch();
                                });
                              },
                            )
                          : const SizedBox.shrink()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.darkpink,
                          width: 1.5,
                        ),
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
                    _showFilterSheet(context, isDark);
                  },
                  child: const Icon(Icons.tune, size: 22, color: Colors.white),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.04),

            // Categories List (Fixed with Obx outside GestureDetector for instant response)
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                itemBuilder: (context, index) {
                  final String category = controller.categories[index];

                  return Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Obx(() {
                      final bool isSelected =
                          controller.selectedCategory.value == category;

                      return GestureDetector(
                        onTap: () {
                          controller.selectCategory(category);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.07,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkpink
                                : (isDark ? AppColors.surfaceDark : AppColors.lightwhite),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.lightwhite : AppColors.lightgrey),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            SizedBox(height: screenHeight * 0.04),
            Obx(() {
              final String currentCategory = controller.selectedCategory.value;

              return StreamBuilder(
                stream: controller.productsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(50),
                        child: Text(
                          'Something went wrong:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Text(
                          'No Product Found!',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    );
                  }

                  final docs = controller.getFilteredProducts(snapshot.data!);

                  if (docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(50.0),
                        child: Text(
                          'no food found!',
                          style: TextStyle(color: Colors.black, fontSize: 16),
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
                      final data = docs[index].data() as Map<String, dynamic>;

                      final FoodModel food = FoodModel(
                        id: index,
                        image: (data['image'] ?? data['imageUrl'] ?? '')
                            .toString(),
                        title: (data['title'] ?? '').toString(),
                        subtitle: (data['subtitle'] ?? '').toString(),
                        productname: (data['productname'] ?? '').toString(),
                        price: _toDouble(data['price'], 4.5),
                        description:
                            (data['description'] ?? 'No description available.')
                                .toString(),
                        spicyLevel: _toDouble(data['spicyLevel'], 2.0),
                        rating: _toDouble(data['rating'], 4.5),
                        reviewCount: _toInt(data['reviewCount'], 10),
                        isFavorite: data['isFavorite'] ?? false,
                      );

                      return ProductCard(food: food);
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                  Text(
                    "Filter Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.lightwhite : Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
              const SizedBox(height: 10),
              Text(
                "Sort By",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? AppColors.lightwhite : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  Obx(() {
                    return ChoiceChip(
                      label: const Text("Price: Low to High"),
                      selected: controller.selectedFilter.value == 'low',
                      selectedColor: AppColors.darkpink.withOpacity(0.2),
                      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: controller.selectedFilter.value == 'low'
                            ? AppColors.darkpink
                            : (isDark ? AppColors.lightwhite : Colors.black87),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectFilter('low');
                        }
                      },
                    );
                  }),
                  Obx(() {
                    return ChoiceChip(
                      label: const Text("Price: High to Low"),
                      selected: controller.selectedFilter.value == 'high',
                      selectedColor: AppColors.darkpink.withOpacity(0.2),
                      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: controller.selectedFilter.value == 'high'
                            ? AppColors.darkpink
                            : (isDark ? AppColors.lightwhite : Colors.black87),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectFilter('high');
                        }
                      },
                    );
                  }),
                  Obx(() {
                    return ChoiceChip(
                      label: const Text("Top Rated"),
                      selected: controller.selectedFilter.value == 'rating',
                      selectedColor: AppColors.darkpink.withOpacity(0.2),
                      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: controller.selectedFilter.value == 'rating'
                            ? AppColors.darkpink
                            : (isDark ? AppColors.lightwhite : Colors.black87),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectFilter('rating');
                        }
                      },
                    );
                  }),
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
  }

  double _toDouble(dynamic value, double defaultValue) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? defaultValue;
  }

  int _toInt(dynamic value, int defaultValue) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? defaultValue;
  }
}
