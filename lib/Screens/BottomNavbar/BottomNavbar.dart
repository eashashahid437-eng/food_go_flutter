import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';
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
    FavouriteScreen(),
    MessageScreen(),
    PersonScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
            backgroundColor: Colors.red,
            elevation: 4,
            shape: const CircleBorder(), // <-- Is se button bilkul GOL (Circle) ho jayega!
            onPressed: () {},
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
              size: 25,
              color: isActive ? Colors.white : Colors.white70,
            );
          },

          activeIndex: controller.currentIndex.value,

          gapLocation: GapLocation.center,

          // Notch smoothness ko soft border ke sath adjust kiya hai
          notchSmoothness: NotchSmoothness.smoothEdge, 
          notchMargin: 8,

          leftCornerRadius: 28,
          rightCornerRadius: 28,

          splashColor: Colors.red,
          backgroundColor: AppColors.darkpink,

          height: 65,
          onTap: controller.changeIndex,
        ),
      ),
    );
  }
}
