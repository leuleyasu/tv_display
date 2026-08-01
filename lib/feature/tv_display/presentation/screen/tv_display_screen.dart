import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/music_request.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import '../config/business_tv_config.dart';
import '../cubit/tv_display_cubit.dart';
import '../cubit/tv_display_state.dart';
import '../../domain/models/idle_content.dart';
import '../theme/tv_display_colors.dart';
import '../widget/ambient_orbs.dart';
import '../widget/birthday_overlay/birthday_overlay.dart';
import '../widget/framed_shoutout_content.dart';
import '../widget/idle_display_view_factory.dart';
import '../widget/now_playing_screen.dart';
import '../widget/shoutout_message_qr.dart';
import '../widget/shoutout_progress_strip.dart';
import '../widget/shoutout_top_bar.dart';
import '../widget/signage_ad_overlay.dart';
import '../widget/tv_empty_state.dart';
import '../widget/tv_fullscreen_qr.dart';
import '../widget/world_cup_overlay.dart';

class TvDisplayScreen extends StatefulWidget {
  final String organizationId;
  final String? businessType;

  const TvDisplayScreen({
    super.key,
    required this.organizationId,
    this.businessType,
  });

  @override
  State<TvDisplayScreen> createState() => _TvDisplayScreenState();
}

class _TvDisplayScreenState extends State<TvDisplayScreen>
    with TickerProviderStateMixin {
  late final TvDisplayRepository _repo;
  late final TvDisplayCubit _cubit;

  // ── Animations ──────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim;

  // Message card entry
  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;
  late Animation<double> _frameAnim;
  late Animation<double> _nameAnim;
  late Animation<double> _metaAnim;

  // Idle-specific continuous animations
  late AnimationController _idleBreathCtrl;
  late Animation<double> _idleBreathAnim;
  late AnimationController _idleRadarCtrl;
  late Animation<double> _idleRadarAnim;

  // VIP gold sweep
  late AnimationController _vipSweepCtrl;
  late Animation<double> _vipSweepAnim;

  // Scanning line
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
        vsync: this, duration: const Duration(milliseconds: 700));
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
      // final name = await _showNameDialog();
      // if (name != null && name.trim().isNotEmpty) {
      //   _deviceName = name.trim();
      //   await prefs.setString('device_name', _deviceName);
      // } else {
      _deviceName = 'TV-${_deviceId.substring(0, 6)}';
      await prefs.setString('device_name', _deviceName);
      // }
    }

    _repo.updateHeartbeat(_deviceId, _deviceName);
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        _repo.updateHeartbeat(_deviceId, _deviceName);
      }
    });
  }

  // Future<String?> _showNameDialog() async {
  //   final controller = TextEditingController();
  //   final name = await showDialog<String>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (ctx) => Material(
  //       type: MaterialType.transparency,
  //       child: Center(
  //         child: SingleChildScrollView(
  //           child: Container(
  //             width: 400,
  //             margin: const EdgeInsets.symmetric(horizontal: 24),
  //             padding: const EdgeInsets.all(24),
  //             decoration: BoxDecoration(
  //               color: const Color(0xFF141424),
  //               borderRadius: BorderRadius.circular(16),
  //               border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
  //             ),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   'NAME THIS DISPLAY',
  //                   style: GoogleFonts.spaceGrotesk(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 18,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 TextField(
  //                   controller: controller,
  //                   autofocus: true,
  //                   style: const TextStyle(color: Colors.white),
  //                   decoration: InputDecoration(
  //                     hintText: 'e.g. Main Bar TV, VIP Section',
  //                     hintStyle:
  //                         TextStyle(color: Colors.white.withValues(alpha: 0.3)),
  //                     enabledBorder: OutlineInputBorder(
  //                       borderSide:
  //                           BorderSide(color: Colors.white.withValues(alpha: 0.2)),
  //                     ),
  //                     focusedBorder: const OutlineInputBorder(
  //                       borderSide: BorderSide(color: TvDisplayColors.accentPink),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 24),
  //                 Align(
  //                   alignment: Alignment.centerRight,
  //                   child: TextButton(
  //                     onPressed: () => Navigator.of(ctx).pop(controller.text),
  //                     child: Text(
  //                       'SAVE',
  //                       style: GoogleFonts.spaceGrotesk(
  //                         color: TvDisplayColors.accentPink,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  //   controller.dispose();
  //   return name;
  // }

  List<IdleSuggestion> _getEffectiveSuggestions(TvDisplayState state) {
    final effectiveType =
        widget.businessType ?? state.settings?.businessType ?? 'nightclub';
    final defaultSuggs = BusinessTvConfig.getSuggestions(effectiveType);
    final labels = state.settings?.idleSuggestionLabels;
    if (labels == null || labels.length < defaultSuggs.length) {
      return defaultSuggs;
    }
    return List.generate(defaultSuggs.length, (i) {
      return IdleSuggestion(
        icon: defaultSuggs[i].icon,
        label: labels[i],
      );
    });
  }

  List<IdleSlide> _getEffectiveSlides(TvDisplayState state) {
    final effectiveType =
        widget.businessType ?? state.settings?.businessType ?? 'nightclub';
    final defaultSlides = BusinessTvConfig.getSlides(effectiveType);
    final scenes = state.settings?.idleScenes;
    if (scenes == null || scenes.isEmpty) return defaultSlides;

    final suggs = _getEffectiveSuggestions(state);
    final maxIdx = suggs.length - 1;
    return scenes.map((s) {
      return IdleSlide(
        emoji: s.emoji,
        headline: s.headline,
        subtitle: s.subtitle,
        suggestionIndex: s.suggestionIndex.clamp(0, maxIdx < 0 ? 0 : maxIdx),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TvDisplayCubit, TvDisplayState>(
      bloc: _cubit,
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
        if (state.showMusicPhase)
          return _buildNowPlayingScreen(state.nowPlaying);
        if (state.showBirthdayPhase) return _buildBirthdayOverlay(state);
        if (state.showBirthdayWishesPhase)
          return _buildBirthdayWishOverlay(state);
        if (state.showCampaignAdPhase) return _buildCampaignAdScreen(state);

        final effectiveType =
            widget.businessType ?? state.settings?.businessType ?? 'nightclub';

        if (state.isIdleMode) {
          return IdleDisplayViewFactory(
            effectiveBusinessType: effectiveType,
            effectiveSlides: _getEffectiveSlides(state),
            effectiveSuggestions: _getEffectiveSuggestions(state),
            idleSlideIndex: state.idleSlideIndex,
            settings: state.settings,
            orgName: state.orgName,
            now: _now,
            qrCodeUrl: state.qrCodeUrl,
            energyLevel: _energyLevel,
            isWorldCupEnabled: state.isWorldCupEnabled,
            fadeAnim: _fadeAnim,
            idleBreathAnim: _idleBreathAnim,
            orbAnim: _orbAnim,
            idleRadarAnim: _idleRadarAnim,
          );
        }

        if (state.showQrPhase) {
          return TvFullscreenQr(
            effectiveBusinessType: effectiveType,
            orgName: state.orgName,
            now: _now,
            qrCodeUrl: state.qrCodeUrl,
            settings: state.settings,
            isWorldCupEnabled: state.isWorldCupEnabled,
            orbAnim: _orbAnim,
          );
        }

        if (state.messages.isEmpty ||
            state.currentIndex >= state.messages.length) {
          return const TvEmptyState();
        }

        final msg = state.messages[state.currentIndex];
        final isVip = msg.isVip;
        final bool hasQr =
            state.qrCodeUrl != null && state.qrCodeUrl!.isNotEmpty;

        return Scaffold(
          backgroundColor: TvDisplayColors.backgroundDeep,
          body: LayoutBuilder(
            builder: (ctx, box) {
              final double scale =
                  min(box.maxWidth / 1920, box.maxHeight / 1080);
              return Stack(
                children: [
                  AmbientOrbs(
                    isVip: isVip,
                    box: box,
                    businessType: effectiveType,
                    orbAnim: _orbAnim,
                  ),
                  ShoutoutProgressStrip(
                    isVip: isVip,
                    progressValue: state.progressValue,
                    businessType: effectiveType,
                  ),
                  ShoutoutTopBar(
                    scale: scale,
                    businessType: effectiveType,
                    orgName: state.orgName,
                    now: _now,
                    orbAnim: _orbAnim,
                  ),
                  if (state.isWorldCupEnabled) WorldCupOverlay(scale: scale),
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: hasQr
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: box.maxWidth * 0.06),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ShoutoutMessageQr(
                                    qrCodeUrl: state.qrCodeUrl,
                                    scale: scale,
                                    customQrSize: state.settings?.qrCodeSize,
                                  ),
                                  SizedBox(width: box.maxWidth * 0.05),
                                  Flexible(
                                    child: FramedShoutoutContent(
                                      msg: msg,
                                      isVip: isVip,
                                      box: box,
                                      scale: scale,
                                      settings: state.settings,
                                      currentIndex: state.currentIndex,
                                      totalMessages: state.messages.length,
                                      entryCtrl: _entryCtrl,
                                      entryAnim: _entryAnim,
                                      frameAnim: _frameAnim,
                                      scanAnim: _scanAnim,
                                      vipSweepAnim: _vipSweepAnim,
                                      nameAnim: _nameAnim,
                                      orbAnim: _orbAnim,
                                      metaAnim: _metaAnim,
                                      noPadding: true,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : FramedShoutoutContent(
                              msg: msg,
                              isVip: isVip,
                              box: box,
                              scale: scale,
                              settings: state.settings,
                              currentIndex: state.currentIndex,
                              totalMessages: state.messages.length,
                              entryCtrl: _entryCtrl,
                              entryAnim: _entryAnim,
                              frameAnim: _frameAnim,
                              scanAnim: _scanAnim,
                              vipSweepAnim: _vipSweepAnim,
                              nameAnim: _nameAnim,
                              orbAnim: _orbAnim,
                              metaAnim: _metaAnim,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildDots(
                        state.messages.length,
                        state.currentIndex,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCampaignAdScreen(TvDisplayState state) {
    if (state.approvedCampaigns.isEmpty) return const SizedBox.shrink();
    final campaign = state.approvedCampaigns[
        state.currentCampaignIndex % state.approvedCampaigns.length];
    final effectiveType =
        widget.businessType ?? state.settings?.businessType ?? 'nightclub';

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
                businessType: effectiveType,
                orbAnim: _orbAnim,
              ),
              Center(
                child: SignageAdOverlay(
                  campaign: campaign,
                  scale: scale,
                  progressValue: state.progressValue,
                  venueName: state.orgName,
                  businessType: effectiveType,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBirthdayOverlay(TvDisplayState state) {
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return BirthdayOverlay(
            imageUrl: state.birthdayImageUrls.isNotEmpty
                ? state.birthdayImageUrls.first
                : null,
            name: state.birthdayName,
            wish: state.birthdayWish,
            scale: scale,
            layout: BirthdayLayout.auto,
            accentColor: const Color(0xFFFBBF24),
            isAsset: false,
          );
        },
      ),
    );
  }

  Widget _buildBirthdayWishOverlay(TvDisplayState state) {
    if (state.birthdayWishes.isEmpty) return const SizedBox.shrink();
    final wish = state.birthdayWishes[state.birthdayWishIndex];
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final isAnonymous = wish['isAnonymous'] == true;
          final name = isAnonymous
              ? 'Anonymous'
              : (wish['userName'] as String? ?? 'Someone');
          final content = wish['content'] as String? ?? '';
          final toName = wish['toName'] as String? ?? state.birthdayName;
          return BirthdayOverlay(
            imageUrl: state.birthdayImageUrls.isNotEmpty
                ? state.birthdayImageUrls.first
                : null,
            name: toName,
            wish: '$name says: $content',
            scale: scale,
            layout: BirthdayLayout.auto,
            accentColor: const Color(0xFFFBBF24),
            isAsset: false,
          );
        },
      ),
    );
  }

  Widget _buildNowPlayingScreen(MusicRequest? req) {
    if (req == null) return const SizedBox.shrink();
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return NowPlayingScreen(request: req, scale: scale);
        },
      ),
    );
  }

  Widget _buildDots(int totalCount, int currentIndex) {
    final int total = min(totalCount, 20);
    final double step = totalCount > total ? totalCount / total : 1.0;
    final int active = (currentIndex / step).round();
    final int count = (totalCount / step).ceil().clamp(0, total);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final bool isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 4,
          decoration: BoxDecoration(
            color: isActive
                ? TvDisplayColors.accentPink
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(0),
          ),
        );
      }),
    );
  }
}
