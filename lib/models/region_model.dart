import 'package:cloud_firestore/cloud_firestore.dart';

/// Region model for storing region/zone data with pricing in Firestore
class RegionModel {
  final String id;
  final String name;
  final String cityName;
  final String countryName;
  final String countryCode;
  final String currencyCode;
  final String currencySymbol;
  final String description;
  final int activeDrivers;
  final int totalRides;
  final bool isActive;
  
  // Standard Pricing
  final double costOfRide;
  final double costPerKm;
  final double costPerMin;
  final double floatPercent;
  
  // Corporate Pricing
  final double corpCostOfRide;
  final double corpCostPerKm;
  final double corpCostPerMin;
  final double corpFloatPercent;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  RegionModel({
    required this.id,
    required this.name,
    this.cityName = '',
    this.countryName = '',
    this.countryCode = '',
    this.currencyCode = '',
    this.currencySymbol = '',
    required this.description,
    this.activeDrivers = 0,
    this.totalRides = 0,
    this.isActive = true,
    this.costOfRide = 0.0,
    this.costPerKm = 0.0,
    this.costPerMin = 0.0,
    this.floatPercent = 0.0,
    this.corpCostOfRide = 0.0,
    this.corpCostPerKm = 0.0,
    this.corpCostPerMin = 0.0,
    this.corpFloatPercent = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json, String id) {
    return RegionModel(
      id: id,
      name: json['name'] ?? '',
      cityName: json['cityName'] ?? '',
      countryName: json['countryName'] ?? '',
      countryCode: json['countryCode'] ?? '',
      currencyCode: json['currencyCode'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
      description: json['description'] ?? '',
      activeDrivers: json['activeDrivers'] ?? 0,
      totalRides: json['totalRides'] ?? 0,
      isActive: json['isActive'] ?? true,
      costOfRide: (json['costOfRide'] ?? 0.0).toDouble(),
      costPerKm: (json['costPerKm'] ?? 0.0).toDouble(),
      costPerMin: (json['costPerMin'] ?? 0.0).toDouble(),
      floatPercent: (json['floatPercent'] ?? 0.0).toDouble(),
      corpCostOfRide: (json['corpCostOfRide'] ?? 0.0).toDouble(),
      corpCostPerKm: (json['corpCostPerKm'] ?? 0.0).toDouble(),
      corpCostPerMin: (json['corpCostPerMin'] ?? 0.0).toDouble(),
      corpFloatPercent: (json['corpFloatPercent'] ?? 0.0).toDouble(),
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
      'cityName': cityName,
      'countryName': countryName,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'description': description,
      'activeDrivers': activeDrivers,
      'totalRides': totalRides,
      'isActive': isActive,
      'costOfRide': costOfRide,
      'costPerKm': costPerKm,
      'costPerMin': costPerMin,
      'floatPercent': floatPercent,
      'corpCostOfRide': corpCostOfRide,
      'corpCostPerKm': corpCostPerKm,
      'corpCostPerMin': corpCostPerMin,
      'corpFloatPercent': corpFloatPercent,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  RegionModel copyWith({
    String? id,
    String? name,
    String? cityName,
    String? countryName,
    String? countryCode,
    String? currencyCode,
    String? currencySymbol,
    String? description,
    int? activeDrivers,
    int? totalRides,
    bool? isActive,
    double? costOfRide,
    double? costPerKm,
    double? costPerMin,
    double? floatPercent,
    double? corpCostOfRide,
    double? corpCostPerKm,
    double? corpCostPerMin,
    double? corpFloatPercent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cityName: cityName ?? this.cityName,
      countryName: countryName ?? this.countryName,
      countryCode: countryCode ?? this.countryCode,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      description: description ?? this.description,
      activeDrivers: activeDrivers ?? this.activeDrivers,
      totalRides: totalRides ?? this.totalRides,
      isActive: isActive ?? this.isActive,
      costOfRide: costOfRide ?? this.costOfRide,
      costPerKm: costPerKm ?? this.costPerKm,
      costPerMin: costPerMin ?? this.costPerMin,
      floatPercent: floatPercent ?? this.floatPercent,
      corpCostOfRide: corpCostOfRide ?? this.corpCostOfRide,
      corpCostPerKm: corpCostPerKm ?? this.corpCostPerKm,
      corpCostPerMin: corpCostPerMin ?? this.corpCostPerMin,
      corpFloatPercent: corpFloatPercent ?? this.corpFloatPercent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
