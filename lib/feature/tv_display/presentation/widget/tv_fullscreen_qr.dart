import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/models/settings_model.dart';
import '../theme/tv_display_colors.dart';
import 'ambient_orbs.dart';
import 'shoutout_top_bar.dart';
import 'world_cup_overlay.dart';

/// Fullscreen QR Code view for TV Signage.
class TvFullscreenQr extends StatelessWidget {
  final String effectiveBusinessType;
  final String orgName;
  final DateTime now;
  final String? qrCodeUrl;
  final SettingsModel? settings;
  final bool isWorldCupEnabled;
  final Animation<double> orbAnim;

  const TvFullscreenQr({
    super.key,
    required this.effectiveBusinessType,
    required this.orgName,
    required this.now,
    required this.qrCodeUrl,
    required this.settings,
    required this.isWorldCupEnabled,
    required this.orbAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return Stack(
            children: [
              AmbientOrbs(
                isVip: false,
                box: box,
                businessType: effectiveBusinessType,
                orbAnim: orbAnim,
              ),
              ShoutoutTopBar(
                scale: scale,
                businessType: effectiveBusinessType,
                orgName: orgName,
                now: now,
                orbAnim: orbAnim,
              ),
              if (isWorldCupEnabled) WorldCupOverlay(scale: scale),
              Center(
                child: qrCodeUrl == null || qrCodeUrl!.isEmpty
                    ? const SizedBox.shrink()
                    : QrImageView(
                        data: qrCodeUrl!,
                        size: (settings?.qrCodeSize ?? 500) * scale,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
              ),
              Positioned(
                bottom: 40 * scale,
                left: 0,
                right: 0,
                child: Text(
                  'SCAN TO JOIN',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 25 * scale,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 8,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
