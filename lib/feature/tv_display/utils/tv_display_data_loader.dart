import 'dart:async';
import '../../../../core/repositories/tv_display_repository.dart';

/// Managed container holding all active stream subscriptions for [TvDisplayScreen].
class TvDisplayStreamManager {
  final List<StreamSubscription> _subscriptions = [];

  /// Helper to attach a stream listener and manage lifecycle automatically.
  void listen<T>(Stream<T> stream, void Function(T event) onData) {
    final sub = stream.listen(onData);
    _subscriptions.add(sub);
  }

  /// Cancels all registered stream subscriptions.
  void cancelAll() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }
}

/// Consolidated helper for initializing all TV display data streams cleanly.
class TvDisplayDataLoader {
  static void initializeStreams({
    required TvDisplayRepository repo,
    required TvDisplayStreamManager manager,
    required void Function(String name) onOrgName,
    required void Function(dynamic settings) onSettings,
    required void Function(List<dynamic> ads) onAds,
    required void Function(List<dynamic> campaigns) onCampaigns,
    required void Function(String? qrUrl) onQrCode,
    required void Function(bool worldCupEnabled) onWcFlag,
    required void Function(Map<String, dynamic> birthdayData) onBirthdaySettings,
    required void Function(List<dynamic> birthdayWishes) onBirthdayWishes,
    required void Function(dynamic nowPlaying) onNowPlaying,
    int defaultExpireHours = 24,
  }) {
    manager.listen(repo.organizationNameStream(), onOrgName);
    manager.listen(repo.settingsStream(), onSettings);
    manager.listen(repo.adsStream(expireHours: defaultExpireHours), onAds);
    manager.listen(repo.approvedAdCampaignsStream(), onCampaigns);
    manager.listen(repo.qrCodeUrlStream(), onQrCode);
    manager.listen(repo.worldCupEnabledStream(), onWcFlag);
    manager.listen(repo.birthdaySettingsStream(), onBirthdaySettings);
    manager.listen(repo.birthdayWishesStream(), onBirthdayWishes);
    manager.listen(repo.nowPlayingStream(), onNowPlaying);
  }
}
