import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Screens/topping_screen.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:food_go/Controllers/bottomnavbarcontroller.dart';
import 'package:food_go/Screens/BottomNavbar/favourite_screen.dart';
import 'package:food_go/Screens/BottomNavbar/home_screen.dart';
import 'package:food_go/Screens/BottomNavbar/message_screen.dart';
import 'package:food_go/Screens/BottomNavbar/person_screen.dart';
import 'package:get/get.dart';

class BottomNavbar extends StatelessWidget {
  BottomNavbar({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    UserChatScreen(),
    PersonScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // MediaQueryu utility se screen width & height nikalna
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);

    return Obx(
      () => Scaffold(
        body: pages[controller.currentIndex.value],

        // --- Perfect Circular FAB with Border ---
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4), // Dynamic notch border look
          ),
          child: FloatingActionButton(
            backgroundColor: AppColors.darkpink,
            elevation: 4,
            shape: const CircleBorder(), // <-- Is se button bilkul GOL (Circle) ho jayega!
            
            // --- 2. Yahan par Get.to() add kar diya hai ---
            onPressed: () {
              Get.to(() => const BurgerCustomizationScreen());
            },
            
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: controller.iconList.length,

          tabBuilder: (int index, bool isActive) {
            return Icon(
              controller.iconList[index],
              size: screenWidth * 0.065,
              color: isActive ? Colors.white : AppColors.lightwhite.withOpacity(0.7),
            );
          },

          activeIndex: controller.currentIndex.value,

          gapLocation: GapLocation.center,

          // Notch smoothness ko soft border ke sath adjust kiya hai
          notchSmoothness: NotchSmoothness.smoothEdge, 
          notchMargin: 8,

          leftCornerRadius: 28,
          rightCornerRadius: 28,

          splashColor: AppColors.darkpink,
          backgroundColor: AppColors.darkpink,

          height: screenHeight * 0.08,
          onTap: controller.changeIndex,
        ),
      ),
    );
  }
}
