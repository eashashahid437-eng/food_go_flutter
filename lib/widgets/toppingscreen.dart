import 'package:flutter/material.dart';
import 'package:food_go/Constants/app_colors.dart';

class CustomOptionCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomOptionCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.darkpink
                : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) {
                    return const Icon(
                      Icons.fastfood,
                      color: Colors.orange,
                      size: 30,
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSelected
                            ? Icons.check
                            : Icons.add,
                        size: 12,
                        color: isSelected
                            ? AppColors.darkpink
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
