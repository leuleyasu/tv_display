import 'package:flutter/material.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/views/cafe_idle_view.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/views/gym_idle_view.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/views/lounge_idle_view.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/views/nightclub_idle_view.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/views/restaurant_idle_view.dart';

/// Polymorphic Dispatcher Factory for Business-Specific TV Display Views.
class IdleDisplayViewFactory extends StatelessWidget {
  final String effectiveBusinessType;
  final List<IdleSlide> effectiveSlides;
  final List<IdleSuggestion> effectiveSuggestions;
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

  const IdleDisplayViewFactory({
    super.key,
    required this.effectiveBusinessType,
    required this.effectiveSlides,
    required this.effectiveSuggestions,
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
    final type = effectiveBusinessType.toLowerCase();

    switch (type) {
      case 'restaurant':
        return RestaurantIdleView(
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

      case 'cafe':
        return CafeIdleView(
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

      case 'gym':
        return GymIdleView(
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

      case 'lounge':
        return LoungeIdleView(
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

      case 'nightclub':
      default:
        return NightclubIdleView(
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
}
