import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/settings_model.dart';
import '../models/shoutout_request.dart';
import '../models/music_request.dart';

class TvDisplayRepository {
  final String organizationId;
  late final FirebaseFirestore _firestore;

  TvDisplayRepository({required this.organizationId}) {
    _firestore = FirebaseFirestore.instanceFor(
      app: Firebase.app('TV_DISPLAY'),
    );
  }

  Stream<SettingsModel> settingsStream() {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .snapshots()
        .asyncExpand((orgSnap) {
      final orgData = orgSnap.data() ?? {};
      final fallbackType = orgData['businessType'] as String?;

      return _firestore
          .collection('organizations')
          .doc(organizationId)
          .collection('tv_settings')
          .doc('settings')
          .snapshots()
          .map((snap) {
        // Base data comes from the organization document settings
        final data = Map<String, dynamic>.from(orgData);

        // Merge TV-specific settings subdocument if present
        final tvSettingsData = snap.data();
        if (tvSettingsData != null) {
          tvSettingsData.forEach((key, value) {
            if (value != null) {
              data[key] = value;
            }
          });
        }

        if (!data.containsKey('businessType') ||
            (data['businessType'] as String?)?.isEmpty == true) {
          if (fallbackType != null && fallbackType.isNotEmpty) {
            data['businessType'] = fallbackType;
          }
        }
        return SettingsModel.fromMap(data);
      });
    });
  }

  Stream<String> organizationNameStream() {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? {};
      final name = (data['houseName'] as String?)?.trim() ?? '';
      return name;
    });
  }

  Stream<String?> qrCodeUrlStream() {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .snapshots()
        .map((snap) {
      final url = snap.data()?['qrCodeUrl'] as String?;
      print(
          '🔍 qrCodeUrlStream - orgId: $organizationId, exists: ${snap.exists}, url: $url');
      return url;
    });
  }

  Future<void> markShoutoutDelivered(String requestId) async {
    await _firestore.collection('shoutout_requests').doc(requestId).update({
      'status': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<Map<String, dynamic>> birthdaySettingsStream() {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? {};
      final rawList = data['birthdayImageUrls'];
      final List<String> urls = [];
      if (rawList is List) {
        for (final e in rawList) {
          if (e is String && e.trim().isNotEmpty) urls.add(e.trim());
        }
      }
      return {
        'birthdayImageUrls': urls,
        'birthdayName': data['birthdayName'] as String? ?? '',
        'birthdayWish': data['birthdayWish'] as String? ?? '',
        'birthdayDurationSeconds':
            (data['birthdayDurationSeconds'] as num?)?.toInt() ?? 7,
        'isBirthdayActive': data['isBirthdayActive'] == true,
      };
    });
  }

  Stream<List<Map<String, dynamic>>> birthdayWishesStream() {
    return _firestore
        .collection('thoughts')
        .where('organizationId', isEqualTo: organizationId)
        .where('category', isEqualTo: 'birthday')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Stream<bool> worldCupEnabledStream() {
    return _firestore
        .collection('organizations')
        .doc(organizationId)
        .snapshots()
        .map((snap) => snap.data()?['isWorldCupEnabled'] != false);
  }

  Stream<List<Map<String, dynamic>>> menuItemsStream() {
    return _firestore
        .collection('organization_menu_items')
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).where((data) {
        final avail = data['isAvailable'];
        final isAvail =
            (avail == null || avail == true || avail == 'true' || avail == 1);
        final feat = data['isFeatured'];
        final isFeat = (feat == true || feat == 'true' || feat == 1);
        return isAvail && isFeat;
      }).toList();
    });
  }

  Stream<List<ShoutoutRequest>> adsStream({required int expireHours}) {
    return _firestore
        .collection('shoutout_requests')
        .where('organizationId', isEqualTo: organizationId)
        .where('type', isEqualTo: 'advertisement')
        .where('status', whereIn: ['accepted', 'paid'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          final cutoff = DateTime.now().subtract(Duration(hours: expireHours));
          return snap.docs
              .map((d) => ShoutoutRequest.fromMap(d.data(), d.id))
              .where((r) => r.createdAt.isAfter(cutoff))
              .toList();
        });
  }

  Stream<List<Map<String, dynamic>>> approvedAdCampaignsStream() {
    return _firestore
        .collection('ad_campaigns')
        .where('organizationId', isEqualTo: organizationId)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).where((data) {
        final status = (data['status'] as String?)?.toLowerCase();
        return status == 'approved' || status == 'active';
      }).toList();
    });
  }

  Future<void> recordCampaignImpression(String campaignId) async {
    try {
      await _firestore.collection('ad_campaigns').doc(campaignId).update({
        'impressionCount': FieldValue.increment(1),
        'lastDisplayedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error incrementing impression count: $e');
    }
  }

  Stream<MusicRequest?> nowPlayingStream() {
    return _firestore
        .collection('music_requests')
        .where('organizationId', isEqualTo: organizationId)
        .where('status', isEqualTo: 'playing')
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final request = MusicRequest.fromFirestore(snap.docs.first);
      return request.hasTrack ? request : null;
    });
  }

  Future<void> updateHeartbeat(String deviceId, String deviceName) async {
    await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('devices')
        .doc(deviceId)
        .set({
      'deviceId': deviceId,
      'deviceName': deviceName,
      'lastPing': FieldValue.serverTimestamp(),
      'isActive': true,
      'platform': 'web',
      'appVersion': '1.0.0',
    }, SetOptions(merge: true));
  }

  Future<void> markDeviceOffline(String deviceId) async {
    await _firestore
        .collection('organizations')
        .doc(organizationId)
        .collection('devices')
        .doc(deviceId)
        .update({'isActive': false});
  }
}
