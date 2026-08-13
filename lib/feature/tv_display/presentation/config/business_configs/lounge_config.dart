import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart'
    show BusinessTypeTvTheme;
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Dedicated content and theme configuration for Lounge business type.
class LoungeTvConfig {
  static const String typeId = 'lounge';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [
    IdleSuggestion(icon: Icons.local_bar_rounded, label: 'COCKTAIL MENU'),
    IdleSuggestion(icon: Icons.star_rounded, label: 'VIP CABANAS'),
    IdleSuggestion(icon: Icons.music_note_rounded, label: 'DEDICATE SONG'),
    IdleSuggestion(icon: Icons.event_seat_rounded, label: 'RESERVE TABLE'),
  ];

  static const List<IdleSlide> defaultSlides = [
    IdleSlide(
      emoji: '🍸',
      headline: 'CRAFT COCKTAILS',
      subtitle: 'Try our mixologist\'s signature smoked old fashioned',
      suggestionIndex: 0,
    ),
    IdleSlide(
      emoji: '✨',
      headline: 'VIP EXPERIENCE',
      subtitle: 'Reserve an executive cabana for private lounge service',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '🎵',
      headline: 'MUSIC DEDICATIONS',
      subtitle: 'Send a special song dedication to your table',
      suggestionIndex: 2,
    ),
    IdleSlide(
      emoji: '🍾',
      headline: 'BOTTLE SERVICE',
      subtitle: 'Ask your concierge for top-shelf champagne & spirits',
      suggestionIndex: 3,
    ),
  ];
}
