import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
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
  final int thoughtDisplayDuration;
  final int vipBonusSeconds;
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

  const SettingsModel({
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
    this.shoutoutPrice = 50,
    this.advertisementPrice = 150,
    this.timeCreditPrice = 5,
    this.timeCreditAmount = 10,
    this.thoughtDisplayDuration = 30,
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
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    List<String> parseStringList(dynamic raw) {
      if (raw is List) return raw.cast<String>();
      if (raw is String) return [raw];
      return [];
    }

    return SettingsModel(
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
      shoutoutPrice: (map['shoutoutPrice'] as num?)?.toDouble() ?? 50,
      advertisementPrice:
          (map['advertisementPrice'] as num?)?.toDouble() ?? 150,
      timeCreditPrice: (map['timeCreditPrice'] as num?)?.toDouble() ?? 5,
      timeCreditAmount: (map['timeCreditAmount'] as num?)?.toDouble() ?? 10,
      thoughtDisplayDuration:
          (map['thoughtDisplayDuration'] as num?)?.toInt() ?? 30,
      vipBonusSeconds: (map['vipBonusSeconds'] as num?)?.toInt() ?? 3,
      expireHours: (map['expireHours'] as num?)?.toInt() ?? 24,
      isEnabled: map['isEnabled'] as bool? ?? true,
      maxPendingRequestsPerUser:
          (map['maxPendingRequestsPerUser'] as num?)?.toInt() ?? 2,
      detectionRadius: (map['detectionRadius'] as num?)?.toDouble(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      djId: map['djId'] as String?,
      userName: map['userName'] as String?,
      musicPricePerTrack: (map['musicPricePerTrack'] as num?)?.toDouble(),
      pricePerMusic: (map['pricePerMusic'] as num?)?.toDouble(),
      imageUrls:
          map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : [],
      logoUrl: map['logoUrl'] as String?,
      bannerImageUrl: map['bannerImageUrl'] as String?,
      qrCodeUrl: map['qrCodeUrl'] as String?,
      fontFamily: map['fontFamily'] as String?,
      fontSize: (map['fontSize'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
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
        'thoughtDisplayDuration': thoughtDisplayDuration,
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
      };

  SettingsModel copyWith({
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
    double? shoutoutPrice,
    double? advertisementPrice,
    double? timeCreditPrice,
    double? timeCreditAmount,
    int? thoughtDisplayDuration,
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
  }) =>
      SettingsModel(
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
        shoutoutPrice: shoutoutPrice ?? this.shoutoutPrice,
        advertisementPrice: advertisementPrice ?? this.advertisementPrice,
        timeCreditPrice: timeCreditPrice ?? this.timeCreditPrice,
        timeCreditAmount: timeCreditAmount ?? this.timeCreditAmount,
        thoughtDisplayDuration:
            thoughtDisplayDuration ?? this.thoughtDisplayDuration,
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
      );

  double get vibeBoardPrice => advertisementPrice;

  @override
  List<Object?> get props => [
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
        shoutoutPrice,
        advertisementPrice,
        timeCreditPrice,
        timeCreditAmount,
        thoughtDisplayDuration,
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
      ];
}
