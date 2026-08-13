# Implementation Plan: Business-Specific Backgrounds & Custom Idle Views

## Executive Overview

Currently, all business types (`nightclub`, `restaurant`, `cafe`, `gym`, `lounge`) rely on a single generic `IdleDisplayView` and `AmbientOrbs` component. To elevate visual excellence and provide tailored user experiences for each venue type, we will build a **Modular Business-Specific UI Engine** featuring unique animated backgrounds, custom layouts, and specialized widgets for each business type.

---

## 1. Component Architecture & Directory Layout

```
lib/feature/tv_display/presentation/
├── widget/
│   ├── backgrounds/                     # Custom Animated Background Engines
│   │   ├── nightclub_background.dart    # Neon Equalizer, Soundwave Ripples, Laser Sweeps
│   │   ├── restaurant_background.dart   # Warm Embers, Slate/Wood Texture, Golden Glow
│   │   ├── cafe_background.dart         # Morning Sunbeams, Espresso Bokeh, Steam Particles
│   │   ├── gym_background.dart          # Carbon Grid, Cyan Pulse Lines, Heart Rate HUD
│   │   └── lounge_background.dart       # Glassmorphism, Champagne Gold Bokeh, Smoke Drift
│   ├── views/                           # Custom Business Idle Views
│   │   ├── nightclub_idle_view.dart     # Party Vibe, DJ Request Spotlight, Neon Theme
│   │   ├── restaurant_idle_view.dart    # Chef Specials, Menu Items, Table QR Focus
│   │   ├── cafe_idle_view.dart          # Morning Specials, Free Wi-Fi QR, Ticker Bar
│   │   ├── gym_idle_view.dart           # Class Schedule HUD, Workout Motivation, Energy Meter
│   │   └── lounge_idle_view.dart        # VIP Bottle Specials, Luxury Gold Framing
│   └── idle_display_view_factory.dart   # Polymorphic Dispatcher (Factory)
```

---

## 2. Business Type Specifications

### 1. 🍹 Nightclub
- **Background**: Pulsing neon equalizer bars, reactive pink/violet soundwave ripples, laser beam sweeps.
- **View Highlights**: Party energy meter, DJ request QR spotlight, high-impact neon typography.

### 2. 🍷 Restaurant
- **Background**: Soft candle-lit golden ambient glow, dark slate/wood texture, floating warm ember particles.
- **View Highlights**: Chef's recommendations, featured dish specials with prices, table QR ordering focus.

### 3. ☕ Cafe
- **Background**: Warm espresso/latte brown gradients, soft morning sunbeams, coffee steam particles.
- **View Highlights**: Morning coffee combos, Free Wi-Fi connect QR code, news ticker bar.

### 4. 🏋️ Gym & Fitness
- **Background**: Dark carbon fiber grid, animated cyan/electric pulse lines, heart-rate pulse wave animation.
- **View Highlights**: Daily workout class schedules (Zumba, Crossfit), hydration reminders, athletic typography.

### 5. 🍸 Lounge & Bar
- **Background**: Ultra-luxurious glassmorphism, champagne gold floating bokeh particles, ambient smoke drift.
- **View Highlights**: Premium bottle service menu spotlight, VIP reservations QR, luxury gold typography.

---

## 3. Polymorphic Dispatcher (`IdleDisplayViewFactory`)

Instead of rendering a single `IdleDisplayView`, `tv_display_screen.dart` will invoke `IdleDisplayViewFactory`:

```dart
class IdleDisplayViewFactory extends StatelessWidget {
  final String businessType;
  // ... parameters

  @override
  Widget build(BuildContext context) {
    switch (businessType) {
      case 'restaurant':
        return RestaurantIdleView(...);
      case 'cafe':
        return CafeIdleView(...);
      case 'gym':
        return GymIdleView(...);
      case 'lounge':
        return LoungeIdleView(...);
      case 'nightclub':
      default:
        return NightclubIdleView(...);
    }
  }
}
```

---

## 4. Proposed Implementation Steps

1. **Create Background Components**: Implement 5 unique animated background widgets in `lib/feature/tv_display/presentation/widget/backgrounds/`.
2. **Create Specialized Views**: Implement 5 custom idle view widgets in `lib/feature/tv_display/presentation/widget/views/`.
3. **Build Polymorphic Factory**: Create `idle_display_view_factory.dart` to cleanly route rendering based on `effectiveBusinessType`.
4. **Update `TvDisplayScreen`**: Replace the direct `IdleDisplayView` invocation with `IdleDisplayViewFactory`.
5. **Verify & Analyze**: Run `flutter analyze` to ensure zero compile warnings/errors.

---

## User Input & Confirmation

Please review this plan. Would you like to proceed with implementing these 5 specialized background and idle view components?
