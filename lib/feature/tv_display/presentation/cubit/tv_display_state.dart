import 'package:equatable/equatable.dart';
import '../../../../core/models/settings_model.dart';
import '../../../../core/models/shoutout_request.dart';
import '../../../../core/models/music_request.dart';

class TvDisplayState extends Equatable {
  final bool isLoading;
  final String orgName;
  final SettingsModel? settings;
  final List<ShoutoutRequest> messages;
  final List<Map<String, dynamic>> approvedCampaigns;
  final String? qrCodeUrl;
  final bool isWorldCupEnabled;

  // Birthday state
  final bool isBirthdayActive;
  final String birthdayName;
  final String birthdayWish;
  final List<String> birthdayImageUrls;
  final int birthdayDurationSeconds;
  final List<Map<String, dynamic>> birthdayWishes;
  final int birthdayWishIndex;

  // Now Playing
  final MusicRequest? nowPlaying;

  // Display status & phase flags
  final bool isIdleMode;
  final bool showMusicPhase;
  final int currentIndex;
  final int idleSlideIndex;
  final bool showCampaignAdPhase;
  final int currentCampaignIndex;
  final double progressValue;
  final bool showQrPhase;
  final bool showBirthdayPhase;
  final bool showBirthdayWishesPhase;
  final int totalMs;
  final int remainingMs;

  const TvDisplayState({
    this.isLoading = true,
    this.orgName = '',
    this.settings,
    this.messages = const [],
    this.approvedCampaigns = const [],
    this.qrCodeUrl,
    this.isWorldCupEnabled = false,
    this.isBirthdayActive = false,
    this.birthdayName = '',
    this.birthdayWish = '',
    this.birthdayImageUrls = const [],
    this.birthdayDurationSeconds = 7,
    this.birthdayWishes = const [],
    this.birthdayWishIndex = 0,
    this.nowPlaying,
    this.isIdleMode = true,
    this.showMusicPhase = false,
    this.currentIndex = 0,
    this.idleSlideIndex = 0,
    this.showCampaignAdPhase = false,
    this.currentCampaignIndex = 0,
    this.progressValue = 1.0,
    this.showQrPhase = false,
    this.showBirthdayPhase = false,
    this.showBirthdayWishesPhase = false,
    this.totalMs = 0,
    this.remainingMs = 0,
  });

  TvDisplayState copyWith({
    bool? isLoading,
    String? orgName,
    SettingsModel? settings,
    List<ShoutoutRequest>? messages,
    List<Map<String, dynamic>>? approvedCampaigns,
    String? qrCodeUrl,
    bool? isWorldCupEnabled,
    bool? isBirthdayActive,
    String? birthdayName,
    String? birthdayWish,
    List<String>? birthdayImageUrls,
    int? birthdayDurationSeconds,
    List<Map<String, dynamic>>? birthdayWishes,
    int? birthdayWishIndex,
    MusicRequest? nowPlaying,
    bool? isIdleMode,
    bool? showMusicPhase,
    int? currentIndex,
    int? idleSlideIndex,
    bool? showCampaignAdPhase,
    int? currentCampaignIndex,
    double? progressValue,
    bool? showQrPhase,
    bool? showBirthdayPhase,
    bool? showBirthdayWishesPhase,
    int? totalMs,
    int? remainingMs,
  }) {
    return TvDisplayState(
      isLoading: isLoading ?? this.isLoading,
      orgName: orgName ?? this.orgName,
      settings: settings ?? this.settings,
      messages: messages ?? this.messages,
      approvedCampaigns: approvedCampaigns ?? this.approvedCampaigns,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      isWorldCupEnabled: isWorldCupEnabled ?? this.isWorldCupEnabled,
      isBirthdayActive: isBirthdayActive ?? this.isBirthdayActive,
      birthdayName: birthdayName ?? this.birthdayName,
      birthdayWish: birthdayWish ?? this.birthdayWish,
      birthdayImageUrls: birthdayImageUrls ?? this.birthdayImageUrls,
      birthdayDurationSeconds:
          birthdayDurationSeconds ?? this.birthdayDurationSeconds,
      birthdayWishes: birthdayWishes ?? this.birthdayWishes,
      birthdayWishIndex: birthdayWishIndex ?? this.birthdayWishIndex,
      nowPlaying: nowPlaying ?? this.nowPlaying,
      isIdleMode: isIdleMode ?? this.isIdleMode,
      showMusicPhase: showMusicPhase ?? this.showMusicPhase,
      currentIndex: currentIndex ?? this.currentIndex,
      idleSlideIndex: idleSlideIndex ?? this.idleSlideIndex,
      showCampaignAdPhase: showCampaignAdPhase ?? this.showCampaignAdPhase,
      currentCampaignIndex: currentCampaignIndex ?? this.currentCampaignIndex,
      progressValue: progressValue ?? this.progressValue,
      showQrPhase: showQrPhase ?? this.showQrPhase,
      showBirthdayPhase: showBirthdayPhase ?? this.showBirthdayPhase,
      showBirthdayWishesPhase:
          showBirthdayWishesPhase ?? this.showBirthdayWishesPhase,
      totalMs: totalMs ?? this.totalMs,
      remainingMs: remainingMs ?? this.remainingMs,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        orgName,
        settings,
        messages,
        approvedCampaigns,
        qrCodeUrl,
        isWorldCupEnabled,
        isBirthdayActive,
        birthdayName,
        birthdayWish,
        birthdayImageUrls,
        birthdayDurationSeconds,
        birthdayWishes,
        birthdayWishIndex,
        nowPlaying,
        isIdleMode,
        showMusicPhase,
        currentIndex,
        idleSlideIndex,
        showCampaignAdPhase,
        currentCampaignIndex,
        progressValue,
        showQrPhase,
        showBirthdayPhase,
        showBirthdayWishesPhase,
        totalMs,
        remainingMs,
      ];
}
