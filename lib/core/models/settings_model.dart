import 'package:equatable/equatable.dart';
import '../../feature/tv_display/domain/models/idle_content.dart';

class SettingsModel extends Equatable {
  final String businessType;
  final String? musicType;
  final List<String> musicGenres;
  final List<String> featuredArtists;
  final List<String> slogans;
  final String? organizationId;
  final String? organizationName;
  final String? djName;
  final String? djImageUrl;
  final String? houseName;
  final String? locationName;
  final String? currency;
  final bool isVip;
  final bool isPaymentEnabled;
  final bool isLakiPayEnabled;
  final double shoutoutPrice;

  final double advertisementPrice;
  final double timeCreditPrice;
  final double timeCreditAmount;
  final int durationSeconds;
  final int vipBonusSeconds;
  final double? idleHeadlineSize;
  final List<String>? idleSuggestionLabels; // 4 labels
  final List<IdleSceneConfig>? idleScenes;
  final int? idleSceneDurationSeconds; // seconds per scene

  final double? idleOrgNameSize;

  final double? idleSubtitleSize;

  final double? idleCtaSize;

  final double? idleCardLabelSize;

  final double? idleCardHintSize;

  final double? idleFooterSize;
  final double? idleGreetingSize;
  final double? idleCardWidth;
  final double? idleCardHeight;
  final int expireHours;
  final bool isEnabled;
  final int maxPendingRequestsPerUser;
  final double? detectionRadius;
  final double? latitude;
  final double? longitude;
  final String? djId;
  final String? userName;
  final double? musicPricePerTrack;
  final double? pricePerMusic;
  final List<String> imageUrls;
  final String? logoUrl;
  final String? bannerImageUrl;
  final String? qrCodeUrl;
  final String? fontFamily;
  final double? fontSize;
  final double? qrCodeSize;
  final String tvLayoutTemplate;
  final String tickerNewsText;
  
  // ── Match Mode Settings ─────────────────────────────────────
  final bool isMatchMode;
  final String matchModeType;
  final String? matchTitle;
  final String? homeTeam;
  final String? awayTeam;
  final String? matchScore;
  final String? matchMinute;
  final String matchVideoSource;
  final String? matchStreamUrl;
  final String? matchTickerText;
  final double sidebarWidthPercent;
  final String? sponsorLogoUrl;
  final String? sponsorName;
  final bool isShoutoutEnabled;
  final bool isLiveBoardEnabled;

