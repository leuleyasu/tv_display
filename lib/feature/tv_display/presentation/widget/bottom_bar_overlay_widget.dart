import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';

/// Primary Overlay Mode: Bottom Bar Overlay (Height: 80px)
/// Runs persistently along the bottom of the venue's live TV / match broadcast.
/// Features: Left QR Dock, Center Animated Menu/News Ticker, Right DOOH Ad Badge.
class BottomBarOverlayWidget extends StatefulWidget {
  final Widget liveContent;
  final SettingsModel? settings;
  final String orgName;
  final String? qrCodeUrl;
  final List<Map<String, dynamic>> menuItems;
  final String businessType;
  final String tickerNewsText;

  const BottomBarOverlayWidget({
    super.key,
    required this.liveContent,
    this.settings,
    required this.orgName,
    this.qrCodeUrl,
    required this.menuItems,
    this.businessType = 'restaurant',
    this.tickerNewsText = '',
  });

  @override
  State<BottomBarOverlayWidget> createState() => _BottomBarOverlayWidgetState();
}

class _BottomBarOverlayWidgetState extends State<BottomBarOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tickerController;

  @override
  void initState() {
    super.initState();
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of(widget.businessType);
    final accent = tvTheme.primaryAccent;

    // Construct ticker text from menu items & custom venue news
    final String menuString = widget.menuItems.isNotEmpty
        ? widget.menuItems.map((item) {
            final name = (item['name'] as String? ?? '').toUpperCase();
            final price = item['price'];
            final currency = item['currency'] ?? 'ETB';
            final priceStr = price != null ? ' — $price $currency' : '';
            return '⭐ $name$priceStr';
          }).join('    •    ')
        : '🍽️ WELCOME TO ${(widget.orgName.isNotEmpty ? widget.orgName : "OUR VENUE").toUpperCase()}    •    SCAN QR CODE TO VIEW DIGITAL MENU';

    final String fullTickerText = widget.tickerNewsText.isNotEmpty
        ? '📢 ${widget.tickerNewsText.toUpperCase()}    •    $menuString'
        : menuString;

    final String finalQrUrl = widget.qrCodeUrl ??
        'https://ayustream.app/menu?org=${widget.settings?.organizationId ?? "venue"}';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Live Media Screen Area (Full screen background)
          Positioned.fill(
            child: widget.liveContent,
          ),

          // Bottom AyuStream Overlay Bar (Height: 80px)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: accent.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left Zone: Mini QR Code Dock (65x65)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: QrImageView(
                            data: finalQrUrl,
                            version: QrVersions.auto,
                            size: 58.0,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SCAN MENU',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'ON PHONE',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),

                  // Center Zone: Scrolling Menu & News Ticker
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRect(
                        child: AnimatedBuilder(
                          animation: _tickerController,
                          builder: (context, child) {
                            return FractionalTranslation(
                              translation: Offset(
                                  1.0 - (_tickerController.value * 2.0), 0.0),
                              child: Text(
                                '$fullTickerText        •        $fullTickerText',
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Right Zone: Sponsored DOOH Brand Ad Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent,
                          accent.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: Colors.black, size: 20),
                        const SizedBox(width: 6),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.orgName.isNotEmpty
                                  ? widget.orgName.toUpperCase()
                                  : 'AYUSTREAM',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Text(
                              'SPONSORED AD',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppColors {
  static const primary = Color(0xFF6156E2);
}
