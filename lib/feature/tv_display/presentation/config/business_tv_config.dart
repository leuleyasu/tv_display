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
  /// Get default idle suggestions for a given business type string.
  /// Defaults to RestaurantTvConfig suggestions when no custom suggestions are defined.
  static List<IdleSuggestion> getSuggestions(String? businessType) {
    final type = businessType?.trim().toLowerCase();
    switch (type) {
      case 'cafe':
        return CafeTvConfig.defaultSuggestions;
      case 'gym':
        return GymTvConfig.defaultSuggestions;
      case 'lounge':
        return LoungeTvConfig.defaultSuggestions;
      case 'nightclub':
        return NightclubTvConfig.defaultSuggestions;
      case 'restaurant':
      default:
        return RestaurantTvConfig.defaultSuggestions;
    }
  }

  /// Get default idle slides for a given business type string.
  /// When there is no menu to display on the TV, defaults to RestaurantTvConfig slides across all business types.
  static List<IdleSlide> getSlides(String? businessType) {
    // When no menu to display, display RestaurantTvConfig idle slides for all business types
    return RestaurantTvConfig.defaultSlides;
  }

  /// Get the BusinessTypeTvTheme object for a given business type string
  static BusinessTypeTvTheme getTheme(String? businessType) {
    return BusinessTypeTvTheme.of(businessType);
  }
}
