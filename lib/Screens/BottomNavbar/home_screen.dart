import 'package:flutter/material.dart';
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

    controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
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
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  top: screenHeight * 0.015,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foodgo',
                            style: GoogleFonts.lobster(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.002,
                          ),
                          Text(
                            'Order Your Favorite Food!',
                            style: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : AppColors.lightgrey,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => GestureDetector(
                        onTap: () {
                          Get.to(() => const PersonScreen());
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: profileController
                                  .profileImageUrl.value.isNotEmpty
                              ? NetworkImage(
                                  profileController.profileImageUrl.value,
                                )
                              : AssetImage(
                                  ImagePath.appbarpic,
                                ) as ImageProvider,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.035,
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                        ),
                        child: TextField(
                          controller: searchController,
                          cursorColor: AppColors.darkpink,
                          onChanged: (value) {
                            controller.setSearchQuery(value);
                            setState(() {});
                          },
                          style: TextStyle(
                            color: isDark
                                ? AppColors.lightwhite
                                : Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'Search for food...',
                            hintStyle: GoogleFonts.poppins(
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark
                                  ? Colors.grey.shade300
                                  : Colors.black87,
                              size: 30,
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: isDark
                                          ? Colors.grey.shade300
                                          : Colors.black54,
                                    ),
                                    onPressed: () {
                                      searchController.clear();
                                      controller.clearSearch();
                                      setState(() {});
                                    },
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 17,
                              horizontal: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: AppColors.darkpink,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth * 0.025,
                    ),
                    SizedBox(
                      width: 58,
                      height: 58,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkpink,
                          elevation: 0,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          _showFilterSheet(context, isDark);
                        },
                        child: const Icon(
                          Icons.tune,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.035,
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final String category =
                        controller.categories[index];

                    return Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: Obx(
                        () {
                          final bool isSelected =
                              controller.selectedCategory.value ==
                                  category;

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
                                    : (isDark
                                        ? AppColors.surfaceDark
                                        : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.lightwhite
                                          : Colors.grey.shade700),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.035,
              ),
            ),

            Obx(
              () {
                controller.selectedCategory.value;
                controller.selectedFilter.value; // Yeh line add ki gayi hai taake filter change par UI update ho

                return StreamBuilder(
                  stream: controller.productsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(50),
                            child: CircularProgressIndicator(
                              color: AppColors.darkpink,
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(50),
                            child: Text(
                              'Something went wrong:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(50),
                            child: Text(
                              'Koi product nahi mila!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final docs =
                        controller.getFilteredProducts(snapshot.data!);

                    if (docs.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(50),
                            child: Text(
                              'no food found!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: 5,
                      ),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final data =
                                docs[index].data()
                                    as Map<String, dynamic>;

                            final FoodModel food = FoodModel(
                              id: index,
                              image:
                                  (data['image'] ??
                                          data['imageUrl'] ??
                                          '')
                                      .toString(),
                              title:
                                  (data['title'] ?? '').toString(),
                              subtitle:
                                  (data['subtitle'] ?? '').toString(),
                              productname:
                                  (data['productname'] ?? '').toString(),
                              price:
                                  _toDouble(data['price'], 4.5),
                              description:
                                  (data['description'] ??
                                          'No description available.')
                                      .toString(),
                              spicyLevel:
                                  _toDouble(data['spicyLevel'], 2.0),
                              rating:
                                  _toDouble(data['rating'], 4.5),
                              reviewCount:
                                  _toInt(data['reviewCount'], 10),
                              isFavorite:
                                  data['isFavorite'] ?? false,
                            );

                            return ProductCard(
                              food: food,
                            );
                          },
                          childCount: docs.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.82,
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: screenHeight * 0.03,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom:
                MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Filter Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.lightwhite
                          : Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? AppColors.lightwhite
                          : Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(
                color: isDark
                    ? Colors.grey[800]
                    : Colors.grey[300],
              ),
              const SizedBox(height: 10),
              Text(
                "Sort By",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark
                      ? AppColors.lightwhite
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  Obx(
                    () => ChoiceChip(
                      label:
                          const Text("Price: Low to High"),
                      selected:
                          controller.selectedFilter.value ==
                              'low',
                      selectedColor:
                          AppColors.darkpink.withOpacity(0.2),
                      backgroundColor: isDark
                          ? AppColors.backgroundDark
                          : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: controller
                                    .selectedFilter.value ==
                                'low'
                            ? AppColors.darkpink
                            : (isDark
                                ? AppColors.lightwhite
                                : Colors.black87),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectFilter('low');
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => ChoiceChip(
                      label:
                          const Text("Price: High to Low"),
                      selected:
                          controller.selectedFilter.value ==
                              'high',
                      selectedColor:
                          AppColors.darkpink.withOpacity(0.2),
                      backgroundColor: isDark
                          ? AppColors.backgroundDark
                          : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: controller
                                    .selectedFilter.value ==
                                'high'
                            ? AppColors.darkpink
                            : (isDark
                                ? AppColors.lightwhite
                                : Colors.black87),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectFilter('high');
                        }
                      },
                    ),
                  ),
                  Obx(
                    () => ChoiceChip(
                      label: const Text("Top Rated"),
                      selected:
                          controller.selectedFilter.value ==
                              'rating',
                      selectedColor:
                          AppColors.darkpink.withOpacity(0.2),
                      backgroundColor: isDark
                          ? AppColors.backgroundDark
                          : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: controller
                                    .selectedFilter.value ==
                                'rating'
                            ? AppColors.darkpink
                            : (isDark
                                ? AppColors.lightwhite
                                : Colors.black87),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.selectFilter('rating');
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.darkpink,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
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

  double _toDouble(
    dynamic value,
    double defaultValue,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        defaultValue;
  }

  int _toInt(
    dynamic value,
    int defaultValue,
  ) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        defaultValue;
  }
}
