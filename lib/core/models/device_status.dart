class DeviceStatus {
  final String deviceId;
  final String deviceName;
  final DateTime? lastPing;
  final bool isActive;
  final String platform;
  final String appVersion;

  const DeviceStatus({
    required this.deviceId,
    required this.deviceName,
    this.lastPing,
    this.isActive = true,
    this.platform = 'web',
    this.appVersion = '1.0.0',
  });

  factory DeviceStatus.fromMap(Map<String, dynamic> map) {
    return DeviceStatus(
      deviceId: map['deviceId'] as String? ?? '',
      deviceName: map['deviceName'] as String? ?? '',
      lastPing: (map['lastPing'] as dynamic)?.toDate(),
      isActive: map['isActive'] as bool? ?? false,
      platform: map['platform'] as String? ?? 'web',
      appVersion: map['appVersion'] as String? ?? '1.0.0',
    );
  }

  Map<String, dynamic> toMap() => {
        'deviceId': deviceId,
        'deviceName': deviceName,
        'isActive': isActive,
        'platform': platform,
        'appVersion': appVersion,
      };
}