  const SettingsModel({
    this.businessType = 'nightclub',
    this.musicType,
    this.musicGenres = const [],
    this.featuredArtists = const [],
    this.slogans = const [],
    this.organizationId,
    this.organizationName,
    this.djName,
    this.djImageUrl,
    this.houseName,
    this.locationName,
    this.currency,
    this.isVip = false,
    this.isPaymentEnabled = true,
    this.isLakiPayEnabled = true,
    this.isShoutoutEnabled = true,
    this.isLiveBoardEnabled = true,
    this.shoutoutPrice = 50,
    this.advertisementPrice = 150,
    this.timeCreditPrice = 5,
    this.timeCreditAmount = 10,
    this.durationSeconds = 7,
    this.idleHeadlineSize,
    this.idleOrgNameSize,
    this.idleSubtitleSize,
    this.idleCtaSize,
    this.idleCardLabelSize,
    this.idleCardHintSize,
    this.idleFooterSize,
    this.idleGreetingSize,
    this.idleCardWidth,
    this.idleCardHeight,
    this.idleSceneDurationSeconds,
    this.idleSuggestionLabels,
    this.idleScenes,
    this.vipBonusSeconds = 3,
    this.expireHours = 24,
    this.isEnabled = true,
    this.maxPendingRequestsPerUser = 2,
    this.detectionRadius,
    this.latitude,
    this.longitude,
    this.djId,
    this.userName,
    this.musicPricePerTrack,
    this.pricePerMusic,
    this.imageUrls = const [],
    this.logoUrl,
    this.bannerImageUrl,
    this.qrCodeUrl,
    this.fontFamily,
    this.fontSize,
    this.qrCodeSize,
    this.tvLayoutTemplate = 'bottom_bar',
    this.tickerNewsText = '',
    this.isMatchMode = false,
    this.matchModeType = 'l_bar',
    this.matchTitle,
    this.homeTeam,
    this.awayTeam,
    this.matchScore,
    this.matchMinute,
    this.matchVideoSource = 'demo',
    this.matchStreamUrl,
    this.matchTickerText,
    this.sidebarWidthPercent = 0.23,
    this.sponsorLogoUrl,
    this.sponsorName,
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) return raw.cast<String>();
      if (raw is String) return [raw];
      return [];
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    return SettingsModel(
      businessType: map['businessType'] as String? ?? 'nightclub',
      musicType: map['musicType'] as String?,
      musicGenres: parseStringList(map['musicGenres']),
      featuredArtists: parseStringList(map['featuredArtists']),
      slogans: parseStringList(map['slogans']),
      organizationId: map['organizationId'] as String?,
      organizationName: map['organizationName'] as String?,
      djName: map['djName'] as String?,
      djImageUrl: map['djImageUrl'] as String?,
      houseName: map['houseName'] as String?,
      locationName: map['locationName'] as String?,
      currency: map['currency'] as String?,
      isVip: map['isVip'] == true,
      isPaymentEnabled: map['isPaymentEnabled'] as bool? ?? true,
      isLakiPayEnabled: map['isLakiPayEnabled'] as bool? ?? false,
      shoutoutPrice: parseDouble(map['shoutoutPrice']) ?? 50,
      advertisementPrice: parseDouble(map['advertisementPrice']) ?? 150,
      timeCreditPrice: parseDouble(map['timeCreditPrice']) ?? 5,
      timeCreditAmount: parseDouble(map['timeCreditAmount']) ?? 10,
      durationSeconds: parseInt(map['durationSeconds']) ?? 7,
      vipBonusSeconds: parseInt(map['vipBonusSeconds']) ?? 3,
      expireHours: parseInt(map['expireHours']) ?? 24,
      isEnabled: map['isEnabled'] as bool? ?? true,
      maxPendingRequestsPerUser:
          parseInt(map['maxPendingRequestsPerUser']) ?? 2,
      detectionRadius: parseDouble(map['detectionRadius']),
      latitude: parseDouble(map['latitude']),
      longitude: parseDouble(map['longitude']),
      djId: map['djId'] as String?,
      userName: map['userName'] as String?,
      musicPricePerTrack: parseDouble(map['musicPricePerTrack']),
      pricePerMusic: parseDouble(map['pricePerMusic']),
      imageUrls:
          map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : [],
      logoUrl: map['logoUrl'] as String?,
      bannerImageUrl: map['bannerImageUrl'] as String?,
      qrCodeUrl: (map['qrCodeUrl'] as String?) ??
          (map['qr_code_url'] as String?) ??
          (map['qrUrl'] as String?),
      fontFamily: map['fontFamily'] as String?,
      fontSize: parseDouble(map['fontSize'] ?? map['font_size']),
      qrCodeSize: parseDouble(
        map['qrCodeSize'] ??
            map['qr_code_size'] ??
            map['qrSize'] ??
            map['qr_size'],
      ),
      idleGreetingSize:
          parseDouble(map['idleGreetingSize'] ?? map['idle_greeting_size']),
      idleCardWidth:
          parseDouble(map['idleCardWidth'] ?? map['idle_card_width']),
      idleCardHeight:
          parseDouble(map['idleCardHeight'] ?? map['idle_card_height']),
      idleHeadlineSize: parseDouble(map['idleHeadlineSize']),
      idleOrgNameSize: parseDouble(map['idleOrgNameSize']),
      idleSubtitleSize: parseDouble(map['idleSubtitleSize']),
      idleCtaSize: parseDouble(map['idleCtaSize']),
      idleCardLabelSize: parseDouble(map['idleCardLabelSize']),
      idleCardHintSize: parseDouble(map['idleCardHintSize']),
      idleFooterSize: parseDouble(map['idleFooterSize']),
      tvLayoutTemplate: (map['tvLayoutTemplate'] as String?) ?? 'bottom_bar',
      tickerNewsText: (map['tickerNewsText'] as String?) ?? '',
      isMatchMode: map['isMatchMode'] == true ||
          map['is_match_mode'] == true ||
          map['businessType'] == 'match' ||
          map['business_type'] == 'match',
      matchModeType: (map['matchModeType'] as String?) ??
          (map['match_mode_type'] as String?) ??
          'l_bar',
      matchTitle: (map['matchTitle'] as String?) ?? (map['match_title'] as String?),
      homeTeam: (map['homeTeam'] as String?) ?? (map['home_team'] as String?),
      awayTeam: (map['awayTeam'] as String?) ?? (map['away_team'] as String?),
      matchScore: (map['matchScore'] as String?) ?? (map['match_score'] as String?),
      matchMinute: (map['matchMinute'] as String?) ?? (map['match_minute'] as String?),
      matchVideoSource: (map['matchVideoSource'] as String?) ??
          (map['match_video_source'] as String?) ??
          'demo',
      matchStreamUrl:
          (map['matchStreamUrl'] as String?) ?? (map['match_stream_url'] as String?),
      matchTickerText: (map['matchTickerText'] as String?) ??
          (map['match_ticker_text'] as String?),
      sidebarWidthPercent: parseDouble(
              map['sidebarWidthPercent'] ?? map['sidebar_width_percent']) ??
          0.23,
      sponsorLogoUrl: (map['sponsorLogoUrl'] as String?) ??
          (map['sponsor_logo_url'] as String?),
      sponsorName:
          (map['sponsorName'] as String?) ?? (map['sponsor_name'] as String?),
      isShoutoutEnabled: map['isShoutoutEnabled'] is bool
          ? map['isShoutoutEnabled'] as bool
          : (map['is_shoutout_enabled'] is bool
              ? map['is_shoutout_enabled'] as bool
              : true),
      isLiveBoardEnabled: map['isLiveBoardEnabled'] is bool
          ? map['isLiveBoardEnabled'] as bool
          : (map['is_live_board_enabled'] is bool
              ? map['is_live_board_enabled'] as bool
              : (map['isLiveboardEnabled'] is bool
                  ? map['isLiveboardEnabled'] as bool
                  : true)),
    );
  }

