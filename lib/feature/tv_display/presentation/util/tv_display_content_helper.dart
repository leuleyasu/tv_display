import 'package:flutter/material.dart';

import '../../domain/models/idle_content.dart';
import '../config/business_configs/restaurant_config.dart';
import '../config/business_tv_config.dart';
import '../cubit/tv_display_state.dart';

/// Helper methods to parse menu items, custom scenes, and suggestion labels
/// into business-specific [IdleSuggestion] and [IdleSlide] data models.
class TvDisplayContentHelper {
  static List<IdleSuggestion> getEffectiveSuggestions(
      TvDisplayState state, String businessType) {
    if (state.menuItems.isNotEmpty) {
      final categories = state.menuItems
          .map((item) {
            final catField = item['category'] ?? item['category '];
            if (catField is List && catField.isNotEmpty) {
              return catField.first.toString().trim();
            } else if (catField is Map) {
              return (catField['name'] ?? catField['title'] ?? '')
                  .toString()
                  .trim();
            } else if (catField is String) {
              return catField.trim();
            }
            return null;
          })
          .where((cat) => cat != null && cat.isNotEmpty)
          .toSet()
          .cast<String>()
          .toList();

      if (categories.isNotEmpty) {
        return categories.take(4).map((cat) {
          final catLower = cat.toLowerCase();
          IconData icon = Icons.restaurant_menu_rounded;
          if (catLower.contains('drink') ||
              catLower.contains('beverage') ||
              catLower.contains('cocktail') ||
              catLower.contains('wine') ||
              catLower.contains('coffee') ||
              catLower.contains('tea')) {
            icon = Icons.local_bar_rounded;
          } else if (catLower.contains('dessert') ||
              catLower.contains('sweet') ||
              catLower.contains('pastry') ||
              catLower.contains('cake')) {
            icon = Icons.icecream_rounded;
          } else if (catLower.contains('starter') ||
              catLower.contains('appetizer') ||
              catLower.contains('snack')) {
            icon = Icons.tapas_rounded;
          } else if (catLower.contains('special') ||
              catLower.contains('chef')) {
            icon = Icons.star_rounded;
          }
          return IdleSuggestion(
            icon: icon,
            label: cat.toUpperCase(),
          );
        }).toList();
      }
    }

    final defaultSuggs = BusinessTvConfig.getSuggestions(businessType);
    final labels = state.settings?.idleSuggestionLabels;
    if (labels == null || labels.length < defaultSuggs.length) {
      return defaultSuggs;
    }
    return List.generate(defaultSuggs.length, (i) {
      return IdleSuggestion(
        icon: defaultSuggs[i].icon,
        label: labels[i],
      );
    });
  }

  static List<IdleSlide> getEffectiveSlides(
      TvDisplayState state, String businessType) {
    if (state.menuItems.isNotEmpty) {
      final suggs = getEffectiveSuggestions(state, businessType);
      final maxIdx = suggs.length - 1;
      return state.menuItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final catField = item['category'] ?? item['category '];
        String? rawCatStr;
        if (catField is List && catField.isNotEmpty) {
          rawCatStr = catField.first.toString().trim();
        } else if (catField is Map) {
          rawCatStr =
              (catField['name'] ?? catField['title'] ?? '').toString().trim();
        } else if (catField is String) {
          rawCatStr = catField.trim();
        }
        final rawCat =
            (rawCatStr != null && rawCatStr.isNotEmpty) ? rawCatStr : 'MENU';

        final categoryLower = rawCat.toLowerCase();
        String emoji = '🍽️';
        if (categoryLower.contains('coffee') ||
            categoryLower.contains('espresso') ||
            categoryLower.contains('latte')) {
          emoji = '☕';
        } else if (categoryLower.contains('drink') ||
            categoryLower.contains('beverage') ||
            categoryLower.contains('tea')) {
          emoji = '🍹';
        } else if (categoryLower.contains('alcohol') ||
            categoryLower.contains('wine') ||
            categoryLower.contains('cocktail')) {
          emoji = '🍷';
        } else if (categoryLower.contains('special') ||
            categoryLower.contains('combo')) {
          emoji = '⭐';
        } else if (categoryLower.contains('pastry') ||
            categoryLower.contains('cake') ||
            categoryLower.contains('dessert')) {
          emoji = '🍰';
        }

        final priceRaw = item['price'];
        final priceNum = (priceRaw as num?)?.toDouble();
        final currencyStr = (item['currency'] as String?) ?? 'ETB';
        final name = (item['name'] as String? ?? '').toUpperCase();
        final desc = item['description'] as String? ?? '';
        final imageUrl = item['imageUrl'] as String?;

        return IdleSlide(
          emoji: emoji,
          headline: name,
          subtitle: desc,
          suggestionIndex: idx % (maxIdx < 0 ? 1 : maxIdx + 1),
          imageUrl: imageUrl,
          price: priceNum,
          currency: currencyStr,
          category: rawCat,
        );
      }).toList();
    }

    final scenes = state.settings?.idleScenes;
    if (scenes != null && scenes.isNotEmpty) {
      final suggs = getEffectiveSuggestions(state, businessType);
      final maxIdx = suggs.length - 1;
      return scenes.map((s) {
        return IdleSlide(
          emoji: s.emoji,
          headline: s.headline,
          subtitle: s.subtitle,
          suggestionIndex: s.suggestionIndex.clamp(0, maxIdx < 0 ? 0 : maxIdx),
        );
      }).toList();
    }

    return RestaurantTvConfig.defaultSlides;
  }
}
