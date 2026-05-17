import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ShoutoutStatus { pending, accepted, rejected, paid, delivered }

enum ShoutoutType { shoutout, advertisement }

enum PaymentStatus { pending, paid, failed, free }

class ShoutoutRequest extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String message;
  final ShoutoutType type;
  final String? preferredTime;
  final ShoutoutStatus status;
  final double price;
  final DateTime createdAt;
  final DateTime? paidAt;
  final PaymentStatus paymentStatus;
  final String? organizationId;
  final String? notes;
  final String? chapaReference;
  final String? chapaTransactionId;
  final bool isCreditBased;
  final double deductedCredits;
  final bool isVip;

  const ShoutoutRequest({
    required this.id,
    required this.userId,
    this.userName,
    required this.message,
    required this.type,
    this.preferredTime,
    this.status = ShoutoutStatus.pending,
    this.price = 0,
    required this.createdAt,
    this.paidAt,
    this.paymentStatus = PaymentStatus.pending,
    this.organizationId,
    this.notes,
    this.chapaReference,
    this.chapaTransactionId,
    this.isCreditBased = false,
    this.deductedCredits = 0,
    this.isVip = false,
  });

  factory ShoutoutRequest.fromMap(Map<String, dynamic> map, String id) {
    return ShoutoutRequest(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String?,
      message: map['message'] as String? ?? '',
      type: (map['type'] as String? ?? 'shoutout') == 'advertisement'
          ? ShoutoutType.advertisement
          : ShoutoutType.shoutout,
      preferredTime: map['preferredTime'] as String?,
      status: _parseStatus(map['status'] as String?),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
      paymentStatus: _parsePaymentStatus(map['paymentStatus'] as String?),
      organizationId: map['organizationId'] as String?,
      notes: map['notes'] as String?,
      chapaReference: map['chapaReference'] as String?,
      chapaTransactionId: map['chapaTransactionId'] as String?,
      isCreditBased: map['isCreditBased'] as bool? ?? false,
      deductedCredits: (map['deductedCredits'] as num?)?.toDouble() ?? 0,
      isVip: map['isVip'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'message': message,
      'type': type == ShoutoutType.advertisement ? 'advertisement' : 'shoutout',
      'preferredTime': preferredTime,
      'status': status.name,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'paymentStatus': paymentStatus.name,
      'organizationId': organizationId,
      'notes': notes,
      'chapaReference': chapaReference,
      'chapaTransactionId': chapaTransactionId,
      'isCreditBased': isCreditBased,
      'deductedCredits': deductedCredits,
      'isVip': isVip,
    };
  }

  ShoutoutRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? message,
    ShoutoutType? type,
    String? preferredTime,
    ShoutoutStatus? status,
    double? price,
    DateTime? createdAt,
    DateTime? paidAt,
    PaymentStatus? paymentStatus,
    String? organizationId,
    String? notes,
    String? chapaReference,
    String? chapaTransactionId,
    bool? isCreditBased,
    double? deductedCredits,
    bool? isVip,
  }) {
    return ShoutoutRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      message: message ?? this.message,
      type: type ?? this.type,
      preferredTime: preferredTime ?? this.preferredTime,
      status: status ?? this.status,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      paidAt: paidAt ?? this.paidAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      organizationId: organizationId ?? this.organizationId,
      notes: notes ?? this.notes,
      chapaReference: chapaReference ?? this.chapaReference,
      chapaTransactionId: chapaTransactionId ?? this.chapaTransactionId,
      isCreditBased: isCreditBased ?? this.isCreditBased,
      deductedCredits: deductedCredits ?? this.deductedCredits,
      isVip: isVip ?? this.isVip,
    );
  }

  static ShoutoutStatus _parseStatus(String? status) {
    switch (status) {
      case 'accepted':
        return ShoutoutStatus.accepted;
      case 'rejected':
        return ShoutoutStatus.rejected;
      case 'paid':
        return ShoutoutStatus.paid;
      case 'delivered':
        return ShoutoutStatus.delivered;
      default:
        return ShoutoutStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status) {
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'free':
        return PaymentStatus.free;
      default:
        return PaymentStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    message,
    type,
    preferredTime,
    status,
    price,
    createdAt,
    paidAt,
    paymentStatus,
    organizationId,
    notes,
    chapaReference,
    chapaTransactionId,
    isCreditBased,
    deductedCredits,
    isVip,
  ];
}
