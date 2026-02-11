import 'package:cloud_firestore/cloud_firestore.dart';

/// Driver model for storing driver data in Firestore
class DriverModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String vehicleMake;
  final String vehicleModel;
  final String vehicleColor;
  final String licensePlate;
  final double rating;
  final int totalRides;
  final String location;
  final bool isOnline;
  final bool isOnBreak;
  final double floatBalance;
  final String regionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.vehicleMake,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.licensePlate,
    required this.rating,
    required this.totalRides,
    required this.location,
    this.isOnline = false,
    this.isOnBreak = false,
    this.floatBalance = 0.0,
    required this.regionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vehicle display string (e.g., "Toyota Camry • AB-123-XY")
  String get vehicleDisplay => '$vehicleMake $vehicleModel • $licensePlate';

  /// Formatted ride count (e.g., "2.1k")
  String get formattedRides {
    if (totalRides >= 1000) {
      return '${(totalRides / 1000).toStringAsFixed(1)}k';
    }
    return totalRides.toString();
  }

  factory DriverModel.fromJson(Map<String, dynamic> json, String id) {
    return DriverModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      vehicleMake: json['vehicleMake'] ?? '',
      vehicleModel: json['vehicleModel'] ?? '',
      vehicleColor: json['vehicleColor'] ?? 'Unknown',
      licensePlate: json['licensePlate'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRides: json['totalRides'] ?? 0,
      location: json['location'] ?? '',
      isOnline: json['isOnline'] ?? false,
      isOnBreak: json['isOnBreak'] ?? false,
      floatBalance: (json['floatBalance'] ?? 0.0).toDouble(),
      regionId: json['regionId'] ?? '',
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
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'vehicleMake': vehicleMake,
      'vehicleModel': vehicleModel,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'rating': rating,
      'totalRides': totalRides,
      'location': location,
      'isOnline': isOnline,
      'isOnBreak': isOnBreak,
      'floatBalance': floatBalance,
      'regionId': regionId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  DriverModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
    double? rating,
    int? totalRides,
    String? location,
    bool? isOnline,
    bool? isOnBreak,
    double? floatBalance,
    String? regionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      floatBalance: floatBalance ?? this.floatBalance,
      regionId: regionId ?? this.regionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
