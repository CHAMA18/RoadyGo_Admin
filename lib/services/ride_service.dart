import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/region_model.dart';
import 'package:roadygo_admin/models/ride_model.dart';
import 'package:roadygo_admin/services/pricing_service.dart';

class RideCreationResult {
  final String rideId;
  final int nearbyDriversNotified;

  const RideCreationResult({
    required this.rideId,
    required this.nearbyDriversNotified,
  });
}

class CommissionSummary {
  final double platformCommission;
  final int completedRides;
  final int activeDriversWithCommission;

  const CommissionSummary({
    required this.platformCommission,
    required this.completedRides,
    required this.activeDriversWithCommission,
  });
}

class DriverCommissionSummary {
  final String driverId;
  final String driverName;
  final double commission;
  final int completedRides;

  const DriverCommissionSummary({
    required this.driverId,
    required this.driverName,
    required this.commission,
    required this.completedRides,
  });
}

/// Service for managing ride data in Firestore
class RideService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RideModel> _rides = [];
  List<RideModel> _activeRides = [];
  bool _isLoading = false;
  String? _error;

  List<RideModel> get rides => _rides;
  List<RideModel> get activeRides => _activeRides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all rides
  Future<void> fetchRides() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('rides')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();

      _rides = snapshot.docs
          .map((doc) => RideModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch rides: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching rides: $e');
    }
  }

  /// Fetch active rides (enRoute, arrived - rides currently in progress)
  Future<void> fetchActiveRides() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('status', whereIn: ['enRoute', 'arrived'])
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _activeRides = snapshot.docs
          .map((doc) => RideModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch active rides: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching active rides: $e');
    }
  }

  /// Stream of active rides (enRoute, arrived - rides currently in progress)
  Stream<List<RideModel>> watchActiveRides() {
    return _firestore
        .collection('rides')
        .where('status', whereIn: ['enRoute', 'arrived'])
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<CommissionSummary> watchCommissionSummary() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      double total = 0;
      final driverIds = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        total += _calculateRideCommission(data);
        final driverId = (data['driverId'] ?? '').toString().trim();
        if (driverId.isNotEmpty) {
          driverIds.add(driverId);
        }
      }
      return CommissionSummary(
        platformCommission: total,
        completedRides: snapshot.docs.length,
        activeDriversWithCommission: driverIds.length,
      );
    });
  }

  Stream<List<DriverCommissionSummary>> watchDriverCommissionBreakdown() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      final byDriver = <String, DriverCommissionSummary>{};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final driverIdRaw = (data['driverId'] ?? '').toString().trim();
        if (driverIdRaw.isEmpty) continue;
        final driverName =
            (data['driverName'] ?? 'Unknown Driver').toString().trim();
        final commission = _calculateRideCommission(data);

        final previous = byDriver[driverIdRaw];
        if (previous == null) {
          byDriver[driverIdRaw] = DriverCommissionSummary(
            driverId: driverIdRaw,
            driverName: driverName.isEmpty ? 'Unknown Driver' : driverName,
            commission: commission,
            completedRides: 1,
          );
        } else {
          byDriver[driverIdRaw] = DriverCommissionSummary(
            driverId: previous.driverId,
            driverName: previous.driverName,
            commission: previous.commission + commission,
            completedRides: previous.completedRides + 1,
          );
        }
      }

      final list = byDriver.values.toList()
        ..sort((a, b) => b.commission.compareTo(a.commission));
      return list;
    });
  }

  double _calculateRideCommission(Map<String, dynamic> data) {
    final fare = _asDouble(data['fare']) ??
        _asDouble(data['estimatedFare']) ??
        _reconstructFare(data);
    final floatPercent = _asDouble(data['floatPercent']) ?? 0;
    if (fare <= 0 || floatPercent <= 0) return 0;
    return fare * (floatPercent / 100);
  }

  double _reconstructFare(Map<String, dynamic> data) {
    final baseFare = _asDouble(data['baseFare']) ?? 0;
    final costPerKm = _asDouble(data['costPerKm']) ?? 0;
    final costPerMin = _asDouble(data['costPerMin']) ?? 0;
    final distanceKm = _asDouble(data['distanceKm']) ?? 0;
    final durationMinutes = _asDouble(data['durationMinutes']) ?? 0;
    return baseFare + (costPerKm * distanceKm) + (costPerMin * durationMinutes);
  }

  /// Get a single ride by ID
  Future<RideModel?> getRide(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return RideModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching ride: $e');
      return null;
    }
  }

  /// Create a new ride
  Future<String?> createRide(RideModel ride) async {
    try {
      final docRef = await _firestore.collection('rides').add(ride.toJson());
      await fetchActiveRides();
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating ride: $e');
      return null;
    }
  }

  /// Create a new ride with pricing from region
  /// This is the preferred method for creating rides as it includes all pricing information
  Future<String?> createRideWithRegionPricing({
    required RegionModel region,
    required String pickupLocation,
    required String dropoffLocation,
    required double distanceKm,
    required int durationMinutes,
    RideType rideType = RideType.standard,
    String vehicleInfo = '',
    String fleetClass = 'Standard',
  }) async {
    try {
      final ride = PricingService.createRideWithPricing(
        region: region,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        rideType: rideType,
        vehicleInfo: vehicleInfo,
        fleetClass: fleetClass,
      );

      // Log pricing details for debugging
      PricingService.logPricingDetails(
        region: region,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        rideType: rideType,
      );

      final docRef = await _firestore.collection('rides').add(ride.toJson());
      await fetchActiveRides();
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating ride with region pricing: $e');
      return null;
    }
  }

  /// Create ride and notify nearby online drivers through Firestore dispatch docs.
  /// Driver apps can listen to `ride_dispatch_requests` to show ride confirmation popups.
  Future<RideCreationResult?> createRideAndDispatchToNearbyDrivers({
    required RegionModel region,
    required String pickupLocation,
    required String dropoffLocation,
    required double distanceKm,
    required int durationMinutes,
    required double pickupLatitude,
    required double pickupLongitude,
    RideType rideType = RideType.standard,
    String vehicleInfo = '',
    String fleetClass = 'Standard',
    double dispatchRadiusKm = 5.0,
    int requestTimeoutSeconds = 45,
  }) async {
    try {
      final ride = PricingService.createRideWithPricing(
        region: region,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        distanceKm: distanceKm,
        durationMinutes: durationMinutes,
        rideType: rideType,
        vehicleInfo: vehicleInfo,
        fleetClass: fleetClass,
      );

      final rideData = ride.toJson()
        ..addAll({
          'pickupLatitude': pickupLatitude,
          'pickupLongitude': pickupLongitude,
          'dispatchRadiusKm': dispatchRadiusKm,
          'dispatchStatus': 'searching',
        });

      final rideRef = await _firestore.collection('rides').add(rideData);

      final driversSnapshot = await _firestore
          .collection('drivers')
          .where('isOnline', isEqualTo: true)
          .get();

      final now = DateTime.now();
      final expiresAt = Timestamp.fromDate(
        now.add(Duration(seconds: requestTimeoutSeconds)),
      );
      final batch = _firestore.batch();
      var dispatchedCount = 0;

      for (final doc in driversSnapshot.docs) {
        final driverData = doc.data();
        if (driverData['isOnBreak'] == true) {
          continue;
        }

        final driverPoint = _extractDriverGeoPoint(driverData);
        if (driverPoint == null) {
          continue;
        }

        final distanceToPickupKm = _haversineKm(
          pickupLatitude,
          pickupLongitude,
          driverPoint.latitude,
          driverPoint.longitude,
        );
        if (distanceToPickupKm > dispatchRadiusKm) {
          continue;
        }

        final dispatchRef =
            _firestore.collection('ride_dispatch_requests').doc();
        batch.set(dispatchRef, {
          'rideId': rideRef.id,
          'driverId': doc.id,
          'status': 'pending',
          'createdAt': Timestamp.fromDate(now),
          'expiresAt': expiresAt,
          'pickupLocation': pickupLocation,
          'dropoffLocation': dropoffLocation,
          'pickupLatitude': pickupLatitude,
          'pickupLongitude': pickupLongitude,
          'distanceToPickupKm':
              double.parse(distanceToPickupKm.toStringAsFixed(3)),
          'regionId': region.id,
          'regionName': region.name,
          'rideType': rideType.name,
          'estimatedFare': ride.estimatedFare,
          'vehicleInfo': vehicleInfo,
          'fleetClass': fleetClass,
        });
        dispatchedCount++;
      }

      if (dispatchedCount > 0) {
        await batch.commit();
      }

      await rideRef.update({
        'nearbyDriverCount': dispatchedCount,
        'dispatchStatus': dispatchedCount > 0 ? 'notified' : 'no_drivers_found',
      });

      await fetchActiveRides();
      return RideCreationResult(
        rideId: rideRef.id,
        nearbyDriversNotified: dispatchedCount,
      );
    } catch (e) {
      debugPrint('Error creating ride and dispatching nearby drivers: $e');
      return null;
    }
  }

  GeoPoint? _extractDriverGeoPoint(Map<String, dynamic> data) {
    final locationCandidates = [
      data['currentLocation'],
      data['locationGeoPoint'],
      data['geoPoint'],
      data['coordinates'],
    ];
    for (final candidate in locationCandidates) {
      if (candidate is GeoPoint) {
        return candidate;
      }
      if (candidate is Map<String, dynamic>) {
        final lat = _asDouble(candidate['lat'] ?? candidate['latitude']);
        final lng = _asDouble(candidate['lng'] ?? candidate['longitude']);
        if (lat != null && lng != null) {
          return GeoPoint(lat, lng);
        }
      }
    }

    final lat = _asDouble(data['lat'] ?? data['latitude']);
    final lng = _asDouble(data['lng'] ?? data['longitude']);
    if (lat != null && lng != null) {
      return GeoPoint(lat, lng);
    }
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degree) => degree * (3.141592653589793 / 180.0);

  /// Get rides by region
  Future<List<RideModel>> getRidesByRegion(String regionId) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('regionId', isEqualTo: regionId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => RideModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching rides by region: $e');
      return [];
    }
  }

  /// Update ride status
  Future<bool> updateRideStatus(String rideId, RideStatus status) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
      await fetchActiveRides();
      return true;
    } catch (e) {
      debugPrint('Error updating ride status: $e');
      return false;
    }
  }

  /// Assign driver to ride
  Future<bool> assignDriver(String rideId, String driverId, String driverName,
      String? photoUrl, String vehicleInfo) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverId': driverId,
        'driverName': driverName,
        'driverPhotoUrl': photoUrl,
        'vehicleInfo': vehicleInfo,
        'status': RideStatus.enRoute.name,
        'updatedAt': Timestamp.now(),
      });
      await fetchActiveRides();
      return true;
    } catch (e) {
      debugPrint('Error assigning driver: $e');
      return false;
    }
  }

  /// Cancel ride
  Future<bool> cancelRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.cancelled.name,
        'updatedAt': Timestamp.now(),
      });
      await fetchActiveRides();
      return true;
    } catch (e) {
      debugPrint('Error cancelling ride: $e');
      return false;
    }
  }

  /// Complete ride with final fare
  Future<bool> completeRide(String rideId, double fare) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.completed.name,
        'fare': fare,
        'updatedAt': Timestamp.now(),
      });
      await fetchActiveRides();
      return true;
    } catch (e) {
      debugPrint('Error completing ride: $e');
      return false;
    }
  }

  /// Complete ride with actual distance and time, recalculating the fare
  Future<bool> completeRideWithActualMetrics({
    required String rideId,
    required RegionModel region,
    required double actualDistanceKm,
    required int actualDurationMinutes,
    RideType rideType = RideType.standard,
  }) async {
    try {
      // Calculate final fare with actual metrics
      final finalFare = PricingService.calculateFare(
        region: region,
        distanceKm: actualDistanceKm,
        durationMinutes: actualDurationMinutes,
        rideType: rideType,
      );

      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.completed.name,
        'fare': finalFare,
        'distanceKm': actualDistanceKm,
        'durationMinutes': actualDurationMinutes,
        'updatedAt': Timestamp.now(),
      });

      debugPrint(
          'Ride $rideId completed with fare: \$${finalFare.toStringAsFixed(2)}');
      await fetchActiveRides();
      return true;
    } catch (e) {
      debugPrint('Error completing ride with actual metrics: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
