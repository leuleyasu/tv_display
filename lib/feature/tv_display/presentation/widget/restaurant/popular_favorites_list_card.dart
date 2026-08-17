import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/idle_content.dart';
import 'gourmet_dish_card.dart';

/// Ultra-Cool Visual Menu Grid Component for Right Section of Restaurant Idle View
class PopularFavoritesListCard extends StatefulWidget {
  final List<IdleSlide> sideItems;
  final double scale;
  final String fallbackCurrency;
  final int activeIndex;

  const PopularFavoritesListCard({
    super.key,
    required this.sideItems,
    required this.scale,
    this.fallbackCurrency = 'ETB',
    this.activeIndex = 0,
  });

  @override
  State<PopularFavoritesListCard> createState() =>
      _PopularFavoritesListCardState();
}

class _PopularFavoritesListCardState extends State<PopularFavoritesListCard> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    // Extract unique categories from sideItems
    final Set<String> categorySet = {'ALL'};
    for (final item in widget.sideItems) {
      if (item.category != null && item.category!.isNotEmpty) {
        categorySet.add(item.category!.toUpperCase());
      }
    }
    final List<String> categories = categorySet.toList();

    // Filter items based on selected category
    final filteredItems = _selectedCategory == 'ALL'
        ? widget.sideItems
        : widget.sideItems
            .where((s) =>
                s.category != null &&
                s.category!.toUpperCase() == _selectedCategory)
            .toList();

    return Container(
      padding: EdgeInsets.all(20 * scale),
      // decoration: BoxDecoration(
      //   color: const Color(0xFF120D08).withValues(alpha: 0.88),
      //   borderRadius: BorderRadius.circular(24 * scale),
      //   border: Border.all(
      //     color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
      //     width: 1.8 * scale,
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withValues(alpha: 0.7),
      //       blurRadius: 28 * scale,
      //       offset: const Offset(0, 10),
      //     ),
      //     BoxShadow(
      //       color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
      //       blurRadius: 36 * scale,
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    color: const Color(0xFFFBBF24),
                    size: 22 * scale,
                  ),
                  SizedBox(width: 10 * scale),
                  Text(
                    'OUR SELECTION',
                    style: GoogleFonts.outfit(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                ],
              ),
              // Container(
              //   padding: EdgeInsets.symmetric(
              //     horizontal: 10 * scale,
              //     vertical: 4 * scale,
              //   ),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF26190E),
              //     borderRadius: BorderRadius.circular(10 * scale),
              //     border: Border.all(
              //       color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
              //     ),
              //   ),
              //   child: Text(
              //     '${filteredItems.length} DISHES',
              //     style: GoogleFonts.outfit(
              //       fontSize: 10 * scale,
              //       fontWeight: FontWeight.w800,
              //       letterSpacing: 1.2,
              //       color: const Color(0xFFFBBF24),
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 14 * scale),

          // Horizontal Category Selector Chips Bar
          if (categories.length > 1) ...[
            SizedBox(
              height: 34 * scale,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
                itemBuilder: (context, idx) {
                  final cat = categories[idx];
                  final bool isSelected = cat == _selectedCategory;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14 * scale,
                        vertical: 6 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFF1F160E).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFFBBF24).withValues(alpha: 0.3),
                          width: 1.5 * scale,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            fontSize: 11 * scale,
                            fontWeight:
                                isSelected ? FontWeight.w900 : FontWeight.w700,
                            letterSpacing: 1.2,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFFFEF3C7),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14 * scale),
          ],

          // 2-Column Gourmet Visual Dish Cards Grid
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No items in this category',
                      style: GoogleFonts.outfit(
                        fontSize: 14 * scale,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14 * scale,
                      mainAxisSpacing: 14 * scale,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, idx) {
                      final item = filteredItems[idx];
                      final bool isActive =
                          idx == (widget.activeIndex % filteredItems.length);

                      return GourmetDishCard(
                        item: item,
                        scale: widget.scale,
                        fallbackCurrency: widget.fallbackCurrency,
                        isActive: isActive,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
