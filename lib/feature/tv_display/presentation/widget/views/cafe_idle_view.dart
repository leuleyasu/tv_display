import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/cafe_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_suggestion_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/tv_top_header_bar.dart';

/// Specialized Cozy Morning Cafe & Coffee Shop Display View.
class CafeIdleView extends StatelessWidget {
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

  const CafeIdleView({
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
    final tvTheme = BusinessTypeTvTheme.of('cafe');
    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          
          final List<IdleSlide> slidesToUse = menuItems.isNotEmpty
              ? menuItems.map((item) {
                  final String name = item['name'] as String? ?? 'Artisan Coffee';
                  final String desc = item['description'] as String? ?? '';
                  final double? price = (item['price'] is num)
                      ? (item['price'] as num).toDouble()
                      : double.tryParse(item['price']?.toString() ?? '');
                  final String? img = item['imageUrl'] as String?;
                  final String cat = item['category'] as String? ?? 'CAFE';
                  final String curr = item['currency'] as String? ?? 'ETB';
                  return IdleSlide(
                    emoji: '☕',
                    headline: name,
                    subtitle: desc,
                    imageUrl: img,
                    price: price,
                    currency: curr,
                    category: cat,
                    suggestionIndex: 0,
                  );
                }).toList()
              : (effectiveSlides ??
                  [
                    const IdleSlide(
                      emoji: '☕',
                      headline: 'FRESHLY BREWED',
                      subtitle: 'Enjoy our selection of artisan coffees & pastries',
                      suggestionIndex: 0,
                    )
                  ]);

          final slide = slidesToUse[idleSlideIndex % slidesToUse.length];
          final suggestionsList = effectiveSuggestions ?? const <IdleSuggestion>[];
          final accent = tvTheme.primaryAccent;
          final greeting = tvTheme.getGreeting(now);

          final double baseFont = settings?.fontSize ?? 72.0;
          final double orgNameSize = (settings?.idleOrgNameSize ?? baseFont * 0.7) * scale;
          final double headlineSize = (settings?.idleHeadlineSize ?? baseFont * 0.9) * scale;
          final double subtitleSize = (settings?.idleSubtitleSize ?? baseFont * 0.26) * scale;
          final double ctaSize = (settings?.idleCtaSize ?? baseFont * 0.22) * scale;

          return Stack(
            children: [
              CafeBackground(box: box, orbAnim: orbAnim),
              TvTopHeaderBar(
                scale: scale,
                businessType: 'cafe',
                orgName: orgName,
                now: now,
                orbAnim: orbAnim,
              ),
              Center(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.outfit(
                          fontSize: (settings?.idleGreetingSize ?? baseFont * 0.2) * scale,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 4,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        orgName.isNotEmpty ? orgName.toUpperCase() : 'COFFEE & ARTISAN CAFE',
                        style: GoogleFonts.outfit(
                          fontSize: orgNameSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      if (slide.imageUrl != null && slide.imageUrl!.isNotEmpty) ...[
                        Container(
                          width: box.maxWidth * 0.65,
                          padding: EdgeInsets.all(20 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1917).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24 * scale),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              width: 2 * scale,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 30 * scale,
                                offset: const Offset(0, 10),
                              ),
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                blurRadius: 40 * scale,
                                spreadRadius: 2 * scale,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16 * scale),
                                child: Image.network(
                                  slide.imageUrl!,
                                  width: 240 * scale,
                                  height: 200 * scale,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 240 * scale,
                                    height: 200 * scale,
                                    color: Colors.white10,
                                    child: Icon(
                                      Icons.local_cafe_rounded,
                                      size: 70 * scale,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 28 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (slide.category != null && slide.category!.isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10 * scale, vertical: 4 * scale),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(8 * scale),
                                              border: Border.all(color: const Color(0xFFF59E0B)),
                                            ),
                                            child: Text(
                                              '${slide.emoji} ${slide.category!.toUpperCase()}',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12 * scale,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFF59E0B),
                                              ),
                                            ),
                                          ),
                                        if (slide.price != null)
                                          Text(
                                            '${slide.price!.toStringAsFixed(0)} ${slide.currency ?? 'ETB'}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 32 * scale,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFFF59E0B),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 12 * scale),
                                    Text(
                                      slide.headline,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: headlineSize * 0.75,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFFEF3C7),
                                      ),
                                    ),
                                    SizedBox(height: 8 * scale),
                                    Text(
                                      slide.subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: subtitleSize * 0.85,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              slide.headline,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: headlineSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFEF3C7),
                              ),
                            ),
                            if (slide.price != null) ...[
                              SizedBox(width: 16 * scale),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14 * scale, vertical: 6 * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12 * scale),
                                  border: Border.all(color: const Color(0xFFF59E0B)),
                                ),
                                child: Text(
                                  '${slide.price!.toStringAsFixed(0)} ${slide.currency ?? 'ETB'}',
                                  style: GoogleFonts.outfit(
                                    fontSize: headlineSize * 0.5,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFF59E0B),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          slide.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      SizedBox(height: 36 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              suggestionsList.length,
                              (i) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                                child: IdleSuggestionCard(
                                  suggestion: suggestionsList[i],
                                  accent: accent,
                                  scale: scale,
                                  active: i == slide.suggestionIndex,
                                  labelStyle: GoogleFonts.outfit(
                                    fontSize: (settings?.idleCardLabelSize ?? baseFont * 0.17) * scale,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  hintFontSize: (settings?.idleCardHintSize ?? baseFont * 0.11) * scale,
                                  cardWidth: settings?.idleCardWidth ?? 190,
                                  cardHeight: settings?.idleCardHeight ?? 130,
                                ),
                              ),
                            ),
                          ),
                          IdleQrCard(
                            qrCodeUrl: qrCodeUrl,
                            scale: scale,
                            tvTheme: tvTheme,
                            radarAnim: idleRadarAnim,
                            customQrSize: settings?.qrCodeSize,
                          ),
                        ],
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        tvTheme.qrPromptCta,
                        style: GoogleFonts.outfit(
                          fontSize: ctaSize,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
