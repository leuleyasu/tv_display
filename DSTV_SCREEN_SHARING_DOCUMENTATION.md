# Full Feature Documentation: DSTV & Live Sports Screen Space Sharing ("Match Mode")

**System:** `night_track_tv` (Digital Signage & Venue Ad Network)
**Target Platform:** Smart TVs, Android TV, FireTV, HDMI Passthrough Devices
**Module:** `lib/feature/tv_display`

---

## 1. Executive Summary & Business Objective

In venue environments (sports bars, lounges, restaurants, night clubs), venue managers prioritize broadcasting live sports (e.g., Premier League, UEFA Champions League, DSTV SuperSport broadcasts).

If playing DSTV requires turning off or minimizing the ad app, **100% of ad impressions and venue revenue are lost during peak foot-traffic hours**.

The **Screen Space Sharing System ("Match Mode")** ensures `night_track_tv` **NEVER CLOSES**. When match mode is enabled from the Web Dashboard, the app dynamically reorganizes its viewport to share screen space with DSTV content, preserving **20%–30% of screen area** for continuous ad revenue, sponsor banners, DJ shoutouts, and revenue-generating QR codes.

---

## 2. System Architecture & Operating Modes

```
+-----------------------------------------------------------------------------------+
|                                  WEB DASHBOARD                                    |
|                 Venue Manager toggles "Match Mode" ON/OFF                          |
+-----------------------------------------+-----------------------------------------+
                                          | Real-time Firebase Sync
                                          v
+-----------------------------------------------------------------------------------+
|                                NIGHT_TRACK_TV                                     |
|                 Listens to _repo.settingsStream() changes                         |
|                 Dynamically transitions UI layout without restart                 |
+-----------------------------------------+-----------------------------------------+
                                          |
                   +----------------------+----------------------+
                   |                      |                      |
                   v                      v                      v
        [ MODE 1: L-BAR SPLIT ]  [ MODE 2: FLOATING DOCK ]  [ MODE 3: MATCH CENTER ]
        • 75% Live Video Stream   • Full DSTV Broadcast      • API Live Match Score
        • 25% Ad Sidebar & Ticker • 15% Floating Ad Dock     • Ad Sidebar & Ticker
```

---

## 3. Detailed Operating Modes

### Mode 1: L-Bar Split Screen (Stream & HDMI Input)

- **Main Viewport (75% Screen Space):** Displays live HLS/RTSP streams, web video feeds, or native HDMI-IN decoder video.
- **Right Sidebar (20% Screen Space):** Continuously cycles campaign ads, venue food/drinks specials, and dynamic ordering QR codes.
- **Bottom Ticker (5% Screen Space):** Displays scrolling sponsor alerts, live match minutes, and venue announcements.

### Mode 2: System Floating Ad Overlay (Physical DSTV Decoders)

- **Primary Screen (85% Screen Space):** Full-screen physical DSTV Decoder broadcxast.
- **Floating Ad Dock (15% Screen Space):** Utilizes Android `SYSTEM_ALERT_WINDOW` or Accessibility Overlay permissions. `night_track_tv` runs in the background while keeping a frosted-glass floating ad banner pinned to the bottom of the TV screen over top of the DSTV broadcast.

### Mode 3: Live Sports Match Center HUD (Software API)

- **Main Viewport (75% Screen Space):** Renders an interactive animated football pitch, live scores, goal logs, possession meters, and match stats driven by real-time sports APIs (`WorldCupService` / `LiveSportsService`).
- **Surrounding Ad Bar (25% Screen Space):** Displays rotating venue ads and customer shoutouts.

---

## 4. Backend & Dashboard Data Schema

### Firestore Collection: `tv_settings/{organizationId}`

```json
{
  "businessType": "lounge",
  "matchMode": {
    "enabled": true,
    "layoutType": "L_BAR_SPLIT",
    "videoSource": "HDMI_INPUT",
    "streamUrl": "https://stream.venue.com/live.m3u8",
    "adSidebarPosition": "RIGHT",
    "sidebarWidthPercent": 25,
    "bottomTickerEnabled": true,
    "autoSwitchOnMatchTime": true
  }
}
```

### Dart Model Integration (`lib/core/models/settings_model.dart`):

