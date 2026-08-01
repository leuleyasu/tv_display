import 'package:flutter/material.dart';

/// Representation of an idle screen suggestion badge/button.
class IdleSuggestion {
  final IconData icon;
  final String label;

  const IdleSuggestion({
    required this.icon,
    required this.label,
  });
}

/// Representation of an idle display slide card with headline and copy.
class IdleSlide {
  final String emoji;
  final String headline;
  final String subtitle;
  final int suggestionIndex;

  const IdleSlide({
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.suggestionIndex,
  });
}

/// Configuration model for custom scenes in idle mode.
class IdleSceneConfig {
  final String emoji;
  final String headline;
  final String subtitle;
  final int suggestionIndex;

  const IdleSceneConfig({
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.suggestionIndex,
  });

  factory IdleSceneConfig.fromJson(Map<String, dynamic> json) {
    return IdleSceneConfig(
      emoji: json['emoji'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      suggestionIndex: json['suggestionIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'emoji': emoji,
        'headline': headline,
        'subtitle': subtitle,
        'suggestionIndex': suggestionIndex,
      };
}
