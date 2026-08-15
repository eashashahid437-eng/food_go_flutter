import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';

class CustomCounter extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const CustomCounter({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _button(Icons.remove, onMinus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _button(Icons.add, onPlus),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: AppColors.darkpink,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}