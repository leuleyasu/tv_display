# ☕ Cafe & Coffee Shop TV Display UI Prototypes

This document presents **16:9 4K TV UI Prototypes** designed specifically for Coffee Shops, Artisan Cafes, and Bakeries.

---

## ☕ Cafe Showcase & Digital Menu Boards

````carousel
![Artisan Coffee & Bakery 3-Column Menu Board](file:///home/l3ul/HoursSignage/night_track_tv/cafe_tv_prototype_1.jpg)
<!-- slide -->
![Cinematic Coffee Ambiance & Barista Specials](file:///home/l3ul/HoursSignage/night_track_tv/cafe_tv_prototype_2.jpg)
````

### Layout Features:
- **Cozy Espresso Palette**: Deep mahogany tones, warm latte radial lighting, amber price callouts, and clean sans-serif/serif typography.
- **3-Column Board Structure**: Dedicated columns for *Espresso & Brews*, *Bakery & Pastries*, and *Specialty Drinks*.
- **Integrated Free Wi-Fi Info**: Displays guest network name (`Wi-Fi: ArtisanGuest`) in top right header.
- **Barista Specials Showcase**: Left-hand cinematic coffee photography paired with a glassmorphic menu card.
- **Fresh Bakery Marquee**: Bottom scrolling ticker announcing daily bake times and seasonal bean origins.

---

## 🛠️ Codebase Implementation Notes

The Flutter codebase provides native support for Cafe screens:

- **Cafe Display View Widget**: [`CafeIdleView`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/views/cafe_idle_view.dart)
- **Cafe Ambient Background Shader**: [`CafeBackground`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/backgrounds/cafe_background.dart)
- **Top Header Bar (With Time & Wi-Fi)**: [`TvTopHeaderBar`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/tv_top_header_bar.dart)
- **Theme Definition**: `BusinessTypeTvTheme.of('cafe')` in [`BusinessTypeTvTheme`](file:///home/l3ul/HoursSignage/night_track_tv/lib/core/config/business_type_tv_theme.dart)
