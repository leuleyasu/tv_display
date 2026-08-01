import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/cafe_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_footer.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_suggestion_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/shoutout_top_bar.dart';

/// Specialized Cozy Morning Cafe & Coffee Shop Display View.
class CafeIdleView extends StatelessWidget {
  final List<IdleSlide> effectiveSlides;
  final List<IdleSuggestion> effectiveSuggestions;
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
    required this.effectiveSlides,
    required this.effectiveSuggestions,
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
          final slide = effectiveSlides[idleSlideIndex];
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
              ShoutoutTopBar(
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
                      Text(
                        slide.headline,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: headlineSize,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFEF3C7),
                        ),
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
                      SizedBox(height: 36 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              effectiveSuggestions.length,
                              (i) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                                child: IdleSuggestionCard(
                                  suggestion: effectiveSuggestions[i],
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
              Positioned(
                bottom: 24 * scale,
                left: 0,
                right: 0,
                child: Center(
                  child: IdleFooter(
                    scale: scale,
                    monoFontSize: (settings?.idleFooterSize ?? baseFont * 0.16) * scale,
                    tvTheme: tvTheme,
                    energyLevel: energyLevel,
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
