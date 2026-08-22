import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import '../../../../core/repositories/tv_display_repository.dart';
import '../../../../core/models/shoutout_request.dart';
import '../../utils/tv_display_utils.dart';
import 'tv_display_state.dart';

class TvDisplayCubit extends Cubit<TvDisplayState> {
  final TvDisplayRepository _repository;
  final List<StreamSubscription> _subscriptions = [];

  Timer? _advanceTimer;
  Timer? _progressTimer;
  Timer? _idleTimer;
  Timer? _musicTimer;

  TvDisplayCubit({required TvDisplayRepository repository})
      : _repository = repository,
        super(const TvDisplayState());

  void initStreams() {
    emit(state.copyWith(isLoading: true));

    _listen(_repository.organizationNameStream(), (name) {
      emit(state.copyWith(orgName: name));
    });

    _listen(_repository.settingsStream(), (settings) {
      emit(state.copyWith(
        settings: settings,
        qrCodeUrl: state.qrCodeUrl ?? settings.qrCodeUrl,
      ));
      if (!state.isIdleMode) restartCurrentMessage();
    });

    _listen(
      _repository.adsStream(expireHours: state.settings?.expireHours ?? 24),
      (messages) {
        final bType = state.settings?.businessType ?? 'nightclub';
        final theme = BusinessTypeTvTheme.of(bType);
        final isShoutoutSupported = theme.supportsShoutouts &&
            (state.settings?.isShoutoutEnabled ?? true);
        final isSuppressed = !isShoutoutSupported;

        final hasRealMessages = !isSuppressed &&
            messages.isNotEmpty &&
            !messages.any((m) => m.id.startsWith('sample_'));
        final isIdle = !hasRealMessages;
        
        List<ShoutoutRequest> updatedMessages = isSuppressed || messages.isEmpty ? [] : messages;
        int newIndex = state.currentIndex;

        if (!isIdle && newIndex >= updatedMessages.length) {
          newIndex = 0;
        }

        emit(state.copyWith(
          messages: updatedMessages,
          isIdleMode: isIdle,
          currentIndex: newIndex,
        ));

        if (isIdle) {
          startIdleMode();
        } else {
          showMessage(newIndex);
        }
      },
    );

    _listen(_repository.approvedAdCampaignsStream(), (campaigns) {
      emit(state.copyWith(approvedCampaigns: campaigns));
    });

    _listen(_repository.qrCodeUrlStream(), (url) {
      emit(state.copyWith(qrCodeUrl: url));
    });

    _listen(_repository.worldCupEnabledStream(), (enabled) {
      emit(state.copyWith(isWorldCupEnabled: enabled));
    });

    _listen(_repository.menuItemsStream(), (items) {
      emit(state.copyWith(menuItems: items));
    });

    _listen(_repository.birthdaySettingsStream(), (data) {
      emit(state.copyWith(
        birthdayImageUrls: List<String>.from(data['birthdayImageUrls'] ?? []),
        birthdayName: data['birthdayName'] as String? ?? '',
        birthdayWish: data['birthdayWish'] as String? ?? '',
        birthdayDurationSeconds: data['birthdayDurationSeconds'] as int? ?? 7,
        isBirthdayActive: data['isBirthdayActive'] == true,
      ));
    });

    _listen(_repository.birthdayWishesStream(), (wishes) {
      emit(state.copyWith(
        birthdayWishes: wishes,
        birthdayWishIndex: 0,
      ));
    });

    _listen(_repository.nowPlayingStream(), (request) {
      final wasPlaying = state.nowPlaying != null;
      final isPlaying = request != null;
      final isNewTrack =
          request != null && (!wasPlaying || request.id != state.nowPlaying?.id);

      if (isNewTrack) {
        _cancelTimers();
        int remainingSeconds = request.durationSeconds;
        if (request.startedPlayingAt != null) {
          final elapsed =
              DateTime.now().difference(request.startedPlayingAt!).inSeconds;
          if (elapsed > 0 && elapsed < request.durationSeconds) {
            remainingSeconds = request.durationSeconds - elapsed;
          }
        }
        if (remainingSeconds < 3) {
          remainingSeconds = request.durationSeconds;
        }

        emit(state.copyWith(
          nowPlaying: request,
          showMusicPhase: true,
        ));

        _musicTimer?.cancel();
        _musicTimer = Timer(Duration(seconds: remainingSeconds), () {
          emit(state.copyWith(showMusicPhase: false));
          resumeAfterMusicPhase();
        });
      } else if (!isPlaying && wasPlaying) {
        _musicTimer?.cancel();
        emit(state.copyWith(
          nowPlaying: null,
          showMusicPhase: false,
        ));
        resumeAfterMusicPhase();
      } else {
        emit(state.copyWith(nowPlaying: request));
      }
    });

    emit(state.copyWith(isLoading: false));
    if (state.isIdleMode) {
      startIdleMode();
    }
  }

