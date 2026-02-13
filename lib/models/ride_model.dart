import 'package:cloud_firestore/cloud_firestore.dart';

/// Ride status enum
enum RideStatus { pending, enRoute, arrived, completed, cancelled }

/// Ride type enum - standard rider or corporate
enum RideType { standard, corporate }

/// Ride model for storing ride data in Firestore
class RideModel {
  final String id;
  final String? driverId;
  final String? driverName;
  final String? driverPhotoUrl;
  final String vehicleInfo;
  final String fleetClass;
  final RideStatus status;
  final String pickupLocation;
  final String dropoffLocation;
  final double? fare;
  final bool isDriverVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Region and pricing fields
  final String? regionId;
  final String? regionName;
  final RideType rideType;
  final double? distanceKm;
  final int? durationMinutes;
  
  // Pricing snapshot at time of ride creation (from region)
  final double? baseFare;
  final double? costPerKm;
  final double? costPerMin;
  final double? floatPercent;
  final double? estimatedFare;

  RideModel({
    required this.id,
    this.driverId,
    this.driverName,
    this.driverPhotoUrl,
    required this.vehicleInfo,
    this.fleetClass = 'Standard',
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.fare,
    this.isDriverVerified = true,
    required this.createdAt,
    required this.updatedAt,
    this.regionId,
    this.regionName,
    this.rideType = RideType.standard,
    this.distanceKm,
    this.durationMinutes,
    this.baseFare,
    this.costPerKm,
    this.costPerMin,
    this.floatPercent,
    this.estimatedFare,
  });

  bool get isPending => status == RideStatus.pending;

  String get statusText {
    switch (status) {
      case RideStatus.pending:
        return 'Pending';
      case RideStatus.enRoute:
        return 'En Route';
      case RideStatus.arrived:
        return 'Arrived';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }

  factory RideModel.fromJson(Map<String, dynamic> json, String id) {
    return RideModel(
      id: id,
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhotoUrl: json['driverPhotoUrl'],
      vehicleInfo: json['vehicleInfo'] ?? '',
      fleetClass: json['fleetClass'] ?? 'Standard',
      status: _parseStatus(json['status']),
      pickupLocation: json['pickupLocation'] ?? '',
      dropoffLocation: json['dropoffLocation'] ?? '',
      fare: json['fare'] != null ? (json['fare']).toDouble() : null,
      isDriverVerified: json['isDriverVerified'] ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      regionId: json['regionId'],
      regionName: json['regionName'],
      rideType: _parseRideType(json['rideType']),
      distanceKm: json['distanceKm'] != null ? (json['distanceKm']).toDouble() : null,
      durationMinutes: json['durationMinutes'],
      baseFare: json['baseFare'] != null ? (json['baseFare']).toDouble() : null,
      costPerKm: json['costPerKm'] != null ? (json['costPerKm']).toDouble() : null,
      costPerMin: json['costPerMin'] != null ? (json['costPerMin']).toDouble() : null,
      floatPercent: json['floatPercent'] != null ? (json['floatPercent']).toDouble() : null,
      estimatedFare: json['estimatedFare'] != null ? (json['estimatedFare']).toDouble() : null,
    );
  }

  static RideType _parseRideType(String? type) {
    switch (type?.toLowerCase()) {
      case 'corporate':
        return RideType.corporate;
      default:
        return RideType.standard;
    }
  }

  static RideStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return RideStatus.pending;
      case 'enroute':
      case 'en_route':
        return RideStatus.enRoute;
      case 'arrived':
        return RideStatus.arrived;
      case 'completed':
        return RideStatus.completed;
      case 'cancelled':
        return RideStatus.cancelled;
      default:
        return RideStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'driverName': driverName,
      'driverPhotoUrl': driverPhotoUrl,
      'vehicleInfo': vehicleInfo,
      'fleetClass': fleetClass,
      'status': status.name,
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'fare': fare,
      'isDriverVerified': isDriverVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'regionId': regionId,
      'regionName': regionName,
      'rideType': rideType.name,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'baseFare': baseFare,
      'costPerKm': costPerKm,
      'costPerMin': costPerMin,
      'floatPercent': floatPercent,
      'estimatedFare': estimatedFare,
    };
  }

  RideModel copyWith({
    String? id,
    String? driverId,
    String? driverName,
    String? driverPhotoUrl,
    String? vehicleInfo,
    String? fleetClass,
    RideStatus? status,
    String? pickupLocation,
    String? dropoffLocation,
    double? fare,
    bool? isDriverVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? regionId,
    String? regionName,
    RideType? rideType,
    double? distanceKm,
    int? durationMinutes,
    double? baseFare,
    double? costPerKm,
    double? costPerMin,
    double? floatPercent,
    double? estimatedFare,
  }) {
    return RideModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhotoUrl: driverPhotoUrl ?? this.driverPhotoUrl,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      fleetClass: fleetClass ?? this.fleetClass,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      fare: fare ?? this.fare,
      isDriverVerified: isDriverVerified ?? this.isDriverVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      rideType: rideType ?? this.rideType,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      baseFare: baseFare ?? this.baseFare,
      costPerKm: costPerKm ?? this.costPerKm,
      costPerMin: costPerMin ?? this.costPerMin,
      floatPercent: floatPercent ?? this.floatPercent,
      estimatedFare: estimatedFare ?? this.estimatedFare,
    );
  }
}
