import 'package:flutter/material.dart';
import '../../feature/tv_display/presentation/theme/tv_display_colors.dart';

enum FooterIndicatorStyle {
  equalizer,
  flameDot,
  steam,
  pulse,
  star,
}

/// Dynamic theme and copy configuration tailored for each business type on the TV Display.
class BusinessTypeTvTheme {
  final String typeId;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color bgColor;
  final Color orbColor1;
  final Color orbColor2;
  final Color cardBorderColor;
  final String adBadgeLabel;
  final String qrPromptCta;
  final String footerStatusText;
  final String topBarTag;
  final FooterIndicatorStyle footerStyle;
  final bool supportsShoutouts;
  final bool supportsLiveBoard;

  const BusinessTypeTvTheme({
    required this.typeId,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.bgColor,
    required this.orbColor1,
    required this.orbColor2,
    required this.cardBorderColor,
    required this.adBadgeLabel,
    required this.qrPromptCta,
    required this.footerStatusText,
    required this.topBarTag,
    required this.footerStyle,
    this.supportsShoutouts = false,
    this.supportsLiveBoard = false,
  });

  static const Map<String, BusinessTypeTvTheme> themes = {
    'nightclub': BusinessTypeTvTheme(
      typeId: 'nightclub',
      primaryAccent: TvDisplayColors.accentPink, // Neon Pink
      secondaryAccent: TvDisplayColors.accentPurple, // Purple Accent
      bgColor: TvDisplayColors.backgroundDeep,
      orbColor1: Color(0xFFB8005C),
      orbColor2: Color(0xFF660033),
      cardBorderColor: TvDisplayColors.accentPink,
      adBadgeLabel: 'SPONSORED AD',
      qrPromptCta: 'SCAN TO JOIN THE PARTY',
      footerStatusText: 'LIVE FROM THE CLUB',
      topBarTag: 'DJ ON STAGE',
      footerStyle: FooterIndicatorStyle.equalizer,
      supportsShoutouts: true,
      supportsLiveBoard: true,
    ),
    'restaurant': BusinessTypeTvTheme(
      typeId: 'restaurant',
      primaryAccent: TvDisplayColors.accentGold, // Gourmet Warm Gold/Amber
      secondaryAccent: Color(0xFFEF4444), // Crimson Accent
      bgColor: Color(0xFF0F0C0A), // Warm Dark Espresso
      orbColor1: Color(0xFF7A4A00),
      orbColor2: Color(0xFF5C2D00),
      cardBorderColor: TvDisplayColors.accentGold,
      adBadgeLabel: 'CHEF\'S SPECIAL / PROMO',
      qrPromptCta: 'SCAN FOR MENU & SPECIALS',
      footerStatusText: 'FINE DINING & HOSPITALITY',
      topBarTag: 'DINING ROOM',
      footerStyle: FooterIndicatorStyle.flameDot,
      supportsShoutouts: false,
      supportsLiveBoard: false,
    ),
    'butcher': BusinessTypeTvTheme(
      typeId: 'butcher',
      primaryAccent: Color(0xFFEF4444), // Sizzling Ember Crimson
      secondaryAccent: Color(0xFFF59E0B), // Spiced Butter / Niter Kibbeh Amber
      bgColor: Color(0xFF0C0908), // Dark Cast Iron Charcoal
      orbColor1: Color(0xFF881337),
      orbColor2: Color(0xFF450A0A),
      cardBorderColor: Color(0xFFDC2626),
      adBadgeLabel: 'BUTCHER SPECIAL',
      qrPromptCta: 'SCAN TO PAY (TELEBIRR / CBE)',
      footerStatusText: '100% FRESH DAILY OX SLAUGHTER',
      topBarTag: '🥩 የሥጋ ቤት / BUTCHER',
      footerStyle: FooterIndicatorStyle.flameDot,
      supportsShoutouts: false,
      supportsLiveBoard: false,
    ),
    'sega_bet': BusinessTypeTvTheme(
      typeId: 'sega_bet',
      primaryAccent: Color(0xFFEF4444), // Sizzling Ember Crimson
      secondaryAccent: Color(0xFFF59E0B), // Spiced Butter / Niter Kibbeh Amber
      bgColor: Color(0xFF0C0908), // Dark Cast Iron Charcoal
      orbColor1: Color(0xFF881337),
      orbColor2: Color(0xFF450A0A),
      cardBorderColor: Color(0xFFDC2626),
      adBadgeLabel: 'BUTCHER SPECIAL',
      qrPromptCta: 'SCAN TO PAY (TELEBIRR / CBE)',
      footerStatusText: '100% FRESH DAILY OX SLAUGHTER',
      topBarTag: '🥩 የሥጋ ቤት / BUTCHER',
      footerStyle: FooterIndicatorStyle.flameDot,
      supportsShoutouts: false,
      supportsLiveBoard: false,
    ),
    'cafe': BusinessTypeTvTheme(
      typeId: 'cafe',
      primaryAccent: Color(0xFFD97706), // Artisan Latte Gold
      secondaryAccent: TvDisplayColors.accentGreen, // Fresh Mint
      bgColor: Color(0xFF140D0A), // Deep Roasted Coffee
      orbColor1: Color(0xFF6B3A11),
      orbColor2: Color(0xFF422208),
      cardBorderColor: Color(0xFFD97706),
      adBadgeLabel: 'CAFE HIGHLIGHT',
      qrPromptCta: 'SCAN TO ORDER & EXPLORE',
      footerStatusText: 'FRESH BREW & ARTISAN BAKERY',
      topBarTag: 'ARTISAN CAFE',
      footerStyle: FooterIndicatorStyle.steam,
      supportsShoutouts: false,
      supportsLiveBoard: false,
    ),
    'gym': BusinessTypeTvTheme(
      typeId: 'gym',
      primaryAccent: TvDisplayColors.accentGreen, // Cyber Emerald Green
      secondaryAccent: TvDisplayColors.accentCyan, // Cyan Accent
      bgColor: Color(0xFF0A110D), // Onyx Dark
      orbColor1: Color(0xFF065F46),
      orbColor2: Color(0xFF047857),
      cardBorderColor: TvDisplayColors.accentGreen,
      adBadgeLabel: 'PROMOTIONAL ANNOUNCEMENT',
      qrPromptCta: 'SCAN FOR CLASSES & WORKOUTS',
      footerStatusText: 'PEAK PERFORMANCE NETWORK',
      topBarTag: 'FITNESS CENTER',
      footerStyle: FooterIndicatorStyle.pulse,
      supportsShoutouts: false,
      supportsLiveBoard: false,
    ),
    'lounge': BusinessTypeTvTheme(
      typeId: 'lounge',
      primaryAccent: TvDisplayColors.accentPurple, // Muted Luxury Lavender
      secondaryAccent: TvDisplayColors.vipGold, // Warm Champagne Gold
      bgColor: Color(0xFF0B0A12), // Midnight Velvet
      orbColor1: Color(0xFF4C1D95),
      orbColor2: Color(0xFF31106A),
      cardBorderColor: TvDisplayColors.accentPurple,
      adBadgeLabel: 'LOUNGE EXCLUSIVE',
      qrPromptCta: 'SCAN TO RESERVE & DEDICATE',
      footerStatusText: 'EXECUTIVE LOUNGE & COCKTAILS',
      topBarTag: 'VIP LOUNGE',
      footerStyle: FooterIndicatorStyle.star,
      supportsShoutouts: true,
      supportsLiveBoard: true,
    ),
  };

