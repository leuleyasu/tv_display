import 'package:flutter_test/flutter_test.dart';
import 'package:night_track_tv/core/models/settings_model.dart';

void main() {
  group('SettingsModel qrCodeSize parsing tests', () {
    test('reads qrCodeSize as double', () {
      final model = SettingsModel.fromMap({
        'qrCodeSize': 320.0,
      });
      expect(model.qrCodeSize, 320.0);
    });

    test('reads qrCodeSize as int', () {
      final model = SettingsModel.fromMap({
        'qrCodeSize': 280,
      });
      expect(model.qrCodeSize, 280.0);
    });

    test('reads qrCodeSize as String', () {
      final model = SettingsModel.fromMap({
        'qrCodeSize': '250',
      });
      expect(model.qrCodeSize, 250.0);
    });

    test('reads snake_case qr_code_size', () {
      final model = SettingsModel.fromMap({
        'qr_code_size': 300,
      });
      expect(model.qrCodeSize, 300.0);
    });

    test('reads qrSize', () {
      final model = SettingsModel.fromMap({
        'qrSize': 220,
      });
      expect(model.qrCodeSize, 220.0);
    });

    test('merged orgData and tv_settings data preserves qrCodeSize', () {
      final orgData = <String, dynamic>{
        'houseName': 'Sky Lounge',
        'qrCodeSize': 350.0,
        'qrCodeUrl': 'https://example.com/qr',
      };
      final tvSettingsData = <String, dynamic>{
        'tvLayoutTemplate': 'fullscreen',
      };

      final merged = Map<String, dynamic>.from(orgData);
      tvSettingsData.forEach((k, v) {
        if (v != null) merged[k] = v;
      });

      final model = SettingsModel.fromMap(merged);
      expect(model.qrCodeSize, 350.0);
      expect(model.qrCodeUrl, 'https://example.com/qr');
      expect(model.tvLayoutTemplate, 'fullscreen');
    });

    test('parses Match Mode settings correctly', () {
      final data = <String, dynamic>{
        'isMatchMode': true,
        'homeTeam': 'Arsenal',
        'awayTeam': 'Chelsea',
        'matchScore': '2 - 1',
        'matchMinute': "78'",
        'sidebarWidthPercent': 0.25,
        'matchTitle': 'Premier League Final',
      };

      final model = SettingsModel.fromMap(data);
      expect(model.isMatchMode, true);
      expect(model.homeTeam, 'Arsenal');
      expect(model.awayTeam, 'Chelsea');
      expect(model.matchScore, '2 - 1');
      expect(model.sidebarWidthPercent, 0.25);
      expect(model.matchTitle, 'Premier League Final');
    });

    test('businessType match activates match mode', () {
      final model = SettingsModel.fromMap({
        'businessType': 'match',
      });
      expect(model.isMatchMode, true);
    });
  });
}