  Map<String, dynamic> toMap() => {
        'businessType': businessType,
        'musicType': musicType,
        'musicGenres': musicGenres,
        'featuredArtists': featuredArtists,
        'slogans': slogans,
        'organizationId': organizationId,
        'organizationName': organizationName,
        'djName': djName,
        'djImageUrl': djImageUrl,
        'houseName': houseName,
        'locationName': locationName,
        'currency': currency,
        'isVip': isVip,
        'isPaymentEnabled': isPaymentEnabled,
        'isLakiPayEnabled': isLakiPayEnabled,
        'shoutoutPrice': shoutoutPrice,
        'advertisementPrice': advertisementPrice,
        'timeCreditPrice': timeCreditPrice,
        'timeCreditAmount': timeCreditAmount,
        'durationSeconds': durationSeconds,
        'vipBonusSeconds': vipBonusSeconds,
        'expireHours': expireHours,
        'isEnabled': isEnabled,
        'maxPendingRequestsPerUser': maxPendingRequestsPerUser,
        'detectionRadius': detectionRadius,
        'latitude': latitude,
        'longitude': longitude,
        'djId': djId,
        'userName': userName,
        'musicPricePerTrack': musicPricePerTrack,
        'pricePerMusic': pricePerMusic,
        'imageUrls': imageUrls,
        'logoUrl': logoUrl,
        'bannerImageUrl': bannerImageUrl,
        'qrCodeUrl': qrCodeUrl,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'qrCodeSize': qrCodeSize,
        'idleGreetingSize': idleGreetingSize,
        'idleCardWidth': idleCardWidth,
        'idleCardHeight': idleCardHeight,
        'tvLayoutTemplate': tvLayoutTemplate,
        'tickerNewsText': tickerNewsText,
        'isMatchMode': isMatchMode,
        'matchModeType': matchModeType,
        'matchTitle': matchTitle,
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'matchScore': matchScore,
        'matchMinute': matchMinute,
        'matchVideoSource': matchVideoSource,
        'matchStreamUrl': matchStreamUrl,
        'matchTickerText': matchTickerText,
        'sidebarWidthPercent': sidebarWidthPercent,
        'sponsorLogoUrl': sponsorLogoUrl,
        'sponsorName': sponsorName,
        'isShoutoutEnabled': isShoutoutEnabled,
        'isLiveBoardEnabled': isLiveBoardEnabled,
      };

