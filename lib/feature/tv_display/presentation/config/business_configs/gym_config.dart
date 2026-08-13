import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart' show BusinessTypeTvTheme;
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';


/// Dedicated content and theme configuration for Gym business type.
class GymTvConfig {
  static const String typeId = 'gym';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [
    IdleSuggestion(icon: Icons.fitness_center_rounded, label: 'JOIN CLASS'),
    IdleSuggestion(icon: Icons.timer_rounded, label: 'TODAY\'S WORKOUT'),
    IdleSuggestion(icon: Icons.local_fire_department_rounded, label: 'BURN RATE'),
    IdleSuggestion(icon: Icons.shopping_cart_rounded, label: 'SHAKE BAR'),
  ];

  static const List<IdleSlide> defaultSlides = [
    IdleSlide(
      emoji: '🏋️',
      headline: 'CRUSH YOUR GOALS',
      subtitle: 'Book your next functional training session now',
      suggestionIndex: 0,
    ),
    IdleSlide(
      emoji: '⏱️',
      headline: 'NO EXCUSES',
      subtitle: 'Today\'s challenge: 50 burpees for time. Log it at reception',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '🔥',
      headline: 'PUSH THE LIMITS',
      subtitle: 'Consistency is key. Every drop of sweat counts',
      suggestionIndex: 2,
    ),
    IdleSlide(
      emoji: '🥤',
      headline: 'FUEL YOUR BODY',
      subtitle: 'Grab a high-protein recovery shake at the nutrition bar',
      suggestionIndex: 3,
    ),
  ];
}
