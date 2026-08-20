import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import '../../theme/tv_display_colors.dart';

/// Renders the 20-25% Right Sidebar for Match Mode.
/// Contains rotating DOOH brand advertisements, match sponsors,
/// and the persistent LakiPay QR Code for patron mobile checkout.
class MatchAdSidebar extends StatelessWidget {
  final SettingsModel settings;
  final Map<String, dynamic>? currentCampaign;
  final double adProgress;
  final double scale;
  final String qrData;

  const MatchAdSidebar({
    super.key,
    required this.settings,
    required this.currentCampaign,
    required this.adProgress,
    required this.scale,
    required this.qrData,
  });

  @override
  Widget build(BuildContext context) {
    final s = scale;
    final venueName = settings.organizationName ?? settings.houseName ?? 'Match Zone';
    final adTitle = (currentCampaign?['title'] as String?) ?? 'Official Match Sponsor';
    final adCaption = (currentCampaign?['caption'] as String?) ?? 'Special Match Day Offer';
    final mediaUrl = (currentCampaign?['mediaUrl'] as String?) ?? '';

    return Container(
      decoration: BoxDecoration(
        color: TvDisplayColors.cardSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
          color: TvDisplayColors.accentPink.withValues(alpha: 0.3),
          width: 2 * s,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 20 * s,
            offset: Offset(0, 8 * s),
          ),
          BoxShadow(
            color: TvDisplayColors.accentPink.withValues(alpha: 0.1),
            blurRadius: 24 * s,
          ),
        ],
      ),
      padding: EdgeInsets.all(16 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Venue Brand Header ────────────────────────────────
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6 * s),
                decoration: BoxDecoration(
                  color: TvDisplayColors.accentPink.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: TvDisplayColors.accentPink.withValues(alpha: 0.4)),
                ),
                child: Icon(Icons.storefront_rounded, color: TvDisplayColors.accentPink, size: 16 * s),
              ),
              SizedBox(width: 8 * s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venueName.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13 * s,
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'MATCH DAY ARENA',
                      style: TextStyle(
                        color: TvDisplayColors.accentGold,
                        fontSize: 10 * s,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12 * s),
          Divider(color: Colors.white12, height: 1 * s),
          SizedBox(height: 12 * s),

          // ── 2. DOOH Rotating Ad Card ──────────────────────────────
          Expanded(
            flex: 55,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11 * s),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ad Creative Image / Placeholder
                    if (mediaUrl.isNotEmpty)
                      Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildAdPlaceholder(s, adTitle, adCaption),
                      )
                    else
                      _buildAdPlaceholder(s, adTitle, adCaption),

                    // Top Sponsored Tag
                    Positioned(
                      top: 8 * s,
                      right: 8 * s,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 3 * s),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6 * s),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, color: TvDisplayColors.accentGold, size: 10 * s),
                            SizedBox(width: 4 * s),
                            Text(
                              'SPONSORED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9 * s,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Ad Countdown Progress Bar
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(
                        value: adProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.black45,
                        valueColor: const AlwaysStoppedAnimation<Color>(TvDisplayColors.accentPink),
                        minHeight: 4 * s,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 12 * s),

          // ── 3. Persistent LakiPay QR Code Card ───────────────────
          Expanded(
            flex: 45,
            child: Container(
              padding: EdgeInsets.all(10 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF14132B), Color(0xFF0F0E22)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(12 * s),
                border: Border.all(
                  color: TvDisplayColors.accentCyan.withValues(alpha: 0.4),
                  width: 1.5 * s,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // QR Container with clean white padding
                  if (qrData.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(6 * s),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10 * s),
                        boxShadow: [
                          BoxShadow(
                            color: TvDisplayColors.accentCyan.withValues(alpha: 0.25),
                            blurRadius: 12 * s,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 88 * s,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF070712),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF070712),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 88 * s,
                      height: 88 * s,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12 * s),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          color: TvDisplayColors.accentCyan.withValues(alpha: 0.6),
                          size: 48 * s,
                        ),
                      ),
                    ),

                  SizedBox(height: 8 * s),

                  // Action Prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded, color: TvDisplayColors.accentCyan, size: 14 * s),
                      SizedBox(width: 6 * s),
                      Text(
                        'SCAN & ORDER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2 * s),
                  Text(
                    'Pay Food, Drinks & Tip DJ',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 10 * s,
                      fontWeight: FontWeight.w500,
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

  Widget _buildAdPlaceholder(double s, String title, String caption) {
    return Container(
      padding: EdgeInsets.all(12 * s),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TvDisplayColors.accentPurple.withValues(alpha: 0.35),
            TvDisplayColors.accentPink.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_rounded, size: 36 * s, color: TvDisplayColors.accentGold),
            SizedBox(height: 8 * s),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13 * s,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (caption.isNotEmpty) ...[
              SizedBox(height: 4 * s),
              Text(
                caption,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10 * s,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
