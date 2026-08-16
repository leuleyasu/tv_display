import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/music_request.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import '../cubit/tv_display_cubit.dart';
import '../cubit/tv_display_state.dart';
import '../theme/tv_display_colors.dart';
import 'birthday_overlay/birthday_overlay.dart';
import 'now_playing_screen.dart';
import 'tv_empty_state.dart';
import 'tv_fullscreen_qr.dart';
import 'signage_ad_overlay.dart';

/// Context containing system animation controllers, timing values, and device identity
/// provided by [TvBaseShell] to business-specific display screens.
class TvShellContext {
  final DateTime now;
  final double energyLevel;
  final String deviceId;
  final String deviceName;
  final Animation<double> fadeAnim;
  final Animation<double> orbAnim;
  final AnimationController entryCtrl;
  final Animation<double> entryAnim;
  final Animation<double> frameAnim;
  final Animation<double> nameAnim;
  final Animation<double> metaAnim;
  final Animation<double> idleBreathAnim;
  final Animation<double> idleRadarAnim;
  final Animation<double> vipSweepAnim;
  final Animation<double> scanAnim;

  const TvShellContext({
    required this.now,
    required this.energyLevel,
    required this.deviceId,
    required this.deviceName,
    required this.fadeAnim,
    required this.orbAnim,
    required this.entryCtrl,
    required this.entryAnim,
    required this.frameAnim,
    required this.nameAnim,
    required this.metaAnim,
    required this.idleBreathAnim,
    required this.idleRadarAnim,
    required this.vipSweepAnim,
    required this.scanAnim,
  });
}

typedef TvBusinessContentBuilder = Widget Function(
  BuildContext context,
  TvDisplayState state,
  TvShellContext shellContext,
);

/// Foundational Shell for TV Display application.
/// Handles repository initialization, Cubit lifecycle, device registration & heartbeat,
/// global animation controllers, and system overlay priority rendering (Loading, Disabled,
/// Birthday, Music, Fullscreen QR).
class TvBaseShell extends StatefulWidget {
  final String organizationId;
  final String businessType;
  final TvBusinessContentBuilder builder;

  const TvBaseShell({
    super.key,
    required this.organizationId,
    required this.businessType,
    required this.builder,
  });

  @override
  State<TvBaseShell> createState() => _TvBaseShellState();
}

class _TvBaseShellState extends State<TvBaseShell>
    with TickerProviderStateMixin {
  late final TvDisplayRepository _repo;
  late final TvDisplayCubit _cubit;

  // System Animations
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim;

  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;
  late Animation<double> _frameAnim;
  late Animation<double> _nameAnim;
  late Animation<double> _metaAnim;

  late AnimationController _idleBreathCtrl;
  late Animation<double> _idleBreathAnim;
  late AnimationController _idleRadarCtrl;
  late Animation<double> _idleRadarAnim;

  late AnimationController _vipSweepCtrl;
  late Animation<double> _vipSweepAnim;
  late AnimationController _scanCtrl;
  late Animation<double> _scanAnim;

  // Timers & State
  Timer? _clockTimer;
  Timer? _idleEnergyTimer;
  Timer? _heartbeatTimer;

  String _deviceId = '';
  String _deviceName = '';
  double _energyLevel = 0.7;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _repo = TvDisplayRepository(organizationId: widget.organizationId);
    _cubit = TvDisplayCubit(repository: _repo)..initStreams();

    _fadeCtrl = AnimationController(
        vsync: this, value: 1.0, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);

    _orbCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _entryAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _frameAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _nameAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
    );
    _metaAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _idleBreathCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat(reverse: true);
    _idleBreathAnim =
        CurvedAnimation(parent: _idleBreathCtrl, curve: Curves.easeInOut);

    _idleRadarCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _idleRadarAnim =
        CurvedAnimation(parent: _idleRadarCtrl, curve: Curves.linear);

    _vipSweepCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _vipSweepAnim =
        CurvedAnimation(parent: _vipSweepCtrl, curve: Curves.linear);

    _scanCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.linear);

    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _idleEnergyTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!mounted) return;
      setState(() => _energyLevel = 0.55 + Random().nextDouble() * 0.45);
    });

    _initDeviceIdentity();
  }

  @override
  void dispose() {
    _cubit.close();
    _fadeCtrl.dispose();
    _orbCtrl.dispose();
    _entryCtrl.dispose();
    _idleBreathCtrl.dispose();
    _idleRadarCtrl.dispose();
    _vipSweepCtrl.dispose();
    _scanCtrl.dispose();

    _clockTimer?.cancel();
    _idleEnergyTimer?.cancel();
    _heartbeatTimer?.cancel();
    _repo.markDeviceOffline(_deviceId);

    super.dispose();
  }

  Future<void> _initDeviceIdentity() async {
    final prefs = await SharedPreferences.getInstance();

    _deviceId = prefs.getString('device_id') ?? '';
    if (_deviceId.isEmpty) {
      _deviceId =
          '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999999)}';
      await prefs.setString('device_id', _deviceId);
    }

    _deviceName = prefs.getString('device_name') ?? '';
    if (_deviceName.isEmpty) {
      _deviceName = 'TV-${_deviceId.substring(0, 6)}';
      await prefs.setString('device_name', _deviceName);
    }

    _repo.updateHeartbeat(_deviceId, _deviceName);
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _repo.updateHeartbeat(_deviceId, _deviceName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TvDisplayCubit, TvDisplayState>(
      bloc: _cubit,
      listenWhen: (prev, curr) => prev.idleSlideIndex != curr.idleSlideIndex,
      listener: (context, state) {
        _fadeCtrl.forward(from: 0.0);
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            backgroundColor: TvDisplayColors.backgroundDeep,
            body: Center(
              child:
                  CircularProgressIndicator(color: TvDisplayColors.accentPink),
            ),
          );
        }

        if (state.settings?.isEnabled == false) return const TvEmptyState();

        if (state.showCampaignAdPhase && state.approvedCampaigns.isNotEmpty) {
          final campaign = state.approvedCampaigns[
              state.currentCampaignIndex % state.approvedCampaigns.length];

          return Scaffold(
            backgroundColor: TvDisplayColors.backgroundDeep,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final scale = (constraints.maxWidth / 1920).clamp(0.4, 1.4);
                return Center(
                  child: SignageAdOverlay(
                    campaign: campaign,
                    scale: scale,
                    progressValue: state.progressValue,
                    venueName: state.orgName,
                    businessType: widget.businessType,
                  ),
                );
              },
            ),
          );
        }

        if (state.showQrPhase) {
          return TvFullscreenQr(
            effectiveBusinessType: widget.businessType,
            orgName: state.orgName,
            now: _now,
            qrCodeUrl: state.qrCodeUrl,
            settings: state.settings,
            isWorldCupEnabled: state.isWorldCupEnabled,
            orbAnim: _orbAnim,
          );
        }

        final shellContext = TvShellContext(
          now: _now,
          energyLevel: _energyLevel,
          deviceId: _deviceId,
          deviceName: _deviceName,
          fadeAnim: _fadeAnim,
          orbAnim: _orbAnim,
          entryCtrl: _entryCtrl,
          entryAnim: _entryAnim,
          frameAnim: _frameAnim,
          nameAnim: _nameAnim,
          metaAnim: _metaAnim,
          idleBreathAnim: _idleBreathAnim,
          idleRadarAnim: _idleRadarAnim,
          vipSweepAnim: _vipSweepAnim,
          scanAnim: _scanAnim,
        );

        return widget.builder(context, state, shellContext);
      },
    );
  }
}
