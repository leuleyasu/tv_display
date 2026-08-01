import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tv_display_colors.dart';

/// Disabled / Empty state view for TV display.
class TvEmptyState extends StatelessWidget {
  const TvEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tv_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 20),
            Text(
              'Display disabled',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
