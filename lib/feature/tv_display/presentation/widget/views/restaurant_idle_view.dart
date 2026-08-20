import 'dart:math';
import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/restaurant_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/floating_particles.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/restaurant/floating_gourmet_cards.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/restaurant/restaurant_empty_state_view.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';

/// Ultra-Cool Modern Fine Dining & Gourmet Menu Signage Display View for Restaurants.
class RestaurantIdleView extends StatelessWidget {
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

  const RestaurantIdleView({
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
    final tvTheme = BusinessTypeTvTheme.of('restaurant');

    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final String fallbackCurrency = settings?.currency ?? 'ETB';

          // Dynamic Data Mapping directly from Live Firestore Stream
          final List<IdleSlide> rawSlides = menuItems.isNotEmpty
              ? menuItems.map((item) {
                  final String name =
                      (item['name'] ?? item['title'] ?? 'Special Dish')
                          .toString()
                          .trim();
                  final String desc =
                      (item['description'] ?? item['desc'] ?? '')
                          .toString()
                          .trim();

                  final priceRaw = item['price'];
                  final double? price = (priceRaw is num)
                      ? priceRaw.toDouble()
                      : (priceRaw != null
                          ? double.tryParse(priceRaw.toString().trim())
                          : null);

                  final String? img = item['imageUrl']?.toString().trim();

                  final catField =
                      item['category'] ?? item['category '] ?? item['cat'];
                  String cat = 'MAIN COURSES';
                  if (catField is List && catField.isNotEmpty) {
                    cat = catField.first.toString().trim();
                  } else if (catField is Map) {
                    cat = (catField['name'] ??
                            catField['title'] ??
                            'MAIN COURSES')
                        .toString()
                        .trim();
                  } else if (catField != null &&
                      catField.toString().trim().isNotEmpty) {
                    cat = catField.toString().trim();
                  }

                  final String curr =
                      (item['currency']?.toString().trim().isNotEmpty == true)
                          ? item['currency'].toString().trim().toUpperCase()
                          : fallbackCurrency.toUpperCase();

                  final String? pairing =
                      (item['pairing'] ?? item['pairingNote'])
                          ?.toString()
                          .trim();

                  return IdleSlide(
                    emoji: _getEmojiForDish(name, cat),
                    headline: name,
                    subtitle: desc,
                    imageUrl: (img != null && img.isNotEmpty) ? img : null,
                    price: price,
                    currency: curr,
                    category: cat,
                    pairingNote: (pairing != null && pairing.isNotEmpty)
                        ? pairing
                        : null,
                    suggestionIndex: 0,
                  );
                }).toList()
              : (effectiveSlides ?? const <IdleSlide>[]);

          // Deduplicate slides by dish headline
          final Set<String> seenKeys = <String>{};
          final List<IdleSlide> slidesToUse = [];
          for (final slide in rawSlides) {
            final key = slide.headline.trim().toLowerCase();
            if (seenKeys.add(key)) {
              slidesToUse.add(slide);
            }
          }

          if (slidesToUse.isEmpty) {
            return RestaurantEmptyStateView(
              scale: scale,
              orgName: orgName,
              bgColor: tvTheme.bgColor,
            );
          }

          final String? effectiveQr =
              (qrCodeUrl != null && qrCodeUrl!.isNotEmpty)
                  ? qrCodeUrl
                  : settings?.qrCodeUrl;

          // Calculate compact QR code footprint dimensions based on user's customQrSize
          final double baseQr = settings?.qrCodeSize ?? 180.0;
          final double qrRenderedSize = baseQr * (scale * 0.7);
          final double qrTotalWidth =
              (effectiveQr != null && effectiveQr.isNotEmpty)
                  ? qrRenderedSize + (20 * scale)
                  : 0.0;
          final double qrTotalHeight =
              (effectiveQr != null && effectiveQr.isNotEmpty)
                  ? qrRenderedSize + (30 * scale)
                  : 0.0;

          return Stack(
            children: [
              // Ambient warm champagne & slate daylight background with integrated top bar
              RestaurantBackground(
                box: box,
                orbAnim: orbAnim,
                orgName: orgName,
                now: now,
                showParticles: false,
              ),
              FloatingParticles(
                  seed: now.millisecond,
                  accent: tvTheme.cardBorderColor,
                  businessType: 'restaurant'),
              // Main Screen Display Area: Dynamic Floating Gourmet Dish Cards
              Positioned(
                top: 105 * scale,
                left: 0,
                right: 0,
                bottom: 20 * scale,
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: FloatingGourmetCards(
                    items: slidesToUse,
                    scale: scale,
                    fallbackCurrency: fallbackCurrency,
                    qrWidth: qrTotalWidth,
                    qrHeight: qrTotalHeight,
                    leftMargin: 60.0,
                    rightMargin: 0.0,
                  ),
                ),
              ),

              // Floating Luxury QR Ordering Badge (Bottom Right)
              if (effectiveQr != null && effectiveQr.isNotEmpty)
                Positioned(
                  right: 36 * scale,
                  bottom: 40 * scale,
                  child: IdleQrCard(
                    qrCodeUrl: effectiveQr,
                    scale: scale * 0.7,
                    tvTheme: tvTheme,
                    radarAnim: idleRadarAnim,
                    customQrSize: settings?.qrCodeSize,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _getEmojiForDish(String name, String cat) {
    final lower = name.toLowerCase();
    if (lower.contains('burger') || lower.contains('wagyu')) return '🍔';
    if (lower.contains('calamari') || lower.contains('squid')) return '🦑';
    if (lower.contains('steak') || lower.contains('ribeye')) return '🥩';
    if (lower.contains('risotto') || lower.contains('truffle')) return '🍄';
    if (lower.contains('salad')) return '🥗';
    if (lower.contains('taco') || lower.contains('lobster')) return '🌮';
    if (lower.contains('cake') || lower.contains('lava')) return '🍰';
    if (lower.contains('crème') || lower.contains('brûlée')) return '🍮';
    return '🍽️';
  }
}
