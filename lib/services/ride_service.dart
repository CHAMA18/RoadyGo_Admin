import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/ride_model.dart';

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

  /// Fetch active rides (pending, enRoute, arrived)
  Future<void> fetchActiveRides() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('status', whereIn: ['pending', 'enRoute', 'arrived'])
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

  /// Stream of active rides
  Stream<List<RideModel>> watchActiveRides() {
    return _firestore
        .collection('rides')
        .where('status', whereIn: ['pending', 'enRoute', 'arrived'])
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RideModel.fromJson(doc.data(), doc.id))
            .toList());
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
  Future<bool> assignDriver(String rideId, String driverId, String driverName, String? photoUrl, String vehicleInfo) async {
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

  /// Complete ride
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
