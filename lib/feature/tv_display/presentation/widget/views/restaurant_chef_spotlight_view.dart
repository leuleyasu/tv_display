import 'package:flutter/material.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/views/restaurant_idle_view.dart';

/// Decoupled Modular Prototype 2 Display View: Cinematic Split-Screen Chef Spotlight & Specials
class RestaurantChefSpotlightView extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final List<IdleSlide>? effectiveSlides;
  final List<IdleSuggestion>? effectiveSuggestions;
  final int idleSlideIndex;
  final SettingsModel? settings;
  final String orgName;
  final DateTime now;
  final String? qrCodeUrl;
  final double energyLevel;
  final bool isWorldCupEnabled;
  final Animation<double> fadeAnim;
  final Animation<double> idleBreathAnim;
  final Animation<double> orbAnim;
  final Animation<double> idleRadarAnim;

  const RestaurantChefSpotlightView({
    super.key,
    this.menuItems = const [],
    this.effectiveSlides,
    this.effectiveSuggestions,
    required this.idleSlideIndex,
    required this.settings,
    required this.orgName,
    required this.now,
    required this.qrCodeUrl,
    required this.energyLevel,
    required this.isWorldCupEnabled,
    required this.fadeAnim,
    required this.idleBreathAnim,
    required this.orbAnim,
    required this.idleRadarAnim,
  });

  @override
  Widget build(BuildContext context) {
    return RestaurantIdleView(
      menuItems: menuItems,
      effectiveSlides: effectiveSlides,
      effectiveSuggestions: effectiveSuggestions,
      idleSlideIndex: idleSlideIndex,
      settings: settings,
      orgName: orgName,
      now: now,
      qrCodeUrl: qrCodeUrl,
      energyLevel: energyLevel,
      isWorldCupEnabled: isWorldCupEnabled,
      fadeAnim: fadeAnim,
      idleBreathAnim: idleBreathAnim,
      orbAnim: orbAnim,
      idleRadarAnim: idleRadarAnim,
    );
  }
}
