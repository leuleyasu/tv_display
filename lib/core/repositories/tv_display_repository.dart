import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/settings_model.dart';
import '../models/shoutout_request.dart';

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
}
