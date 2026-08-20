import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import '../../theme/tv_display_colors.dart';
import '../widget/match_mode/l_bar_match_layout.dart';

/// Top-level display screen for Match Mode (Live Sports & DOOH Ad Overlay).
class MatchModeDisplayScreen extends StatefulWidget {
  final String organizationId;

  const MatchModeDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  State<MatchModeDisplayScreen> createState() => _MatchModeDisplayScreenState();
}

class _MatchModeDisplayScreenState extends State<MatchModeDisplayScreen>
    with SingleTickerProviderStateMixin {
  late final TvDisplayRepository _repository;

  List<Map<String, dynamic>> _campaigns = [];
  int _currentCampaignIndex = 0;
  Timer? _campaignCycleTimer;
  Timer? _progressTicker;
  double _adProgress = 0.0;
  static const int _adDurationSec = 12;

  @override
  void initState() {
    super.initState();
    _repository = TvDisplayRepository(organizationId: widget.organizationId);
    _startCampaignRotation();
  }

  void _startCampaignRotation() {
    _progressTicker?.cancel();
    _campaignCycleTimer?.cancel();

    _adProgress = 0.0;
    _progressTicker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _adProgress += 0.1 / _adDurationSec;
          if (_adProgress >= 1.0) {
            _adProgress = 0.0;
            if (_campaigns.isNotEmpty) {
              _currentCampaignIndex = (_currentCampaignIndex + 1) % _campaigns.length;
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _progressTicker?.cancel();
    _campaignCycleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SettingsModel>(
      stream: _repository.settingsStream(),
      builder: (context, settingsSnapshot) {
        if (settingsSnapshot.connectionState == ConnectionState.waiting &&
            !settingsSnapshot.hasData) {
          return _buildLoadingScreen();
        }

        final settings = settingsSnapshot.data ??
            SettingsModel(
              organizationId: widget.organizationId,
              businessType: 'match',
              isMatchMode: true,
            );

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _repository.campaignsStream(),
          builder: (context, campaignSnapshot) {
            if (campaignSnapshot.hasData && campaignSnapshot.data != null) {
              _campaigns = campaignSnapshot.data!;
            }

            final activeCampaign = _campaigns.isNotEmpty
                ? _campaigns[_currentCampaignIndex % _campaigns.length]
                : null;

            final qrUrl = settings.qrCodeUrl ??
                'https://lakipay.app/match?org=${widget.organizationId}';

            return Scaffold(
              backgroundColor: const Color(0xFF070712),
              body: LBarMatchLayout(
                settings: settings,
                currentCampaign: activeCampaign,
                adProgress: _adProgress,
                qrData: qrUrl,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF070712),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.discreteCircle(
              color: TvDisplayColors.accentPink,
              secondRingColor: TvDisplayColors.accentPurple,
              thirdRingColor: TvDisplayColors.accentCyan,
              size: 64,
            ),
            const SizedBox(height: 24),
            const Text(
              'INITIALIZING MATCH MODE DISPLAY...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
