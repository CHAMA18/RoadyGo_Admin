import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/region_model.dart';

/// Service for managing region data in Firestore
class RegionService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<RegionModel> _regions = [];
  bool _isLoading = false;
  String? _error;

  List<RegionModel> get regions => _regions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all regions
  Future<void> fetchRegions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('regions')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .limit(50)
          .get();

      _regions = snapshot.docs
          .map((doc) => RegionModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch regions: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching regions: $e');
    }
  }

  /// Get a single region by ID
  Future<RegionModel?> getRegion(String regionId) async {
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
  Future<bool> createRegion(RegionModel region) async {
    try {
      await _firestore.collection('regions').add(region.toJson());
      await fetchRegions();
      return true;
    } catch (e) {
      debugPrint('Error creating region: $e');
      return false;
    }
  }

  /// Update region
  Future<bool> updateRegion(RegionModel region) async {
    try {
      await _firestore.collection('regions').doc(region.id).update(region.toJson());
      await fetchRegions();
      return true;
    } catch (e) {
      debugPrint('Error updating region: $e');
      return false;
    }
  }

  /// Delete (deactivate) a region
  Future<bool> deleteRegion(String regionId) async {
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
}