  /// Get the configuration theme object for a specific business type
  static BusinessTypeTvTheme of(String? businessType) {
    if (businessType == null || businessType.isEmpty) {
      return themes['nightclub']!;
    }
    final key = businessType.trim().toLowerCase();
    return themes[key] ?? themes['nightclub']!;
  }

  /// Get appropriate greeting string for time of day and business type
  String getGreeting(DateTime time) {
    final h = time.hour;
    switch (typeId) {
      case 'butcher':
      case 'sega_bet':
        if (h < 12) return 'ትኩስ የበሬ ሥጋ • MORNING FRESH CUTS';
        if (h < 17) return 'ቀዝቃዛ አምቦ እና የሸክላ ጥብስ • LUNCH TIBS';
        if (h < 22) return 'ምሽቱን በቁርት እና ጥብስ • PRIME EVENING CUTS';
        return 'ልዩ የሥጋ ቤት ድባብ • BUTCHER LOUNGE';

      case 'restaurant':
        if (h < 5) return 'LATE NIGHT DINING';
        if (h < 12) return 'GOOD MORNING & WELCOME';
        if (h < 17) return 'BON APPÉTIT & LUNCH';
        if (h < 22) return 'FINE DINING EXPERIENCE';
        return 'EVENING SPECIALS';

      case 'cafe':
        if (h < 12) return 'MORNING BREW & FRESH BAKERY';
        if (h < 17) return 'AFTERNOON COFFEE & COZY VIBES';
        return 'EVENING ARTISAN HIGHLIGHTS';

      case 'gym':
        if (h < 12) return 'MORNING CRUSH & WORKOUT';
        if (h < 17) return 'POWER & ENDURANCE HOUR';
        return 'EVENING PEAK SESSION';

      case 'lounge':
        if (h < 17) return 'AFTERNOON RETREAT';
        if (h < 22) return 'COCKTAIL & LOUNGE HOUR';
        return 'VIP NIGHT VIBES';

      case 'nightclub':
      default:
        if (h < 5) return 'LATE NIGHT VIBES';
        if (h < 12) return 'GOOD MORNING';
        if (h < 17) return 'GOOD AFTERNOON';
        if (h < 22) return 'GOOD EVENING';
        return 'LATE NIGHT VIBES';
    }
  }
}
