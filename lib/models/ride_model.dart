import 'package:cloud_firestore/cloud_firestore.dart';

/// Ride status enum
enum RideStatus { pending, enRoute, arrived, completed, cancelled }

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
      fare: (json['fare'] ?? 0.0).toDouble(),
      isDriverVerified: json['isDriverVerified'] ?? true,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
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
    );
  }
}
