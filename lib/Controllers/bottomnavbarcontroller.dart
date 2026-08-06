import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  final List<IconData> iconList = [
    Icons.home,
    Icons.person_outline,
    Icons.message_outlined,
    Icons.favorite_outline,
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}