import 'package:flutter/material.dart';

/// Utility class containing helper functions extracted from [TvDisplayScreen]
/// for scaling, timer duration calculations, and formatting.
class TvDisplayUtils {
  /// Calculates screen scale factor relative to standard 1080p TV resolution (1920x1080).
  static double calculateTvScale(BuildContext context, {double baseWidth = 1920}) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    return (width / baseWidth).clamp(0.5, 3.0);
  }

  /// Extracts display duration in milliseconds from a campaign ad object.
  static int getCampaignDurationMs(Map<String, dynamic>? campaign, {int defaultSeconds = 10}) {
    if (campaign == null) return defaultSeconds * 1000;
    final durationSec = (campaign['displayDurationSeconds'] as num?)?.toInt() ?? defaultSeconds;
    return durationSec * 1000;
  }

  /// Calculates progress ratio (0.0 to 1.0) given remaining and total duration in ms.
  static double calculateProgressRatio(int remainingMs, int totalMs) {
    if (totalMs <= 0) return 0.0;
    return (remainingMs / totalMs).clamp(0.0, 1.0);
  }

  /// Formats live match minute string (e.g. 78 -> "78'", null -> "LIVE").
  static String formatMatchMinute(int? minute) {
    if (minute == null) return 'LIVE';
    return "$minute'";
  }

  /// Generates a randomized energy meter level between 0.55 and 1.0 for venue visualizers.
  static double generateEnergyLevel(double baseMin, double randomFactor) {
    return (baseMin + randomFactor * (1.0 - baseMin)).clamp(0.0, 1.0);
  }
}
