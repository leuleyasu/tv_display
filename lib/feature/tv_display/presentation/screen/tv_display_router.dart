import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import 'restaurant_display_screen.dart';
import 'nightclub_display_screen.dart';
import 'cafe_display_screen.dart';
import 'gym_display_screen.dart';
import 'lounge_display_screen.dart';
import 'match_mode_display_screen.dart';

/// Router component that listens to organization tv_settings and dynamically
/// routes/navigates to the appropriate business type UI screen class.
class TvDisplayRouter extends StatefulWidget {
  final String organizationId;

  const TvDisplayRouter({
    super.key,
    required this.organizationId,
  });

  @override
  State<TvDisplayRouter> createState() => _TvDisplayRouterState();
}

class _TvDisplayRouterState extends State<TvDisplayRouter> {
  late final TvDisplayRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = TvDisplayRepository(organizationId: widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SettingsModel>(
      stream: _repository.settingsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingScreen('Loading business settings...');
        }

        final settings = snapshot.data;
        final businessType =
            settings?.businessType.trim().toLowerCase() ?? 'nightclub';

        // ⚽ Match Mode Override: When match mode is enabled via dashboard or business type is match/sports_bar
        if (settings?.isMatchMode == true ||
            businessType == 'match' ||
            businessType == 'sports_bar') {
          debugPrint('⚽ [TvDisplayRouter] Route: MatchModeDisplayScreen (isMatchMode=${settings?.isMatchMode}, type=$businessType)');
          return MatchModeDisplayScreen(
            organizationId: widget.organizationId,
          );
        }

        debugPrint('📺 [TvDisplayRouter] Route: Standard Business Display ($businessType)');

        switch (businessType) {
          case 'restaurant':
            return RestaurantDisplayScreen(
              organizationId: widget.organizationId,
            );
          case 'cafe':
            return CafeDisplayScreen(
              organizationId: widget.organizationId,
            );
          case 'gym':
            return GymDisplayScreen(
              organizationId: widget.organizationId,
            );
          case 'lounge':
            return LoungeDisplayScreen(
              organizationId: widget.organizationId,
            );
          case 'nightclub':
          default:
            return NightclubDisplayScreen(
              organizationId: widget.organizationId,
            );
        }
      },
    );
  }

  Widget _buildLoadingScreen(String message) {
    return Scaffold(
      backgroundColor: const Color(0xFF070712),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.discreteCircle(
              color: const Color(0xFFFF007A),
              secondRingColor: const Color(0xFF6A5CFF),
              thirdRingColor: const Color(0xFF00F0FF),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
