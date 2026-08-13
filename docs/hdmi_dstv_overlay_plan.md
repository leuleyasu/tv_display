# DStv HDMI Live Stream & Signage Overlay Implementation Plan (v1.2 - Final Spec)

## 📌 Executive Summary
This document outlines the architecture and phased execution plan for embedding a live **DStv HDMI video feed** directly inside the `night_track_tv` Flutter application canvas. This enables real-time overlay of venue ads, QR codes, menu tickers, and popups on top of live sports broadcasts without requiring extra hardware video mixers.

---

## 🏗️ System Architecture

```
[ DStv Decoder ] ──(HDMI)──> [ USB 3.0 UVC Capture Card ]
                                        │
                                      (USB)
                                        ▼
                            [ Android TV Box / Player ]
                                        │
                     Runs night_track_tv (Flutter App)
                                        │
┌───────────────────────────────────────┴──────────────────────────────────────┐
│  Flutter Stack Surface Composition                                            │
│  ├── Positioned.fill: HdmiVideoSurface (Native Android Texture - GPU)        │
│  ├── Positioned.bottom: BottomBarOverlayWidget (80px QR / Ticker / Ad Bar)    │
│  └── Center: Dynamic Popups (Goal Alerts, Halftime Menus)                    │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 📂 Proposed Code Directory Structure

```
night_track_tv/lib/feature/tv_display/
├── data/
│   └── hdmi/
│       ├── hdmi_input.dart          # Abstract HDMI Interface (Decoupled Layer)
│       └── uvc_hdmi_input.dart      # UVC Hardware Implementation
├── domain/
│   ├── hdmi_state.dart              # State Machine enum
│   └── tv_mode.dart                 # UI Mode enum
└── presentation/
    ├── widget/
    │   ├── hdmi_video_surface.dart  # Hardware Video Texture Container & Fallback
    │   ├── bottom_bar_overlay_widget.dart
    │   └── tv_layout_factory.dart
```

---

## 🚀 Phased Implementation Roadmap

### Phase 1: Hardware Proof-of-Concept & Acceptance Validation
* **Hardware Target:** USB 3.0 UVC HDMI capture card (1080p50/60fps) + Android TV Box (Android 10+ with USB Host and documented firmware).
* **Acceptance Criteria Checklist:**
  * [ ] **4+ Hours Continuous Video:** Zero crashes, stable frame rate.
  * [ ] **No Memory Leak:** No progressive RAM/GPU memory growth over time.
  * [ ] **Low Latency:** Under 100ms delay between DStv output and TV display.
  * [ ] **USB Unplug/Re-plug:** Auto-resumes video stream seamlessly on re-connection.
  * [ ] **Instant UI Transitions:** Fullscreen ↔ Live stream mode changes happen without HDMI re-initialization.
  * [ ] **Audio Sync:** Audio remains synchronized with video feed.

---

### Phase 2: Abstract HDMI Interface, Platform Channels & State Stream
Define a decoupled abstract layer with explicit lifecycle cleanup, platform channel communication, and state streaming:

#### Platform Channel Architecture:
* **`MethodChannel('com.ayustream.tv/hdmi_control')`**: Sends lifecycle commands (`startCapture`, `stopCapture`, `requestUsbPermission`) and receives the GPU `textureId` from Android Native.
* **`EventChannel('com.ayustream.tv/hdmi_state')`**: Streams real-time `HdmiState` events (`connected`, `noSignal`, `streaming`, `disconnected`) to Flutter.
* **`Texture(textureId: id)`**: Renders zero-copy GPU video frames produced by Android `SurfaceTexture`.

```dart
enum HdmiState {
  initializing,
  disconnected,       // USB Capture Dongle unplugged
  permissionRequired, // Android USB permission prompt needed
  connected,          // Dongle attached to Android
  noSignal,           // Dongle attached but DStv cable turned off/unplugged
  streaming,          // Active video feed rendering
  error,              // Hardware error state
}

abstract class HdmiInput {
  Future<void> initialize();
  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
  
  Widget buildView();
  HdmiState get state;
  Stream<HdmiState> get stateStream;
}
```

---

### Phase 3: Hardware Video Surface & Visual Fallback UI
Create `hdmi_video_surface.dart`:
* **If `state == HdmiState.streaming`:** Render native GPU `Texture` view.
* **Dev / Debug Visual Indicators:**
  * `disconnected`: Display *"HDMI Capture Device Not Connected"* overlay badge.
  * `noSignal`: Display *"Waiting for DStv HDMI Signal"* overlay badge.
  * `error`: Display *"HDMI Input Error"* overlay badge.
* **Production Fallback:** If `disconnected` or `noSignal` persists, automatically transition to `IdleDisplayViewFactory` (animated menu slideshow) so the TV screen never goes black.

---

### Phase 4: `TvLayoutFactory` Integration
Wire `HdmiVideoSurface` into `TvLayoutFactory`:

```dart
switch (mode) {
  case 'bottom_bar':
    return BottomBarOverlayWidget(
      liveContent: const HdmiVideoSurface(),
      settings: settings,
      orgName: orgName,
      qrCodeUrl: qrCodeUrl,
      menuItems: menuItems,
      businessType: businessType,
      tickerNewsText: tickerNewsText,
    );
}
```

---

### Phase 5: Firestore Remote Control & Overlay Popups
Keep the HDMI video stream active in the background (`Positioned.fill`), toggling Flutter UI layers based on Firestore `SettingsModel` (**Never stop/restart the HDMI capture stream on mode changes**):

* **`bottom_bar` (Match Mode):** DStv sports + 80px bottom ad bar.
* **`fullscreen` (Halftime / Break):** Overlay full-screen menu slides over the HDMI feed.
* **`popup` (Goal / Special Promo):** Overlay center 10-second banner (*"Goal Special: 20% Off Beer!"*).

---

### Phase 6: Reliability & Audio Routing
* **USB Handling:** Listen for `USB_ATTACHED` and `USB_DETACHED` Android events to automatically resume stream without app restarts.
* **Audio Routing:**
  * Option A: DStv decoder audio plugged directly into venue's sound amplifier (simplest).
  * Option B: UAC (USB Audio Class) captured via Android audio manager.

---

## 🛒 Hardware Specification Checklist

### Capture Card:
* ✅ USB 3.0 (high bandwidth)
* ✅ UVC (USB Video Class driverless)
* ✅ 1080p50 / 60fps support
* ✅ Android USB Host compatibility
* ❌ *Do not lock to specific chipsets or rely on HDCP bypass features.*

### Android TV Box:
* ✅ Android 10 or higher
* ✅ Physical USB 3.0 Port (Verified in specs)
* ✅ 4GB RAM & USB Host support
* ✅ Ethernet port / 5GHz Wi-Fi
* ✅ Documented Android firmware & stable vendor support
