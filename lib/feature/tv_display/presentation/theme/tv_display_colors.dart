import 'package:flutter/material.dart';

/// Centralized Color System for TV Display & Signage System.
/// Defines all curated brand colors, glow effects, gradients, and overlays.
class TvDisplayColors {
  TvDisplayColors._();

  // Backgrounds & Surface Palette
  static const Color backgroundDeep = Color(0xFF070712);
  static const Color backgroundSurface = Color(0xFF0F0E2A);
  static const Color cardSurface = Color(0xFF16152B);
  static const Color cardBorder = Color(0x33FFFFFF);

  // Neon & Glow Accents
  static const Color accentPink = Color(0xFFFF007A);
  static const Color accentPurple = Color(0xFF6A5CFF);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color neonMagenta = Color(0xFFFF0055);

  // Glow Orbs & Soft Accents
  static const Color pinkOrb = Color(0xFFB8005C);
  static const Color pinkOrb2 = Color(0xFF660033);
  static const Color amberOrb = Color(0xFF7A4A00);
  static const Color amberOrb2 = Color(0xFF5C2D00);
  static const Color pinkSoft = Color(0xFFFF5C9E);
  static const Color amberAccent = Color(0xFFFBBF24);
  static const Color cyanAccent = Color(0xFF22D3EE);
  static const Color purpleAccent = Color(0xFFA78BFA);
  static const Color goldAccent = Color(0xFFFFD24A);
  static const Color goldDeep = Color(0xFFB8860B);

  // Status & Badges
  static const Color liveStatus = Color(0xFFFF3366);
  static const Color vipGold = Color(0xFFFFD700);
  static const Color vipOrange = Color(0xFFFFA500);
  static const Color successGreen = Color(0xFF00C853);
  static const Color errorRed = Color(0xFFFF5252);

  // TV Match Mode & HUD Overlays
  static const Color hudBackground = Color(0xCC0D0D1A);
  static const Color hudBorder = Color(0x6600F0FF);
  static const Color tickerBackground = Color(0xE60A0A14);

  // Curated Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPink, accentPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldVipGradient = LinearGradient(
    colors: [vipGold, vipOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient matchHudGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF15142B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cyanPulseGradient = LinearGradient(
    colors: [accentCyan, accentPurple],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
