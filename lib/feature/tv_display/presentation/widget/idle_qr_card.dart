import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/config/business_type_tv_theme.dart';

/// Animated radar pulse QR card widget displayed on the idle screen.
class IdleQrCard extends StatelessWidget {
  final String? qrCodeUrl;
  final double scale;
  final BusinessTypeTvTheme tvTheme;
  final double? customQrSize;
  final Animation<double> radarAnim;

  const IdleQrCard({
    super.key,
    required this.qrCodeUrl,
    required this.scale,
    required this.tvTheme,
    required this.radarAnim,
    this.customQrSize,
  });

  @override
  Widget build(BuildContext context) {
    if (qrCodeUrl == null || qrCodeUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    final double baseQr = customQrSize ?? 180.0;
    final double size = baseQr * scale;
    final accent = tvTheme.primaryAccent;

    return AnimatedBuilder(
      animation: radarAnim,
      builder: (context, _) {
        return SizedBox(
          width: size + 80,
          height: size + 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (i) {
                final double t = (radarAnim.value + i / 3) % 1.0;
                return Container(
                  width: size + t * 80,
                  height: size + t * 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha: (1 - t) * 0.35),
                      width: 2,
                    ),
                  ),
                );
              }),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: QrImageView(
                  data: qrCodeUrl!,
                  size: size,
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
            ],
          ),
        );
      },
    );
  }
}
