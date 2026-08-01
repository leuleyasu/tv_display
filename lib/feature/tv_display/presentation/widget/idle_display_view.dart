import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import '../../domain/models/idle_content.dart';
import '../../../../core/models/settings_model.dart';
import '../theme/tv_display_colors.dart';
import 'ambient_orbs.dart';
import 'floating_particles.dart';
import 'idle_footer.dart';
import 'idle_qr_card.dart';
import 'idle_suggestion_card.dart';
import 'shoutout_top_bar.dart';
import 'world_cup_overlay.dart';

/// Full Idle Screen View component for TV Signage.
class IdleDisplayView extends StatelessWidget {
  final String effectiveBusinessType;
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

  const IdleDisplayView({
    super.key,
    required this.effectiveBusinessType,
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

  Color _accentForSlide(int suggestionIndex, BusinessTypeTvTheme tvTheme) {
    if (tvTheme.typeId != 'nightclub') {
      switch (suggestionIndex) {
        case 0:
          return tvTheme.primaryAccent;
        case 1:
          return tvTheme.secondaryAccent;
        case 2:
          return const Color(0xFF22D3EE);
        case 3:
          return const Color(0xFFA78BFA);
        default:
          return tvTheme.primaryAccent;
      }
    }
    switch (suggestionIndex) {
      case 0:
        return TvDisplayColors.accentPink;
      case 1:
        return TvDisplayColors.amberAccent;
      case 2:
        return TvDisplayColors.cyanAccent;
      case 3:
        return TvDisplayColors.purpleAccent;
      default:
        return TvDisplayColors.accentPink;
    }
  }

  TextStyle _getFontStyle(
      {double fontSize = 16,
      FontWeight fontWeight = FontWeight.w500,
      double letterSpacing = 0,
      Color color = Colors.white,
      double height = 1.0,
      List<Shadow> shadows = const []}) {
    final family = settings?.fontFamily;
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      height: height,
      shadows: shadows,
    );
    if (family != null && family.isNotEmpty) {
      return GoogleFonts.getFont(family, textStyle: base);
    }
    return GoogleFonts.spaceGrotesk(textStyle: base);
  }

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of(effectiveBusinessType);
    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final slide = effectiveSlides[idleSlideIndex];
          final accent = _accentForSlide(slide.suggestionIndex, tvTheme);
          final greeting = tvTheme.getGreeting(now);

          final double baseFont = settings?.fontSize ?? 72.0;
          final double orgNameSize =
              (settings?.idleOrgNameSize ?? baseFont * 0.72) * scale;
          final double headlineSize =
              (settings?.idleHeadlineSize ?? baseFont * 1.0) * scale;
          final double subtitleSize =
              (settings?.idleSubtitleSize ?? baseFont * 0.28) * scale;
          final double ctaSize =
              (settings?.idleCtaSize ?? baseFont * 0.22) * scale;
          final double cardLabelSize =
              (settings?.idleCardLabelSize ?? baseFont * 0.17) * scale;
          final double cardHintSize =
              (settings?.idleCardHintSize ?? baseFont * 0.11) * scale;
          final double footerMonoSize =
              (settings?.idleFooterSize ?? baseFont * 0.16) * scale;
          final double greetingSize =
              (settings?.idleGreetingSize ?? baseFont * 0.19) * scale;

          final labelStyle = _getFontStyle(
            fontSize: cardLabelSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          );

          final cardWidth = settings?.idleCardWidth ?? 190;
          final cardHeight = settings?.idleCardHeight ?? 130;

          return Stack(
            children: [
              AmbientOrbs(
                isVip: false,
                box: box,
                businessType: effectiveBusinessType,
                orbAnim: orbAnim,
              ),
              ShoutoutTopBar(
                scale: scale,
                businessType: effectiveBusinessType,
                orgName: orgName,
                now: now,
                orbAnim: orbAnim,
              ),
              if (isWorldCupEnabled) WorldCupOverlay(scale: scale),
              Positioned.fill(
                child: IgnorePointer(
                  child: FloatingParticles(
                    seed: idleSlideIndex + 7,
                    accent: accent,
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.spaceMono(
                          fontSize: greetingSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [accent, Colors.white, accent],
                        ).createShader(bounds),
                        child: Text(
                          orgName.isNotEmpty ? orgName.toUpperCase() : 'WELCOME',
                          style: _getFontStyle(
                            fontSize: orgNameSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      SizedBox(height: 30 * scale),
                      AnimatedBuilder(
                        animation:
                            Listenable.merge([idleBreathAnim, orbAnim]),
                        builder: (context, _) {
                          final breath =
                              1.0 + (idleBreathAnim.value - 0.5) * 0.05;
                          return Transform.scale(
                            scale: breath,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment(-1.0 + orbAnim.value * 2, 0),
                                end: const Alignment(1.0, 0),
                                colors: [
                                  Colors.white,
                                  accent,
                                  Colors.white,
                                  accent,
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                              ).createShader(bounds),
                              child: Text(
                                slide.headline,
                                key: ValueKey('hl_$idleSlideIndex'),
                                textAlign: TextAlign.center,
                                style: _getFontStyle(
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6,
                                  height: 1.05,
                                  shadows: [
                                    Shadow(
                                      color: accent.withValues(alpha: 0.5),
                                      blurRadius: 40 * scale,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16 * scale),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        child: Text(
                          slide.subtitle,
                          key: ValueKey('sub_$idleSlideIndex'),
                          textAlign: TextAlign.center,
                          style: _getFontStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                      SizedBox(height: 40 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              effectiveSuggestions.length,
                              (i) {
                                final s = effectiveSuggestions[i];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10 * scale),
                                  child: IdleSuggestionCard(
                                    suggestion: s,
                                    accent: _accentForSlide(i, tvTheme),
                                    scale: scale,
                                    active: i == slide.suggestionIndex,
                                    labelStyle: labelStyle,
                                    hintFontSize: cardHintSize,
                                    cardWidth: cardWidth,
                                    cardHeight: cardHeight,
                                  ),
                                );
                              },
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
                      Text(
                        tvTheme.qrPromptCta,
                        style: _getFontStyle(
                          fontSize: ctaSize,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w800,
                          color: accent.withValues(alpha: 0.9),
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
                    monoFontSize: footerMonoSize,
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
