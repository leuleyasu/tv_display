# 📋 Implementation Plan: Restaurant Chef Spotlight & Split-Screen View

## 1. Domain Naming & Architecture Overview

Instead of arbitrary numbered names (e.g., `prototype2`), we use **meaningful domain-driven naming**:

- **File**: [`lib/feature/tv_display/presentation/widget/views/restaurant_chef_spotlight_view.dart`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/views/restaurant_chef_spotlight_view.dart)
- **Widget Class**: `RestaurantChefSpotlightView`
- **Layout Identity**: `CHEF_SPOTLIGHT` (Cinematic Split-Screen Showcase)

---

## 2. Component Structure Breakdown

```
+-----------------------------------------------------------------------------------+
|                            RESTAURANT_BACKGROUND                                  |
|         (Warm Candle-Lit Ember Radial Glow + Integrated Header Bar & Live Clock)   |
+-----------------------------------------------------------------------------------+
|                                                                                   |
|  +---------------------------------------+ +-----------------------------------+  |
|  |       LEFT: CHEF RECOMMENDATION       | |     RIGHT: POPULAR FAVORITES      |  |
|  |               (56% Width)             | |            (44% Width)           |  |
|  |  • Gold 'CHEF RECOMMENDATION' Badge   | |  • Category Icon Badges         |  |
|  |  • High-Res Hero Food Photography     | |  • Item Titles                  |  |
|  |  • Dish Headline & Description        | |  • Glowing Amber Price Tags     |  |
|  |  • Prominent Price Badge (e.g. 450 ETB) | |  • Vertical Specials List       |  |
|  +---------------------------------------+ +-----------------------------------+  |
|                                                                                   |
+-----------------------------------------------------------------------------------+
|                  BOTTOM TICKER: DINING HALL UPDATES & ANNOUNCEMENTS               |
+-----------------------------------------------------------------------------------+
```

---

## 3. Detailed Sub-Widgets & Methods

### A. `_buildChefRecommendationCard()` (Left Hero Panel - 56% Width)
- **Header**: Gold badge with `workspace_premium_rounded` icon + Category Tag (`CHEF RECOMMENDATION`) + Price Pill (`450 ETB`).
- **Hero Photography**: Full-bleed `Image.network` with rounded corners & dark slate fallback image (`_buildFallbackImage`).
- **Typography**: `GoogleFonts.playfairDisplay` for luxury dish headlines + `GoogleFonts.inter` for descriptions.

### B. `_buildPopularFavoritesList()` (Right Column List - 44% Width)
- **Header**: Section title with `restaurant_menu_rounded` icon (`POPULAR FAVORITES & SPECIALS`).
- **List Items**: Structured `ListView.separated` featuring emoji/category badges, dish titles, descriptions, and price pills.

### C. `_buildDiningUpdatesMarquee()` (Bottom Marquee - 100% Width)
- **Tag**: `DINING UPDATES` badge in solid gold.
- **Marquee Text**: Live scrolling greetings, chef spotlight alerts, and venue announcements.

---

## 4. Proposed Implementation Steps

1. **Create File**: Create [`lib/feature/tv_display/presentation/widget/views/restaurant_chef_spotlight_view.dart`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/views/restaurant_chef_spotlight_view.dart) with `RestaurantChefSpotlightView`.
2. **Update View Factory**: Register `RestaurantChefSpotlightView` in [`idle_display_view_factory.dart`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/idle_display_view_factory.dart).
3. **Verify & Analyze**: Run `flutter analyze` to ensure 0 lint or compile errors.
