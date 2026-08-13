import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/tv_display_colors.dart';

/// QR code card widget displayed on the side during shoutouts.
class ShoutoutMessageQr extends StatelessWidget {
  final String? qrCodeUrl;
  final double scale;
  final double? customQrSize;

  const ShoutoutMessageQr({
    super.key,
    required this.qrCodeUrl,
    required this.scale,
    this.customQrSize,
  });

  @override
  Widget build(BuildContext context) {
    if (qrCodeUrl == null || qrCodeUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    final double size = (customQrSize ?? 280) * scale;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TvDisplayColors.accentPink.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 1,
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
    );
  }
}
