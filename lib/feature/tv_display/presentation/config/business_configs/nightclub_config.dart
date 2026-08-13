import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart'
    show BusinessTypeTvTheme;
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Dedicated content and theme configuration for Nightclub business type.
class NightclubTvConfig {
  static const String typeId = 'nightclub';

  static BusinessTypeTvTheme get theme => BusinessTypeTvTheme.of(typeId);

  static const List<IdleSuggestion> defaultSuggestions = [
    IdleSuggestion(icon: Icons.campaign_rounded, label: 'SHOUTOUT'),
    IdleSuggestion(icon: Icons.cake_rounded, label: 'BIRTHDAY'),
    IdleSuggestion(icon: Icons.music_note_rounded, label: 'REQUEST A SONG'),
    IdleSuggestion(icon: Icons.favorite_rounded, label: 'DEDICATE'),
  ];

  static const List<IdleSlide> defaultSlides = [
    IdleSlide(
      emoji: '🎤',
      headline: 'SHOUT THEM OUT',
      subtitle: 'Put your crew on the big screen for everyone to see',
      suggestionIndex: 0,
    ),
    IdleSlide(
      emoji: '🎂',
      headline: 'BIRTHDAY TAKEOVER',
      subtitle: 'Turn the whole venue into their birthday moment',
      suggestionIndex: 1,
    ),
    IdleSlide(
      emoji: '🎵',
      headline: 'DROP YOUR TRACK',
      subtitle: 'Request the next song straight from your table',
      suggestionIndex: 2,
    ),
    IdleSlide(
      emoji: '💖',
      headline: 'SEND SOME LOVE',
      subtitle: 'Dedicate a message to someone special tonight',
      suggestionIndex: 3,
    ),
  ];
}