  SettingsModel copyWith({
    String? businessType,
    String? musicType,
    List<String>? musicGenres,
    List<String>? featuredArtists,
    List<String>? slogans,
    String? organizationId,
    String? organizationName,
    String? djName,
    String? djImageUrl,
    String? houseName,
    String? locationName,
    String? currency,
    bool? isVip,
    bool? isPaymentEnabled,
    bool? isLakiPayEnabled,
    bool? isShoutoutEnabled,
    bool? isLiveBoardEnabled,
    double? shoutoutPrice,
    double? advertisementPrice,
    double? timeCreditPrice,
    double? timeCreditAmount,
    int? durationSeconds,
    int? vipBonusSeconds,
    int? expireHours,
    bool? isEnabled,
    int? maxPendingRequestsPerUser,
    double? detectionRadius,
    double? latitude,
    double? longitude,
    String? djId,
    String? userName,
    double? musicPricePerTrack,
    double? pricePerMusic,
    List<String>? imageUrls,
    String? logoUrl,
    String? bannerImageUrl,
    String? qrCodeUrl,
    String? fontFamily,
    double? fontSize,
    double? qrCodeSize,
    double? idleGreetingSize,
    double? idleCardWidth,
    double? idleCardHeight,
    String? tvLayoutTemplate,
    String? tickerNewsText,
    bool? isMatchMode,
    String? matchModeType,
    String? matchTitle,
    String? homeTeam,
    String? awayTeam,
    String? matchScore,
    String? matchMinute,
    String? matchVideoSource,
    String? matchStreamUrl,
    String? matchTickerText,
    double? sidebarWidthPercent,
    String? sponsorLogoUrl,
    String? sponsorName,
  }) =>
      SettingsModel(
        businessType: businessType ?? this.businessType,
        musicType: musicType ?? this.musicType,
        musicGenres: musicGenres ?? this.musicGenres,
        featuredArtists: featuredArtists ?? this.featuredArtists,
        slogans: slogans ?? this.slogans,
        organizationId: organizationId ?? this.organizationId,
        organizationName: organizationName ?? this.organizationName,
        djName: djName ?? this.djName,
        djImageUrl: djImageUrl ?? this.djImageUrl,
        houseName: houseName ?? this.houseName,
        locationName: locationName ?? this.locationName,
        currency: currency ?? this.currency,
        isVip: isVip ?? this.isVip,
        isPaymentEnabled: isPaymentEnabled ?? this.isPaymentEnabled,
        isLakiPayEnabled: isLakiPayEnabled ?? this.isLakiPayEnabled,
        isShoutoutEnabled: isShoutoutEnabled ?? this.isShoutoutEnabled,
        isLiveBoardEnabled: isLiveBoardEnabled ?? this.isLiveBoardEnabled,
        shoutoutPrice: shoutoutPrice ?? this.shoutoutPrice,
        advertisementPrice: advertisementPrice ?? this.advertisementPrice,
        timeCreditPrice: timeCreditPrice ?? this.timeCreditPrice,
        timeCreditAmount: timeCreditAmount ?? this.timeCreditAmount,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        vipBonusSeconds: vipBonusSeconds ?? this.vipBonusSeconds,
        expireHours: expireHours ?? this.expireHours,
        isEnabled: isEnabled ?? this.isEnabled,
        maxPendingRequestsPerUser:
            maxPendingRequestsPerUser ?? this.maxPendingRequestsPerUser,
        detectionRadius: detectionRadius ?? this.detectionRadius,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        djId: djId ?? this.djId,
        userName: userName ?? this.userName,
        musicPricePerTrack: musicPricePerTrack ?? this.musicPricePerTrack,
        pricePerMusic: pricePerMusic ?? this.pricePerMusic,
        imageUrls: imageUrls ?? this.imageUrls,
        logoUrl: logoUrl ?? this.logoUrl,
        bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
        qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        qrCodeSize: qrCodeSize ?? this.qrCodeSize,
        idleGreetingSize: idleGreetingSize ?? this.idleGreetingSize,
        idleCardWidth: idleCardWidth ?? this.idleCardWidth,
        idleCardHeight: idleCardHeight ?? this.idleCardHeight,
        tvLayoutTemplate: tvLayoutTemplate ?? this.tvLayoutTemplate,
        tickerNewsText: tickerNewsText ?? this.tickerNewsText,
        isMatchMode: isMatchMode ?? this.isMatchMode,
        matchModeType: matchModeType ?? this.matchModeType,
        matchTitle: matchTitle ?? this.matchTitle,
        homeTeam: homeTeam ?? this.homeTeam,
        awayTeam: awayTeam ?? this.awayTeam,
        matchScore: matchScore ?? this.matchScore,
        matchMinute: matchMinute ?? this.matchMinute,
        matchVideoSource: matchVideoSource ?? this.matchVideoSource,
        matchStreamUrl: matchStreamUrl ?? this.matchStreamUrl,
        matchTickerText: matchTickerText ?? this.matchTickerText,
        sidebarWidthPercent: sidebarWidthPercent ?? this.sidebarWidthPercent,
        sponsorLogoUrl: sponsorLogoUrl ?? this.sponsorLogoUrl,
        sponsorName: sponsorName ?? this.sponsorName,
      );

