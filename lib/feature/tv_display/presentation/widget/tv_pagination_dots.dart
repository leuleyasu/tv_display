import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/tv_display_colors.dart';

/// Standalone animated pagination indicator widget for TV screens.
class TvPaginationDots extends StatelessWidget {
  final int totalCount;
  final int currentIndex;

  const TvPaginationDots({
    super.key,
    required this.totalCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final int total = min(totalCount, 20);
    final double step = totalCount > total ? totalCount / total : 1.0;
    final int active = (currentIndex / step).round();
    final int count = (totalCount / step).ceil().clamp(0, total);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final bool isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: isActive
                ? TvDisplayColors.accentPink
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(0),
          ),
        );
      }),
    );
  }
}
