import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Utility class containing helper functions extracted from [TvDisplayScreen]
/// for scaling, timer duration calculations, schedule eligibility checks, and formatting.
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

  /// Parses a dynamic date/timestamp into a DateTime object.
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Parses a time string (e.g. "18:00" or "8:30 PM") into minutes since midnight (0..1439).
  static int? parseTimeToMinutes(dynamic timeVal) {
    if (timeVal == null) return null;
    final str = timeVal.toString().trim();
    if (str.isEmpty) return null;

    try {
      if (str.contains(':')) {
        final parts = str.split(':');
        int hour = int.parse(parts[0].trim());
        int minute = int.parse(parts[1].trim().split(' ')[0]);
        if (str.toUpperCase().contains('PM') && hour < 12) hour += 12;
        if (str.toUpperCase().contains('AM') && hour == 12) hour = 0;
        return hour * 60 + minute;
      }
    } catch (_) {}
    return null;
  }

  /// Validates whether a campaign is strictly eligible to play at the given moment [now].
  /// Checks:
  /// 1. Date Range: [startDate] <= now <= [endDate]
  /// 2. Day of Week: [daysOfWeek] contains now.weekday (1=Mon ... 7=Sun)
  /// 3. Active Time Window: [startTime] <= current time <= [endTime]
  /// 4. Frequency Lockout: (now - lastDisplayedAt) >= frequencyMinutes
  static bool isCampaignEligibleToPlay(
    Map<String, dynamic> campaign,
    DateTime now, {
    bool ignoreFrequencyLockout = false,
  }) {
    // 1. Status Check
    final status = (campaign['status'] as String?)?.toLowerCase();
    if (status != 'approved' && status != 'active') return false;

    // 2. Date Range Check
    final startDt = parseDateTime(campaign['startDate']);
    if (startDt != null) {
      final startOfFirstDay = DateTime(startDt.year, startDt.month, startDt.day);
      if (now.isBefore(startOfFirstDay)) return false;
    }

    final endDt = parseDateTime(campaign['endDate']);
    if (endDt != null) {
      final endOfLastDay = DateTime(endDt.year, endDt.month, endDt.day, 23, 59, 59, 999);
      if (now.isAfter(endOfLastDay)) return false;
    }

    // 3. Day of Week Check
    final daysOfWeekRaw = campaign['daysOfWeek'];
    if (daysOfWeekRaw is List && daysOfWeekRaw.isNotEmpty) {
      final validDays = daysOfWeekRaw.map((e) => (e as num).toInt()).toList();
      if (!validDays.contains(now.weekday)) return false;
    }

    // 4. Time Window Check (e.g. 18:00 to 23:30)
    final startMinutes = parseTimeToMinutes(campaign['startTime']);
    final endMinutes = parseTimeToMinutes(campaign['endTime']);
    final nowMinutes = now.hour * 60 + now.minute;

    if (startMinutes != null && endMinutes != null) {
      if (startMinutes <= endMinutes) {
        // Standard window (e.g., 09:00 - 22:00)
        if (nowMinutes < startMinutes || nowMinutes > endMinutes) return false;
      } else {
        // Overnight window (e.g., 20:00 - 03:00)
        if (nowMinutes < startMinutes && nowMinutes > endMinutes) return false;
      }
    } else if (startMinutes != null) {
      if (nowMinutes < startMinutes) return false;
    } else if (endMinutes != null) {
      if (nowMinutes > endMinutes) return false;
    }

    // 5. Frequency Lockout Check (Interval between consecutive plays)
    if (!ignoreFrequencyLockout) {
      final frequencyMinutes = (campaign['frequencyMinutes'] as num?)?.toInt() ?? 15;
      final lastDisplayed = parseDateTime(campaign['lastDisplayedAt']);

      if (lastDisplayed != null) {
        final elapsedMinutes = now.difference(lastDisplayed).inMinutes;
        if (elapsedMinutes < frequencyMinutes) {
          return false; // Still in cooldown period
        }
      }
    }

    return true;
  }
}
