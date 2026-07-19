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
        .collection('tv_settings')
        .doc('settings')
        .snapshots()
        .map((snap) => SettingsModel.fromMap(snap.data() ?? {}));
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
        final data = doc.data() as Map<String, dynamic>;
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
}
