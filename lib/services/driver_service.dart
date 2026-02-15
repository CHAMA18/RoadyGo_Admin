import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/models/activity_model.dart';

/// Service for managing driver data in Firestore
class DriverService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<DriverModel> _drivers = [];
  List<DriverModel> _onlineDrivers = [];
  int _activeDriverCount = 0;
  bool _isLoading = false;
  String? _error;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _driversSub;

  List<DriverModel> get drivers => _drivers;
  List<DriverModel> get onlineDrivers => _onlineDrivers;
  int get activeDriverCount => _activeDriverCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all drivers
  Future<void> fetchDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('drivers')
          .orderBy('name')
          .limit(100)
          .get();

      _drivers = snapshot.docs
          .map((doc) => DriverModel.fromJson(doc.data(), doc.id))
          .toList();

      _onlineDrivers = _drivers.where((d) => d.isOnline || d.isOnBreak).toList();
      _activeDriverCount = _drivers.where((d) => d.isOnline).length;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch drivers: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching drivers: $e');
    }
  }

  /// Live stream of drivers to keep the dashboard in sync with Firestore
  Future<void> fetchOnlineDrivers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _driversSub?.cancel();

    _driversSub = _firestore
        .collection('drivers')
        .orderBy('name')
        .limit(100)
        .snapshots()
        .listen(
      (snapshot) {
        final allDrivers = snapshot.docs
            .map((doc) => DriverModel.fromJson(doc.data(), doc.id))
            .toList();

        _drivers = allDrivers;
        _onlineDrivers =
            allDrivers.where((d) => d.isOnline || d.isOnBreak).toList();
        _activeDriverCount = allDrivers.where((d) => d.isOnline).length;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to fetch online drivers: $e';
        _isLoading = false;
        notifyListeners();
        debugPrint('Error streaming online drivers: $e');
      },
    );
  }

  /// Stream of active driver count
  Stream<int> watchActiveDriverCount() {
    return _firestore
        .collection('drivers')
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get a single driver by ID
  Future<DriverModel?> getDriver(String driverId) async {
    try {
      final doc = await _firestore.collection('drivers').doc(driverId).get();
      if (doc.exists) {
        return DriverModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching driver: $e');
      return null;
    }
  }

  /// Get driver activities
  Future<List<ActivityModel>> getDriverActivities(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection('activities')
          .where('driverId', isEqualTo: driverId)
          .orderBy('activityDate', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ActivityModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching driver activities: $e');
      return [];
    }
  }

  /// Create a new driver
  Future<bool> createDriver(DriverModel driver) async {
    try {
      await _firestore.collection('drivers').add(driver.toJson());
      await fetchDrivers();
      return true;
    } catch (e) {
      debugPrint('Error creating driver: $e');
      return false;
    }
  }

  /// Update driver
  Future<bool> updateDriver(DriverModel driver) async {
    try {
      await _firestore.collection('drivers').doc(driver.id).update(driver.toJson());
      await fetchDrivers();
      return true;
    } catch (e) {
      debugPrint('Error updating driver: $e');
      return false;
    }
  }

  /// Update driver status (online/offline/break)
  Future<bool> updateDriverStatus(String driverId, {bool? isOnline, bool? isOnBreak}) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (isOnline != null) updates['isOnline'] = isOnline;
      if (isOnBreak != null) updates['isOnBreak'] = isOnBreak;

      await _firestore.collection('drivers').doc(driverId).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating driver status: $e');
      return false;
    }
  }

  /// Add funds to driver float balance
  Future<bool> addFunds(String driverId, double amount) async {
    try {
      final driver = await getDriver(driverId);
      if (driver == null) return false;

      await _firestore.collection('drivers').doc(driverId).update({
        'floatBalance': driver.floatBalance + amount,
        'updatedAt': Timestamp.now(),
      });
      return true;
    } catch (e) {
      debugPrint('Error adding funds: $e');
      return false;
    }
  }

  /// Delete a driver
  Future<bool> deleteDriver(String driverId) async {
    try {
      await _firestore.collection('drivers').doc(driverId).delete();
      await fetchDrivers();
      return true;
    } catch (e) {
      debugPrint('Error deleting driver: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _driversSub?.cancel();
    super.dispose();
  }
}
