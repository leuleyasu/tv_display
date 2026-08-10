import 'dart:math';
import 'package:flutter/material.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/restaurant_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/restaurant/chef_recommendation_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/restaurant/dining_updates_marquee_bar.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/restaurant/popular_favorites_list_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/restaurant/restaurant_empty_state_view.dart';

/// Prototype 2: Modular Split-Screen Chef Spotlight & Daily Specials Display View.
/// Perfectly proportioned centered UI with balanced padding on all 4 sides.
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

          // Dynamic Data Mapping from Live Firestore Stream
          final List<IdleSlide> slidesToUse = menuItems.isNotEmpty
              ? menuItems.map((item) {
                  final String name = item['name'] as String? ?? 'Special Dish';
                  final String desc = item['description'] as String? ?? '';
                  final double? price = (item['price'] is num)
                      ? (item['price'] as num).toDouble()
                      : double.tryParse(item['price']?.toString() ?? '');
                  final String? img = item['imageUrl'] as String?;
                  final String cat =
                      item['category'] as String? ?? 'MAIN COURSES';
                  final String curr =
                      item['currency'] as String? ?? fallbackCurrency;
                  final String? pairing = item['pairing'] as String? ??
                      item['pairingNote'] as String?;
                  return IdleSlide(
                    emoji: _getEmojiForDish(name, cat),
                    headline: name,
                    subtitle: desc,
                    imageUrl: img,
                    price: price,
                    currency: curr,
                    category: cat,
                    pairingNote: pairing,
                    suggestionIndex: 0,
                  );
                }).toList()
              : (effectiveSlides ?? const <IdleSlide>[]);

          if (slidesToUse.isEmpty) {
            return RestaurantEmptyStateView(
              scale: scale,
              orgName: orgName,
              bgColor: tvTheme.bgColor,
            );
          }

          final IdleSlide featuredSlide =
              slidesToUse[idleSlideIndex % slidesToUse.length];
          final List<IdleSlide> sideItems = slidesToUse.length > 1
              ? slidesToUse.where((s) => s != featuredSlide).toList()
              : slidesToUse;

          final double baseFont = settings?.fontSize ?? 72.0;

          final String tickerContent = (settings?.tickerNewsText != null &&
                  settings!.tickerNewsText.isNotEmpty)
              ? settings!.tickerNewsText
              : '✦ Welcome to ${orgName.isNotEmpty ? orgName : "our Dining Hall"}! ✦ Featured Special: "${featuredSlide.headline}" ✦ Enjoy your dining experience!';

          return Stack(
            children: [
              // Ambient warm slate & glowing ember background with integrated top bar
              RestaurantBackground(
                box: box,
                orbAnim: orbAnim,
                orgName: orgName,
                now: now,
              ),

              // Main Screen Split-Screen Layout with Centered Padding
              Positioned(
                top: 100 * scale,
                left: 100 * scale,
                right: 100 * scale,
                bottom: 100 * scale,
                child: Center(
                  child: FadeTransition(
                    opacity: fadeAnim,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Section: Chef Recommendation Spotlight Card
                        Expanded(
                          flex: 56,
                          child: ChefRecommendationCard(
                            slide: featuredSlide,
                            scale: scale,
                            baseFont: baseFont,
                            fallbackCurrency: fallbackCurrency,
                          ),
                        ),
                        SizedBox(width: 28 * scale),

                        // Right Section: Popular Favorites List Card
                        Expanded(
                          flex: 44,
                          child: PopularFavoritesListCard(
                            sideItems: sideItems,
                            scale: scale,
                            fallbackCurrency: fallbackCurrency,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Section: Continuous Marquee Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 48 * scale,
                child: DiningUpdatesMarqueeBar(
                  tickerContent: tickerContent,
                  scale: scale,
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
