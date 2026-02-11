import 'package:cloud_firestore/cloud_firestore.dart';

/// Schedule model for driver schedules
class ScheduleModel {
  final String id;
  final String driverId;
  final String driverName;
  final String shiftType; // 'morning', 'afternoon', 'evening', 'night'
  final DateTime startTime;
  final DateTime endTime;
  final String regionId;
  final String regionName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleModel({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    required this.regionId,
    required this.regionName,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedShiftTime {
    final startHour = startTime.hour;
    final endHour = endTime.hour;
    final startPeriod = startHour >= 12 ? 'PM' : 'AM';
    final endPeriod = endHour >= 12 ? 'PM' : 'AM';
    final formattedStart = '${startHour > 12 ? startHour - 12 : startHour}:${startTime.minute.toString().padLeft(2, '0')} $startPeriod';
    final formattedEnd = '${endHour > 12 ? endHour - 12 : endHour}:${endTime.minute.toString().padLeft(2, '0')} $endPeriod';
    return '$formattedStart - $formattedEnd';
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json, String id) {
    return ScheduleModel(
      id: id,
      driverId: json['driverId'] ?? '',
      driverName: json['driverName'] ?? '',
      shiftType: json['shiftType'] ?? 'morning',
      startTime: json['startTime'] is Timestamp
          ? (json['startTime'] as Timestamp).toDate()
          : DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: json['endTime'] is Timestamp
          ? (json['endTime'] as Timestamp).toDate()
          : DateTime.tryParse(json['endTime'] ?? '') ?? DateTime.now(),
      regionId: json['regionId'] ?? '',
      regionName: json['regionName'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'shiftType': shiftType,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'regionId': regionId,
      'regionName': regionName,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ScheduleModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? shiftType,
    DateTime? startTime,
    DateTime? endTime,
    String? regionId,
    String? regionName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      shiftType: shiftType ?? this.shiftType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
