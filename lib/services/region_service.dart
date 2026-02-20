import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/region_model.dart';

/// Service for managing region data in Firestore
class RegionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<RegionModel> _regions = [];
  bool _isLoading = false;
  String? _error;

  List<RegionModel> get regions => _regions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool _requireAuthOrSetError() {
    if (_auth.currentUser != null) return true;
    _error = 'You must be signed in before loading regions.';
    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Fetch all regions (both active and inactive)
  Future<void> fetchRegions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (!_requireAuthOrSetError()) return;

    try {
      final snapshot = await _firestore
          .collection('regions')
          .orderBy('name')
          .get();

      _regions = snapshot.docs
          .map((doc) => RegionModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      final message = e.toString().contains('permission-denied')
          ? 'Missing Firestore permissions. Sign in first, then deploy firestore.rules if needed.'
          : '$e';
      _error = 'Failed to fetch regions: $message';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching regions: $e');
    }
  }

  /// Get only active regions
  List<RegionModel> get activeRegions =>
      _regions.where((r) => r.isActive).toList();

  /// Get computed statistics
  int get totalConfiguredRegions => _regions.length;
  int get totalActiveRegions => _regions.where((r) => r.isActive).length;
  int get totalDriversAcrossRegions =>
      _regions.fold<int>(0, (total, r) => total + r.activeDrivers);
  int get totalRidesAcrossRegions =>
      _regions.fold<int>(0, (total, r) => total + r.totalRides);

  /// Get a single region by ID
  Future<RegionModel?> getRegion(String regionId) async {
    if (_auth.currentUser == null) return null;
    try {
      final doc = await _firestore.collection('regions').doc(regionId).get();
      if (doc.exists) {
        return RegionModel.fromJson(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching region: $e');
      return null;
    }
  }

  /// Create a new region
  Future<String?> createRegion(RegionModel region) async {
    if (_auth.currentUser == null) return null;
    _error = null;
    try {
      final docRef =
          await _firestore.collection('regions').add(region.toJson());
      await fetchRegions();
      return docRef.id;
    } on FirebaseException catch (e) {
      _error = 'Failed to create region (${e.code}): ${e.message ?? 'Unknown error'}';
      notifyListeners();
      debugPrint('Error creating region: ${e.code} ${e.message}');
      return null;
    } catch (e) {
      _error = 'Failed to create region: $e';
      notifyListeners();
      debugPrint('Error creating region: $e');
      return null;
    }
  }

  /// Update region
  Future<bool> updateRegion(RegionModel region) async {
    if (_auth.currentUser == null) return false;
    _error = null;
    try {
      await _firestore
          .collection('regions')
          .doc(region.id)
          .update(region.toJson());
      await fetchRegions();
      return true;
    } on FirebaseException catch (e) {
      _error = 'Failed to update region (${e.code}): ${e.message ?? 'Unknown error'}';
      notifyListeners();
      debugPrint('Error updating region: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      _error = 'Failed to update region: $e';
      notifyListeners();
      debugPrint('Error updating region: $e');
      return false;
    }
  }

  /// Delete (deactivate) a region
  Future<bool> deleteRegion(String regionId) async {
    if (_auth.currentUser == null) return false;
    try {
      await _firestore.collection('regions').doc(regionId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
      await fetchRegions();
      return true;
    } catch (e) {
      debugPrint('Error deleting region: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get region pricing summary for display
  Map<String, dynamic> getRegionPricingSummary(RegionModel region,
      {bool isCorporate = false}) {
    if (isCorporate) {
      return {
        'baseFare': region.corpCostOfRide,
        'costPerKm': region.corpCostPerKm,
        'costPerMin': region.corpCostPerMin,
        'floatPercent': region.corpFloatPercent,
        'type': 'Corporate',
      };
    }
    return {
      'baseFare': region.costOfRide,
      'costPerKm': region.costPerKm,
      'costPerMin': region.costPerMin,
      'floatPercent': region.floatPercent,
      'type': 'Standard',
    };
  }
}
