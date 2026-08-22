import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/config/business_configs/butcher_config.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/butcher_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/butcher/bento_digestives_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/butcher/bento_hero_dish_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/butcher/bento_kilo_rate_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/butcher/bento_prep_grid.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_footer.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/tv_top_header_bar.dart';

/// Ultra-Modern 4K Dark Bento Grid TV Signage View for Ethiopian Butcher Houses (ሥጋ ቤት).
/// Built specifically for high-volume flagship venues like Yonas Chercher.
class ButcherIdleView extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final List<IdleSlide>? effectiveSlides;
  final List<IdleSuggestion>? effectiveSuggestions;
  final int idleSlideIndex;
  final SettingsModel? settings;
  final String orgName;
  final DateTime now;
  final String? qrCodeUrl;
  final double energyLevel;
  final bool isWorldCupEnabled;
  final Animation<double> fadeAnim;
  final Animation<double> idleBreathAnim;
  final Animation<double> orbAnim;
  final Animation<double> idleRadarAnim;

  const ButcherIdleView({
    super.key,
    this.menuItems = const [],
    this.effectiveSlides,
    this.effectiveSuggestions,
    required this.idleSlideIndex,
    required this.settings,
    required this.orgName,
    required this.now,
    required this.qrCodeUrl,
    required this.energyLevel,
    required this.isWorldCupEnabled,
    required this.fadeAnim,
    required this.idleBreathAnim,
    required this.orbAnim,
    required this.idleRadarAnim,
  });

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of('butcher');

    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final String fallbackCurrency = settings?.currency ?? 'ETB';

          // 1. Dynamic Menu Mapping from Live Firestore Stream or Default Butcher Config
          final List<IdleSlide> rawSlides = menuItems.isNotEmpty
              ? menuItems.map((item) {
                  final String name = (item['name'] ?? item['title'] ?? 'Special Cut').toString().trim();
                  final String desc = (item['description'] ?? item['desc'] ?? '').toString().trim();
                  final priceRaw = item['price'];
                  final double? price = (priceRaw is num)
                      ? priceRaw.toDouble()
                      : (priceRaw != null ? double.tryParse(priceRaw.toString().trim()) : null);
                  final String? img = item['imageUrl']?.toString().trim();
                  final catField = item['category'] ?? item['cat'];
                  String cat = 'PRIME CUTS';
                  if (catField is List && catField.isNotEmpty) {
                    cat = catField.first.toString().trim();
                  } else if (catField != null && catField.toString().trim().isNotEmpty) {
                    cat = catField.toString().trim();
                  }
                  final String curr = (item['currency']?.toString().trim().isNotEmpty == true)
                      ? item['currency'].toString().trim().toUpperCase()
                      : fallbackCurrency.toUpperCase();
                  final String? pairing = (item['pairing'] ?? item['pairingNote'])?.toString().trim();

                  return IdleSlide(
                    emoji: _getEmojiForCut(name, cat),
                    headline: name,
                    subtitle: desc.isNotEmpty ? desc : 'Freshly prepared Ethiopian ox beef delicacy.',
                    imageUrl: (img != null && img.isNotEmpty) ? img : null,
                    price: price,
                    currency: curr,
                    category: cat,
                    pairingNote: pairing,
                    suggestionIndex: 0,
                  );
                }).toList()
              : (effectiveSlides ?? ButcherTvConfig.defaultSlides);

          final List<IdleSlide> slidesToUse = rawSlides.isNotEmpty
              ? rawSlides
              : ButcherTvConfig.defaultSlides;

          final currentSlide = slidesToUse[idleSlideIndex % slidesToUse.length];

          // Compute base kilo price from active items or default 2200 ETB
          final double baseKiloPrice = currentSlide.price ?? 2200.0;

          final effectiveOrgName = orgName.isNotEmpty ? orgName : 'YONAS CHERCHER PRIME BEEF';
          final effectiveQr = (qrCodeUrl != null && qrCodeUrl!.isNotEmpty)
              ? qrCodeUrl
              : settings?.qrCodeUrl;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Dark Cast Iron Slate Background
              ButcherBackground(
                box: box,
                orbAnim: orbAnim,
                orgName: effectiveOrgName,
                now: now,
              ),

              // 2. Top Header Bar
              TvTopHeaderBar(
                scale: scale,
                businessType: 'butcher',
                orgName: effectiveOrgName,
                now: now,
                orbAnim: orbAnim,
              ),

              // 3. Central 4K Bento Grid Layout
              Positioned(
                top: 95 * scale,
                bottom: 60 * scale,
                left: 40 * scale,
                right: 40 * scale,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A. Hero Dish Spotlight (42% Width)
                    Expanded(
                      flex: 42,
                      child: BentoHeroDishCard(
                        slide: currentSlide,
                        scale: scale,
                        fadeAnim: fadeAnim,
                      ),
                    ),

                    SizedBox(width: 20 * scale),

                    // B. Center Column: Live Kilo Rate HUD (Top) + Prep Matrix (Bottom) (34% Width)
                    Expanded(
                      flex: 34,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 54,
                            child: BentoKiloRateCard(
                              baseKiloPrice: baseKiloPrice,
                              currency: fallbackCurrency,
                              scale: scale,
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          Expanded(
                            flex: 46,
                            child: BentoPrepGrid(scale: scale),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 20 * scale),

                    // C. Right Column: Digestives / Ambo (Top) + Fast Table Checkout QR (Bottom) (24% Width)
                    Expanded(
                      flex: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 48,
                            child: BentoDigestivesCard(scale: scale),
                          ),
                          SizedBox(height: 16 * scale),
                          Expanded(
                            flex: 52,
                            child: _buildQuickPayCard(
                              scale: scale,
                              qrUrl: effectiveQr,
                              tvTheme: tvTheme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Bottom Footer Status Bar
              Positioned(
                bottom: 16 * scale,
                left: 40 * scale,
                right: 40 * scale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IdleFooter(
                      scale: scale,
                      monoFontSize: 11 * scale,
                      tvTheme: tvTheme,
                      energyLevel: energyLevel,
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale,
                            vertical: 4 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8 * scale),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFFEF4444),
                                size: 14,
                              ),
                              SizedBox(width: 6 * scale),
                              Text(
                                'ትኩስ የበሬ ሥጋ • DAILY FRESH SLAUGHTER',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 10.5 * scale,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickPayCard({
    required double scale,
    required String? qrUrl,
    required BusinessTypeTvTheme tvTheme,
  }) {
    const warmAmber = Color(0xFFF59E0B);
    const primaryEmber = Color(0xFFEF4444);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF16100E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: warmAmber.withValues(alpha: 0.25),
          width: 1.5 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: warmAmber, size: 18 * scale),
              SizedBox(width: 8 * scale),
              Text(
                'ፈጣን የሂሳብ መክፈያ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            'TELEBIRR • CBE BIRR • LAKIPAY',
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          if (qrUrl != null && qrUrl.isNotEmpty)
            IdleQrCard(
              qrCodeUrl: qrUrl,
              scale: scale,
              tvTheme: tvTheme,
              radarAnim: idleRadarAnim,
              customQrSize: 110,
            )
          else
            Container(
              width: 100 * scale,
              height: 100 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.qr_code_2_rounded,
                color: warmAmber.withValues(alpha: 0.6),
                size: 50 * scale,
              ),
            ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: primaryEmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Text(
              'SCAN WITH TELEBIRR APP',
              style: GoogleFonts.outfit(
                color: const Color(0xFFFCA5A5),
                fontSize: 9.5 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _getEmojiForCut(String name, String category) {
    final n = name.toLowerCase();
    final c = category.toLowerCase();

    if (n.contains('ጥብስ') || n.contains('tibs') || n.contains('sizzle')) return '🔥';
    if (n.contains('ቁርት') || n.contains('kurt') || n.contains('ጥሬ') || n.contains('tire')) return '🥩';
    if (n.contains('ክትፎ') || n.contains('kitfo')) return '🧈';
    if (n.contains('ጎረድ') || n.contains('gored') || n.contains('ለብለብ')) return '🍖';
    if (n.contains('አምቦ') || n.contains('ambo') || n.contains('ውሀ') || n.contains('water')) return '💧';
    if (n.contains('ቢራ') || n.contains('beer') || n.contains('habesha') || n.contains('walia')) return '🍺';
    if (c.contains('drink') || c.contains('beverage')) return '🥤';
    return '🥩';
  }
}