  double get vibeBoardPrice => advertisementPrice;

  @override
  List<Object?> get props => [
        businessType,
        musicType,
        musicGenres,
        featuredArtists,
        slogans,
        organizationId,
        organizationName,
        djName,
        djImageUrl,
        houseName,
        locationName,
        currency,
        isVip,
        isPaymentEnabled,
        isLakiPayEnabled,
        isShoutoutEnabled,
        isLiveBoardEnabled,
        shoutoutPrice,
        advertisementPrice,
        timeCreditPrice,
        timeCreditAmount,
        durationSeconds,
        vipBonusSeconds,
        expireHours,
        isEnabled,
        maxPendingRequestsPerUser,
        detectionRadius,
        latitude,
        longitude,
        djId,
        userName,
        musicPricePerTrack,
        pricePerMusic,
        imageUrls,
        logoUrl,
        bannerImageUrl,
        qrCodeUrl,
        fontFamily,
        fontSize,
        qrCodeSize,
        idleGreetingSize,
        idleCardWidth,
        idleCardHeight,
        tvLayoutTemplate,
        tickerNewsText,
        isMatchMode,
        matchModeType,
        matchTitle,
        homeTeam,
        awayTeam,
        matchScore,
        matchMinute,
        matchVideoSource,
        matchStreamUrl,
        matchTickerText,
        sidebarWidthPercent,
        sponsorLogoUrl,
        sponsorName,
      ];
}
