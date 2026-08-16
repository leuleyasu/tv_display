import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/models/music_request.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import '../config/business_configs/restaurant_config.dart';
import '../config/business_tv_config.dart';
import '../cubit/tv_display_cubit.dart';
import '../cubit/tv_display_state.dart';
import '../../domain/models/idle_content.dart';
import '../theme/tv_display_colors.dart';
import '../widget/ambient_orbs.dart';
import '../widget/framed_shoutout_content.dart';
import '../widget/idle_display_view_factory.dart';
import '../widget/shoutout_message_qr.dart';
import '../widget/shoutout_progress_strip.dart';
import '../widget/tv_birthday_display_view.dart';
import '../widget/tv_empty_state.dart';
import '../widget/tv_fullscreen_qr.dart';
import '../widget/tv_layout_factory.dart';
import '../widget/tv_now_playing_view.dart';
import '../widget/tv_pagination_dots.dart';
import '../widget/signage_ad_overlay.dart';
import '../widget/tv_top_header_bar.dart';

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

  List<IdleSuggestion> _getEffectiveSuggestions(TvDisplayState state) {
    if (state.menuItems.isNotEmpty) {
      final categories = state.menuItems
          .map((item) {
            final catField = item['category'] ?? item['category '];
            if (catField is List && catField.isNotEmpty) {
              return catField.first.toString().trim();
            } else if (catField is Map) {
              return (catField['name'] ?? catField['title'] ?? '')
                  .toString()
                  .trim();
            } else if (catField is String) {
              return catField.trim();
            }
            return null;
          })
          .where((cat) => cat != null && cat.isNotEmpty)
          .toSet()
          .cast<String>()
          .toList();

      if (categories.isNotEmpty) {
        return categories.take(4).map((cat) {
          final catLower = cat.toLowerCase();
          IconData icon = Icons.restaurant_menu_rounded;
          if (catLower.contains('drink') ||
              catLower.contains('beverage') ||
              catLower.contains('cocktail') ||
              catLower.contains('wine')) {
            icon = Icons.local_bar_rounded;
          } else if (catLower.contains('dessert') ||
              catLower.contains('sweet')) {
            icon = Icons.icecream_rounded;
          } else if (catLower.contains('starter') ||
              catLower.contains('appetizer')) {
            icon = Icons.tapas_rounded;
          } else if (catLower.contains('special') ||
              catLower.contains('chef')) {
            icon = Icons.star_rounded;
          }
          return IdleSuggestion(
            icon: icon,
            label: cat.toUpperCase(),
          );
        }).toList();
      }
    }

    final effectiveType =
        widget.businessType ?? state.settings?.businessType ?? 'restaurant';
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
    if (state.menuItems.isNotEmpty) {
      final suggs = _getEffectiveSuggestions(state);
      final maxIdx = suggs.length - 1;
      return state.menuItems.asMap().entries.map((entry) {
        final idx = entry.key;
        final item = entry.value;
        final catField = item['category'] ?? item['category '];
        String? rawCatStr;
        if (catField is List && catField.isNotEmpty) {
          rawCatStr = catField.first.toString().trim();
        } else if (catField is Map) {
          rawCatStr =
              (catField['name'] ?? catField['title'] ?? '').toString().trim();
        } else if (catField is String) {
          rawCatStr = catField.trim();
        }
        final rawCat =
            (rawCatStr != null && rawCatStr.isNotEmpty) ? rawCatStr : 'MENU';
        debugPrint(
            'DEBUG MENU ITEM: name=${item['name']} | catField=$catField | final rawCat=$rawCat');
        if (item['name'] == 'Some' || item['name'] == 'SOME') {
          debugPrint('DEBUG FULL DOC FOR "Some": $item');
        }
        final categoryLower = rawCat.toLowerCase();
        String emoji = '🍽️';
        if (categoryLower.contains('drink') ||
            categoryLower.contains('beverage')) {
          emoji = '🍹';
        } else if (categoryLower.contains('alcohol') ||
            categoryLower.contains('wine') ||
            categoryLower.contains('cocktail')) {
          emoji = '🍷';
        } else if (categoryLower.contains('special') ||
            categoryLower.contains('combo')) {
          emoji = '⭐';
        }
        final priceRaw = item['price'];
        final priceNum = (priceRaw as num?)?.toDouble();
        final currencyStr = (item['currency'] as String?) ?? 'ETB';
        final name = (item['name'] as String? ?? '').toUpperCase();
        final desc = item['description'] as String? ?? '';
        final imageUrl = item['imageUrl'] as String?;

        return IdleSlide(
          emoji: emoji,
          headline: name,
          subtitle: desc,
          suggestionIndex: idx % (maxIdx < 0 ? 1 : maxIdx + 1),
          imageUrl: imageUrl,
          price: priceNum,
          currency: currencyStr,
          category: rawCat,
        );
      }).toList();
    }

    final scenes = state.settings?.idleScenes;
    if (scenes != null && scenes.isNotEmpty) {
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

    // Fallback when no menu items or custom scenes exist
    return RestaurantTvConfig.defaultSlides;
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
        if (state.showMusicPhase) {
          return TvNowPlayingView(request: state.nowPlaying);
        }
        if (state.showBirthdayPhase) {
          return TvBirthdayDisplayView(state: state);
        }
        if (state.showCampaignAdPhase) return _buildCampaignAdScreen(state);

        final effectiveType =
            widget.businessType ?? state.settings?.businessType ?? 'restaurant';

        final templateId = state.settings?.tvLayoutTemplate ?? 'bottom_bar';
        final tickerNewsText = state.settings?.tickerNewsText ?? '';

        if (state.isIdleMode) {
          final defaultView = IdleDisplayViewFactory(
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

          return TvLayoutFactory(
            templateId: templateId,
            defaultView: defaultView,
            settings: state.settings,
            orgName: state.orgName,
            qrCodeUrl: state.qrCodeUrl,
            menuItems: state.menuItems,
            businessType: effectiveType,
            tickerNewsText: tickerNewsText,
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
                  TvTopHeaderBar(
                    scale: scale,
                    businessType: effectiveType,
                    orgName: state.orgName,
                    now: _now,
                    orbAnim: _orbAnim,
                  ),
                  // if (state.isWorldCupEnabled) WorldCupOverlay(scale: scale),
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
                      child: TvPaginationDots(
                        totalCount: state.messages.length,
                        currentIndex: state.currentIndex,
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
              businessType: widget.businessType ?? state.settings?.businessType,
            ),
          );
        },
      ),
    );
  }
}