```dart
class MatchModeSettings {
  final bool enabled;
  final String layoutType; // 'L_BAR_SPLIT', 'FLOATING_DOCK', 'MATCH_CENTER'
  final String videoSource; // 'HDMI_INPUT', 'STREAM_URL', 'SPORTS_API'
  final String? streamUrl;
  final double sidebarWidthPercent;
  final bool bottomTickerEnabled;

  const MatchModeSettings({
    required this.enabled,
    required this.layoutType,
    required this.videoSource,
    this.streamUrl,
    this.sidebarWidthPercent = 25.0,
    this.bottomTickerEnabled = true,
  });

  factory MatchModeSettings.fromJson(Map<String, dynamic> json) {
    return MatchModeSettings(
      enabled: json['enabled'] as bool? ?? false,
      layoutType: json['layoutType'] as String? ?? 'L_BAR_SPLIT',
      videoSource: json['videoSource'] as String? ?? 'SPORTS_API',
      streamUrl: json['streamUrl'] as String?,
      sidebarWidthPercent: (json['sidebarWidthPercent'] as num?)?.toDouble() ?? 25.0,
      bottomTickerEnabled: json['bottomTickerEnabled'] as bool? ?? true,
    );
  }
}
```

---

## 5. UI Layout Implementation (`tv_display_screen.dart`)

The implementation wraps `TvDisplayScreen` inside a responsive split-view container when `_settings?.matchMode.enabled == true`:

```dart
Widget buildMatchModeContainer(BuildContext context, double scale) {
  final mode = _settings?.matchMode;
  if (mode == null || !mode.enabled) {
    return _buildStandardDisplayScreen();
  }

  return Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        Row(
          children: [
            // 1. MAIN MATCH / VIDEO CONTENT AREA (75% Width)
            Expanded(
              flex: (100 - mode.sidebarWidthPercent).toInt(),
              child: Stack(
                children: [
                  if (mode.videoSource == 'HDMI_INPUT')
                    const AndroidHdmiInputView()
                  else if (mode.videoSource == 'STREAM_URL')
                    VenueVideoPlayer(url: mode.streamUrl!)
                  else
                    const LiveMatchCenterPitchView(),

                  // Floating HUD Overlay for Scores
                  Positioned(
                    top: 20 * scale,
                    right: 20 * scale,
                    child: WorldCupOverlay(scale: scale * 0.8),
                  ),
                ],
              ),
            ),

            // 2. PERMANENT AD SIDEBAR (25% Width)
            SizedBox(
              width: MediaQuery.of(context).size.width * (mode.sidebarWidthPercent / 100),
              child: Column(
                children: [
                  Expanded(child: SignageAdOverlay(scale: scale * 0.9)),
                  const QrCodeWidget(),
                ],
              ),
            ),
          ],
        ),

        // 3. BOTTOM SCROLLING TICKER BAR
        if (mode.bottomTickerEnabled)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SportsTickerBar(scale: scale),
          ),
      ],
    ),
  );
}
```

---

## 6. Hardware Compatibility & Deployment Matrix

| Setup Scenario                                        | Hardware Requirement        | Setup Effort                     | Impression Retention |
| :---------------------------------------------------- | :-------------------------- | :------------------------------- | :------------------- |
| **A. Standard Smart TV (In-App Sports API / Stream)** | Any Smart TV or TV Stick    | 0 Min (Software Only)            | 100%                 |
| **B. Physical DSTV Decoder + Floating Banner**        | Any Android TV Device       | 1 Min (Grant Overlay Permission) | 100%                 |
| **C. Physical DSTV Decoder + HDMI In**                | Android TV Box with HDMI-IN | Plug DSTV HDMI into Android Box  | 100%                 |

---

## 7. Rollout Checklist

1. **Backend Integration:** Update Firestore schema to include `matchMode` configuration in `tv_settings`.
2. **Dashboard UI:** Add a toggle switch and layout selector in the Web Admin Dashboard.
3. **Flutter App Integration:** Update `tv_display_screen.dart` with the `buildMatchModeContainer` split view.
4. **Android Overlay Permission:** Add `SYSTEM_ALERT_WINDOW` permission to `AndroidManifest.xml` for floating dock support.
