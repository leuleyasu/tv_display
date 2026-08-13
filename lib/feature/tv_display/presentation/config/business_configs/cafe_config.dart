import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart'
    show BusinessTypeTvTheme;
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Dedicated content and theme configuration for Cafe business type.
class CafeTvConfig {
  static const String typeId = 'cafe';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [
    IdleSuggestion(icon: Icons.coffee_rounded, label: 'ORDER SPECIALS'),
    IdleSuggestion(icon: Icons.wifi_rounded, label: 'WIFI PASS'),
    IdleSuggestion(icon: Icons.cake_rounded, label: 'PASTRY COMBOS'),
    IdleSuggestion(
        icon: Icons.chat_bubble_outline_rounded, label: 'LEAVE A TRIBUTE'),
  ];

  static const List<IdleSlide> defaultSlides = [
    IdleSlide(
      emoji: '☕',
      headline: 'FRESHLY BREWED',
      subtitle: 'Explore our single-origin specials at the counter',
      suggestionIndex: 0,
    ),
    IdleSlide(
      emoji: '📶',
      headline: 'STAY CONNECTED',
      subtitle: 'Free high-speed WiFi is available. Password: coffeehouse',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '🍰',
      headline: 'SWEET PAIRINGS',
      subtitle: 'Get 20% off any pastry with a double shot latte',
      suggestionIndex: 2,
    ),
    IdleSlide(
      emoji: '💬',
      headline: 'SHARE YOUR THOUGHTS',
      subtitle: 'Write a note on our board using your phone',
      suggestionIndex: 3,
    ),
  ];
}
