import 'package:cloud_firestore/cloud_firestore.dart';

/// Rate model for storing pricing data in Firestore
class RateModel {
  final String id;
  final String fleetClass;
  final double baseFare;
  final double perKmRate;
  final double perMinuteRate;
  final double minimumFare;
  final double bookingFee;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RateModel({
    required this.id,
    required this.fleetClass,
    required this.baseFare,
    required this.perKmRate,
    required this.perMinuteRate,
    required this.minimumFare,
    this.bookingFee = 0.0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RateModel.fromJson(Map<String, dynamic> json, String id) {
    return RateModel(
      id: id,
      fleetClass: json['fleetClass'] ?? '',
      baseFare: (json['baseFare'] ?? 0.0).toDouble(),
      perKmRate: (json['perKmRate'] ?? 0.0).toDouble(),
      perMinuteRate: (json['perMinuteRate'] ?? 0.0).toDouble(),
      minimumFare: (json['minimumFare'] ?? 0.0).toDouble(),
      bookingFee: (json['bookingFee'] ?? 0.0).toDouble(),
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
      'fleetClass': fleetClass,
      'baseFare': baseFare,
      'perKmRate': perKmRate,
      'perMinuteRate': perMinuteRate,
      'minimumFare': minimumFare,
      'bookingFee': bookingFee,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RateModel copyWith({
    String? id,
    String? fleetClass,
    double? baseFare,
    double? perKmRate,
    double? perMinuteRate,
    double? minimumFare,
    double? bookingFee,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RateModel(
      id: id ?? this.id,
      fleetClass: fleetClass ?? this.fleetClass,
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      perMinuteRate: perMinuteRate ?? this.perMinuteRate,
      minimumFare: minimumFare ?? this.minimumFare,
      bookingFee: bookingFee ?? this.bookingFee,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
