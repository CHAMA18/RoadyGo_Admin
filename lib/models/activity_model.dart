import 'package:cloud_firestore/cloud_firestore.dart';

/// Activity status enum
enum ActivityStatus { completed, scheduled, cancelled }

/// Activity model for driver activity history
class ActivityModel {
  final String id;
  final String driverId;
  final String title;
  final double amount;
  final ActivityStatus status;
  final DateTime activityDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ActivityModel({
    required this.id,
    required this.driverId,
    required this.title,
    required this.amount,
    required this.status,
    required this.activityDate,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case ActivityStatus.completed:
        return 'completed';
      case ActivityStatus.scheduled:
        return 'scheduled';
      case ActivityStatus.cancelled:
        return 'cancelled';
    }
  }

  String get formattedDateTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final activityDay = DateTime(activityDate.year, activityDate.month, activityDate.day);

    final timeStr = '${activityDate.hour}:${activityDate.minute.toString().padLeft(2, '0')} ${activityDate.hour >= 12 ? 'PM' : 'AM'}';

    if (activityDay == today) {
      return 'Today, $timeStr';
    } else if (activityDay == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[activityDate.weekday - 1]}, $timeStr';
    }
  }

  factory ActivityModel.fromJson(Map<String, dynamic> json, String id) {
    return ActivityModel(
      id: id,
      driverId: json['driverId'] ?? '',
      title: json['title'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      status: _parseStatus(json['status']),
      activityDate: json['activityDate'] is Timestamp
          ? (json['activityDate'] as Timestamp).toDate()
          : DateTime.tryParse(json['activityDate'] ?? '') ?? DateTime.now(),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static ActivityStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return ActivityStatus.completed;
      case 'scheduled':
        return ActivityStatus.scheduled;
      case 'cancelled':
        return ActivityStatus.cancelled;
      default:
        return ActivityStatus.completed;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'title': title,
      'amount': amount,
      'status': status.name,
      'activityDate': Timestamp.fromDate(activityDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ActivityModel copyWith({
    String? id,
    String? driverId,
    String? title,
    double? amount,
    ActivityStatus? status,
    DateTime? activityDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      activityDate: activityDate ?? this.activityDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
