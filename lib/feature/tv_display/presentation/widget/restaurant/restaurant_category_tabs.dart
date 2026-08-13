import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated Horizontal Category Navigation Bar for Restaurant Displays
class RestaurantCategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelectCategory;
  final double scale;

  const RestaurantCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelectCategory,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38 * scale,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 10 * scale),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          final bool isSelected = cat == selectedCategory;

          return GestureDetector(
            onTap: () => onSelectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFBBF24)
                    : const Color(0xFF1E150D).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFBBF24)
                      : const Color(0xFFFBBF24).withValues(alpha: 0.3),
                  width: 1.5 * scale,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
                          blurRadius: 14 * scale,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14 * scale,
                      color: Colors.black,
                    ),
                    SizedBox(width: 6 * scale),
                  ],
                  Text(
                    cat,
                    style: GoogleFonts.outfit(
                      fontSize: 12 * scale,
                      fontWeight:
                          isSelected ? FontWeight.w900 : FontWeight.w700,
                      letterSpacing: 1.5,
                      color: isSelected ? Colors.black : const Color(0xFFFEF3C7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
