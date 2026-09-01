import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/bottomnavbarcontroller.dart';
import 'package:food_go/Screens/BottomNavbar/favourite_screen.dart';
import 'package:food_go/Screens/BottomNavbar/home_screen.dart';
import 'package:food_go/Screens/BottomNavbar/message_screen.dart';
import 'package:food_go/Screens/BottomNavbar/person_screen.dart';
import 'package:food_go/Screens/topping_screen.dart';
import 'package:food_go/utility/responsive.dart';
import 'package:get/get.dart';

class BottomNavbar extends StatelessWidget {
  BottomNavbar({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // MediaQuery utility typo fix
    final double screenWidth = MediaQueryu.getScreenWidth(context);
    final double screenHeight = MediaQueryu.getScreenHeight(context);

    // Theme state detection
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic background matching for FAB ring border
    final Color notchBorderColor = isDark 
        ? Theme.of(context).scaffoldBackgroundColor 
        : Colors.white;

    return Obx(
      () => Scaffold(
        body: pages[controller.currentIndex.value > 1 ? 0 : controller.currentIndex.value],

        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: notchBorderColor, 
              width: 4,
            ),
          ),
          child: FloatingActionButton(
            backgroundColor: AppColors.darkpink,
            elevation: 4,
            shape: const CircleBorder(),
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

          activeIndex: controller.currentIndex.value > 1 ? 0 : controller.currentIndex.value,

          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.smoothEdge, 
          notchMargin: 8,

          leftCornerRadius: 28,
          rightCornerRadius: 28,

          splashColor: AppColors.darkpink,
          backgroundColor: AppColors.darkpink,

          height: screenHeight * 0.08,
          onTap: (index) {
            if (index == 2) {
              Get.to(() => const UserChatScreen());
            } else if (index == 3) {
              Get.to(() => const PersonScreen());
            } else {
              controller.changeIndex(index);
            }
          },
        ),
      ),
    );
  }
}