  // ── Playback & Message Cycling Logic ─────────────────────────

  /// Finds the next approved campaign that is strictly eligible according to its
  /// date range, active time window, day of week, and frequency lockout interval.
  Map<String, dynamic>? getEligibleCampaign() {
    if (state.approvedCampaigns.isEmpty) return null;
    final now = DateTime.now();

    for (int i = 0; i < state.approvedCampaigns.length; i++) {
      final idx =
          (state.currentCampaignIndex + i) % state.approvedCampaigns.length;
      final camp = state.approvedCampaigns[idx];
      if (TvDisplayUtils.isCampaignEligibleToPlay(camp, now)) {
        return camp;
      }
    }
    return null;
  }

  void startIdleMode(
      {int effectiveSlideCount = 4, VoidCallback? onSlideChange}) {
    _cancelTimers();
    _idleTimer = Timer.periodic(
      Duration(seconds: state.settings?.idleSceneDurationSeconds ?? 5),
      (_) {
        final eligibleCampaign = getEligibleCampaign();
        if (eligibleCampaign != null && !state.showCampaignAdPhase) {
          triggerCampaignAdIfAvailable();
        } else {
          final nextIndex = (state.idleSlideIndex + 1) % effectiveSlideCount;
          emit(state.copyWith(idleSlideIndex: nextIndex));
          onSlideChange?.call();
        }
      },
    );
  }

