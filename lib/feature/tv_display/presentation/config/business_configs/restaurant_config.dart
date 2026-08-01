import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Dedicated content and theme configuration for Restaurant business type.
class RestaurantTvConfig {
  static const String typeId = 'restaurant';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [
    IdleSuggestion(icon: Icons.restaurant_menu_rounded, label: 'VIEW MENU'),
    IdleSuggestion(icon: Icons.wine_bar_rounded, label: 'WINE PAIRINGS'),
    IdleSuggestion(icon: Icons.star_rounded, label: 'RATE US'),
    IdleSuggestion(icon: Icons.celebration_rounded, label: 'BOOK EVENT'),
  ];

  static const List<IdleSlide> defaultSlides = [
    IdleSlide(
      emoji: '🍽️',
      headline: 'CHEF\'S SPECIALS',
      subtitle: 'Try our locally-sourced grilled salmon of the day',
      suggestionIndex: 0,
    ),
    IdleSlide(
      emoji: '🍷',
      headline: 'PERFECT PAIRING',
      subtitle: 'Ask your server about our curated wines for your steak',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '⭐',
      headline: 'WE VALUE YOU',
      subtitle: 'Share your dining experience on Google or TripAdvisor',
      suggestionIndex: 2,
    ),
    IdleSlide(
      emoji: '🎉',
      headline: 'HOST WITH US',
      subtitle: 'Plan your next private party or corporate dinner with us',
      suggestionIndex: 3,
    ),
  ];
}
