import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
import 'package:food_go/Controllers/bottomnavbarcontroller.dart';
import 'package:food_go/Screens/cart_screen.dart';
import 'package:food_go/Screens/favourite.dart';
import 'package:food_go/Screens/home_screen.dart';
import 'package:food_go/Screens/profile_screen.dart';
import 'package:get/get.dart';

class BottomNavbar extends StatelessWidget {
  BottomNavbar({super.key});

  final BottomNavController controller = Get.put(BottomNavController());

  final List<Widget> pages = [
    HomeScreen(),
    Favourite(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[controller.currentIndex.value],

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          elevation: 5,
          onPressed: () {},
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),

        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: controller.iconList.length,

          tabBuilder: (int index, bool isActive) {
            return Icon(
              controller.iconList[index],
              size: 25,
              color: isActive ? Colors.red : Colors.grey,
            );
          },

          activeIndex: controller.currentIndex.value,

          gapLocation: GapLocation.center,

          notchSmoothness: NotchSmoothness.verySmoothEdge,

          leftCornerRadius: 25,

          rightCornerRadius: 25,

          splashColor: Colors.red,
          backgroundColor: AppColors.darkpink,

          height: 60,
          onTap: controller.changeIndex,
        ),
      ),
    );
  }
}