  void showMessage(int index, {VoidCallback? onAnimate}) {
    if (index >= state.messages.length || state.isIdleMode) return;
    _cancelTimers();

    emit(state.copyWith(
      showQrPhase: false,
      showBirthdayPhase: false,
      currentIndex: index,
    ));

    final msg = state.messages[index];
    final base = (state.settings?.durationSeconds ?? 7) * 1000;
    final bonus = msg.isVip ? (state.settings?.vipBonusSeconds ?? 3) * 1000 : 0;
    final ms = base + bonus;

    int remaining = ms;
    emit(state.copyWith(
      totalMs: ms,
      remainingMs: ms,
      progressValue: 1.0,
    ));

    onAnimate?.call();

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      remaining -= 50;
      if (remaining <= 0) remaining = 0;
      final ratio = TvDisplayUtils.calculateProgressRatio(remaining, ms);
      emit(state.copyWith(
        remainingMs: remaining,
        progressValue: ratio,
      ));
    });

    _advanceTimer = Timer(Duration(milliseconds: ms), () {
      markCurrentDelivered();
      final next = (index + 1) % state.messages.length;
      List<ShoutoutRequest> msgs = List.from(state.messages);

      if (next == 0 && msgs.length > 1) {
        msgs.shuffle(Random());
        emit(state.copyWith(messages: msgs));
      }

      if (next == 0) {
        if (getEligibleCampaign() != null) {
          triggerCampaignAdIfAvailable();
          return;
        }

        emit(state.copyWith(showQrPhase: true));
        _advanceTimer = Timer(const Duration(seconds: 15), () {
          emit(state.copyWith(showQrPhase: false));
          advanceToPostMusicPhase();
        });
        return;
      }

      showMessage(next, onAnimate: onAnimate);
    });
  }

  void triggerCampaignAdIfAvailable(
      {VoidCallback? onStart, VoidCallback? onComplete}) {
    if (state.showCampaignAdPhase) return;
    final campaign = getEligibleCampaign();
    if (campaign == null) return;

    final campaignId = campaign['id'] as String?;
    if (campaignId != null) {
      _repository.recordCampaignImpression(campaignId);
      // Optimistically record locally to immediately lock out for frequency interval
      campaign['lastDisplayedAt'] = DateTime.now();
    }

    final ms = TvDisplayUtils.getCampaignDurationMs(campaign);
    int remaining = ms;

    emit(state.copyWith(
      showCampaignAdPhase: true,
      totalMs: ms,
      remainingMs: ms,
      progressValue: 1.0,
    ));

    onStart?.call();

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      remaining -= 50;
      if (remaining <= 0) remaining = 0;
      emit(state.copyWith(
        remainingMs: remaining,
        progressValue: TvDisplayUtils.calculateProgressRatio(remaining, ms),
      ));
    });

    _advanceTimer?.cancel();
    _advanceTimer = Timer(Duration(milliseconds: ms), () {
      _progressTimer?.cancel();
      emit(state.copyWith(
        showCampaignAdPhase: false,
        currentCampaignIndex: state.currentCampaignIndex + 1,
      ));
      onComplete?.call();
    });
  }

  void advanceToPostMusicPhase() {
    if (state.isBirthdayActive && state.birthdayName.isNotEmpty) {
      emit(state.copyWith(showBirthdayPhase: true));
      _advanceTimer = Timer(Duration(seconds: state.birthdayDurationSeconds), () {
        if (state.birthdayWishes.isNotEmpty) {
          emit(state.copyWith(
            showBirthdayPhase: false,
            showBirthdayWishesPhase: true,
            birthdayWishIndex: 0,
          ));
          _advanceTimer = Timer(const Duration(seconds: 7), nextBirthdayWish);
        } else {
          emit(state.copyWith(showBirthdayPhase: false, currentIndex: 0));
          showMessage(0);
        }
      });
    } else {
      emit(state.copyWith(currentIndex: 0));
      showMessage(0);
    }
  }

  void nextBirthdayWish() {
    final next = state.birthdayWishIndex + 1;
    if (next < state.birthdayWishes.length) {
      emit(state.copyWith(birthdayWishIndex: next));
      _advanceTimer = Timer(const Duration(seconds: 7), nextBirthdayWish);
    } else {
      emit(state.copyWith(
        showBirthdayWishesPhase: false,
        currentIndex: 0,
      ));
      showMessage(0);
    }
  }

  void resumeAfterMusicPhase() {
    if (state.isIdleMode) {
      startIdleMode();
    } else if (state.messages.isNotEmpty) {
      showMessage(state.currentIndex);
    } else {
      startIdleMode();
    }
  }

  void restartCurrentMessage() {
    if (!state.isIdleMode && state.messages.isNotEmpty) {
      showMessage(state.currentIndex);
    }
  }

  void markCurrentDelivered() {
    if (state.isIdleMode || state.messages.isEmpty) return;
    final msg = state.messages[state.currentIndex];
    if (msg.status == ShoutoutStatus.accepted ||
        msg.status == ShoutoutStatus.paid) {
      _repository.markShoutoutDelivered(msg.id);
    }
  }

  void _cancelTimers() {
    _advanceTimer?.cancel();
    _progressTimer?.cancel();
    _idleTimer?.cancel();
    _musicTimer?.cancel();
  }

  void _listen<T>(Stream<T> stream, void Function(T data) onData) {
    final sub = stream.listen((data) {
      if (!isClosed) onData(data);
    });
    _subscriptions.add(sub);
  }

  @override
  Future<void> close() {
    _cancelTimers();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    return super.close();
  }
}
