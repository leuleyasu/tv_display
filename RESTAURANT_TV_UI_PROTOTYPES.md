# 🍽️ Restaurant TV Display UI Prototypes

This document presents the **16:9 4K TV UI Prototypes** designed for restaurant digital signage, ambiance displays, and menu boards.

---

## 📺 Signage & Ambiance Displays (Pure Showcase & Menu Boards)

````carousel
![Pure Menu Board Showcase (3-Column Layout)](file:///home/l3ul/HoursSignage/night_track_tv/restaurant_tv_no_ordering_1.jpg)
<!-- slide -->
![Cinematic Specials Showcase & Ambiance Gallery](file:///home/l3ul/HoursSignage/night_track_tv/restaurant_tv_no_ordering_2.jpg)
````

### Layout Features (Signage & Showcase):
- **Structured Menu Grid**: Organized sections for *Appetizers*, *Mains*, *Daily Specials*, and *Desserts* with clean typography and pricing.
- **Cinematic Photography Spotlight**: Highlights chef signature dishes (dry-aged steaks, seafood platters) in high contrast 16:9 layout.
- **Atmospheric Visuals**: Warm ambient lighting, slate/wood backdrop textures, and subtle amber glow.
- **Live Ticker Bar**: Displays restaurant announcements, happy hour hours, weather, or news updates at the bottom.
- **No Ordering UI**: Clean visual experience with no checkout screens or ordering prompts.

---

## 📱 Interactive & Engagement Displays (Optional Features)

If you decide to add guest interaction in the future:

````carousel
![Horizontal Cards & Table QR Spotlight](file:///home/l3ul/HoursSignage/night_track_tv/restaurant_tv_prototype_1.jpg)
<!-- slide -->
![Split-Screen Chef Spotlight & Live Shoutouts](file:///home/l3ul/HoursSignage/night_track_tv/restaurant_tv_prototype_2.jpg)
<!-- slide -->
![Emerald & Gold Luxury Lounge & Bar Display](file:///home/l3ul/HoursSignage/night_track_tv/restaurant_tv_prototype_3.jpg)
````

---

## 🛠️ Codebase Implementation Notes

The repository contains ready-to-use Flutter components for this display engine:

- **Restaurant Display View Widget**: [`RestaurantIdleView`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/views/restaurant_idle_view.dart)
- **Background Shader & Gradient Engine**: [`RestaurantBackground`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/backgrounds/restaurant_background.dart)
- **Polymorphic Dispatcher**: [`IdleDisplayViewFactory`](file:///home/l3ul/HoursSignage/night_track_tv/lib/feature/tv_display/presentation/widget/idle_display_view_factory.dart)
- **Theme Tokens**: [`BusinessTypeTvTheme`](file:///home/l3ul/HoursSignage/night_track_tv/lib/core/config/business_type_tv_theme.dart)
