import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

import '../../../../core/config/business_type_tv_theme.dart';
import 'business_configs/restaurant_config.dart';
import 'business_configs/nightclub_config.dart';
import 'business_configs/cafe_config.dart';
import 'business_configs/gym_config.dart';
import 'business_configs/lounge_config.dart';

/// Business Configuration Registry & Factory.
/// Solves monolith overhead by delegating per-business-type slides,
/// idle suggestions, and themes into dedicated isolated configuration files.
abstract class BusinessTvConfig {
  /// Get default idle suggestions for a given business type string
  static List<IdleSuggestion> getSuggestions(String? businessType) {
    final type = businessType?.trim().toLowerCase() ?? 'nightclub';
    switch (type) {
      case 'restaurant':
        return RestaurantTvConfig.defaultSuggestions;
      case 'cafe':
        return CafeTvConfig.defaultSuggestions;
      case 'gym':
        return GymTvConfig.defaultSuggestions;
      case 'lounge':
        return LoungeTvConfig.defaultSuggestions;
      case 'nightclub':
      default:
        return NightclubTvConfig.defaultSuggestions;
    }
  }

  /// Get default idle slides for a given business type string
  static List<IdleSlide> getSlides(String? businessType) {
    final type = businessType?.trim().toLowerCase() ?? 'nightclub';
    switch (type) {
      case 'restaurant':
        return RestaurantTvConfig.defaultSlides;
      case 'cafe':
        return CafeTvConfig.defaultSlides;
      case 'gym':
        return GymTvConfig.defaultSlides;
      case 'lounge':
        return LoungeTvConfig.defaultSlides;
      case 'nightclub':
      default:
        return NightclubTvConfig.defaultSlides;
    }
  }

  /// Get the BusinessTypeTvTheme object for a given business type string
  static BusinessTypeTvTheme getTheme(String? businessType) {
    return BusinessTypeTvTheme.of(businessType);
  }
}
