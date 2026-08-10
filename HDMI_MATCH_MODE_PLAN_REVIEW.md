# ⚽ Strategic & Technical Review: HDMI & DSTV Match Mode Plan

## Executive Summary

Pursuing the **HDMI & DSTV Screen Sharing ("Match Mode")** B2B venue model is **100% the best strategic decision**. It directly solves the biggest barrier in venue digital signage: **keeping ad monetization running 24/7, even during high-traffic live sports broadcasts (DSTV, Premier League, Champions League, World Cup)**.

---

## 🔍 Evaluation of the 3 Operating Modes

```
+-----------------------------------------------------------------------------------+
|                               MODE 1: L-BAR SPLIT                                 |
| +-----------------------------------------------+ +-----------------------------+ |
| |                                               | |                             | |
| |           75% MAIN VIEWPORT                   | |       20% AD SIDEBAR        | |
| |    (Live DSTV HDMI / Stream / Video)          | |  (Rotating Ads & QR Code)   | |
| |                                               | |                             | |
| +-----------------------------------------------+ +-----------------------------+ |
| |                       5% BOTTOM TICKER (Scores & Sponsors)                     | |
+-----------------------------------------------------------------------------------+
```

### Mode 1: L-Bar Split Screen (HDMI Input & Streaming) — ⭐⭐⭐⭐⭐ (Golden Standard)
- **How it works**: Divides screen into **75% Live Sports** + **20% Ad Sidebar** + **5% Scrolling Marquee**.
- **Business Value**: Venue owners never turn off your signage system because their patrons get live sports while the venue continues generating ad revenue.
- **Hardware**: Compatible with Android TV boxes featuring HDMI-IN passthrough (Zidoo, Formuler, Tronsmart) or live RTSP/HLS stream URLs.

### Mode 2: Floating System Ad Dock (`SYSTEM_ALERT_WINDOW`) — ⭐⭐⭐⭐ (High Practicality)
- **How it works**: Runs in the background on Android TV devices, pinning a frosted-glass ad banner over physical DSTV decoder broadcasts.
- **Business Value**: Eliminates the need for expensive HDMI hardware capture cards in venues with legacy decoders.

### Mode 3: Live Sports Match Center HUD (API Driven) — ⭐⭐⭐⭐ (Software Fallback)
- **How it works**: Renders real-time match scores, 2D pitch animations, and goal logs driven by sports APIs ([`WorldCupService`](file:///home/l3ul/HoursSignage/night_track_tv/lib/core/services/world_cup_service.dart)) alongside ad sidebars.
- **Business Value**: Ideal when direct video streams or decoders are unavailable.

---

## 🛠️ Architecture & Roadmap for Codebase Integration

1. **Settings Data Model (`lib/core/models/settings_model.dart`)**:
   Add `MatchModeSettings` to parse real-time Firebase toggles (`layoutType`, `videoSource`, `sidebarWidthPercent`).

2. **Responsive Screen Layout (`lib/feature/tv_display/presentation/screen/tv_display_screen.dart`)**:
   Wrap the active view in a `Row` container to seamlessly toggle between **Full Display** and **L-Bar Split Screen**.

3. **Android HDMI-IN Native View**:
   Integrate Android `TvView` / `SurfaceView` platform channels for hardware HDMI passthrough.
