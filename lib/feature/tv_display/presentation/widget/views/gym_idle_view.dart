import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/gym_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_suggestion_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/tv_top_header_bar.dart';

/// Specialized High-Performance Gym & Fitness Display View.
class GymIdleView extends StatelessWidget {
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

  const GymIdleView({
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
    final tvTheme = BusinessTypeTvTheme.of('gym');
    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          
          final List<IdleSlide> slidesToUse = menuItems.isNotEmpty
              ? menuItems.map((item) {
                  final String name = item['name'] as String? ?? 'Gym Class';
                  final String desc = item['description'] as String? ?? '';
                  final double? price = (item['price'] is num)
                      ? (item['price'] as num).toDouble()
                      : double.tryParse(item['price']?.toString() ?? '');
                  final String? img = item['imageUrl'] as String?;
                  final String cat = item['category'] as String? ?? 'FITNESS';
                  final String curr = item['currency'] as String? ?? 'ETB';
                  return IdleSlide(
                    emoji: '🏋️',
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
                      emoji: '🏋️',
                      headline: 'FITNESS & TRAINERS',
                      subtitle: 'Join our daily workouts & personal training',
                      suggestionIndex: 0,
                    )
                  ]);

          final slide = slidesToUse[idleSlideIndex % slidesToUse.length];
          final suggestionsList = effectiveSuggestions ?? const <IdleSuggestion>[];
          final accent = const Color(0xFF00F0FF);
          final greeting = tvTheme.getGreeting(now);

          final double baseFont = settings?.fontSize ?? 72.0;
          final double orgNameSize = (settings?.idleOrgNameSize ?? baseFont * 0.72) * scale;
          final double headlineSize = (settings?.idleHeadlineSize ?? baseFont * 1.0) * scale;
          final double subtitleSize = (settings?.idleSubtitleSize ?? baseFont * 0.28) * scale;
          final double ctaSize = (settings?.idleCtaSize ?? baseFont * 0.22) * scale;

          return Stack(
            children: [
              GymBackground(box: box, orbAnim: orbAnim),
              TvTopHeaderBar(
                scale: scale,
                businessType: 'gym',
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
                        style: GoogleFonts.orbitron(
                          fontSize: (settings?.idleGreetingSize ?? baseFont * 0.2) * scale,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 6,
                          color: const Color(0xFF00F0FF),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      Text(
                        orgName.isNotEmpty ? orgName.toUpperCase() : 'FITNESS & GYM',
                        style: GoogleFonts.orbitron(
                          fontSize: orgNameSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 26 * scale),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF00F0FF), Colors.white, Color(0xFF10B981)],
                        ).createShader(bounds),
                        child: Text(
                          slide.headline,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            fontSize: headlineSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        slide.subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 38 * scale),
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
                                  labelStyle: GoogleFonts.orbitron(
                                    fontSize: (settings?.idleCardLabelSize ?? baseFont * 0.17) * scale,
                                    fontWeight: FontWeight.w800,
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
                        style: GoogleFonts.orbitron(
                          fontSize: ctaSize,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF00F0FF),
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
