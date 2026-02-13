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

  /// Fetch all regions (both active and inactive)
  Future<void> fetchRegions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('regions')
          .orderBy('name')
          .limit(100)
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
  
  /// Get only active regions
  List<RegionModel> get activeRegions => _regions.where((r) => r.isActive).toList();
  
  /// Get computed statistics
  int get totalConfiguredRegions => _regions.length;
  int get totalActiveRegions => _regions.where((r) => r.isActive).length;
  int get totalDriversAcrossRegions => _regions.fold<int>(0, (sum, r) => sum + r.activeDrivers);
  int get totalRidesAcrossRegions => _regions.fold<int>(0, (sum, r) => sum + r.totalRides);

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

  /// Initialize default regions with pricing if none exist
  /// This ensures the regions collection has at least one region configured
  Future<void> initializeDefaultRegions() async {
    try {
      final snapshot = await _firestore.collection('regions').limit(1).get();
      if (snapshot.docs.isEmpty) {
        debugPrint('No regions found, creating default regions with pricing...');
        final now = DateTime.now();
        
        // Default regions with pricing matching the Edit Region page screenshot
        final defaultRegions = [
          RegionModel(
            id: '',
            name: 'Airport Zone',
            description: 'Airport pickup and dropoff zone with standard pricing',
            activeDrivers: 0,
            totalRides: 0,
            isActive: true,
            // Standard Pricing (from screenshot)
            costOfRide: 5.00,
            costPerKm: 1.20,
            costPerMin: 0.30,
            floatPercent: 15.0,
            // Corporate Pricing (from screenshot)
            corpCostOfRide: 6.50,
            corpCostPerKm: 1.45,
            corpCostPerMin: 0.35,
            corpFloatPercent: 20.0,
            createdAt: now,
            updatedAt: now,
          ),
          RegionModel(
            id: '',
            name: 'Downtown',
            description: 'Central downtown area with city pricing',
            activeDrivers: 0,
            totalRides: 0,
            isActive: true,
            costOfRide: 4.50,
            costPerKm: 1.00,
            costPerMin: 0.25,
            floatPercent: 10.0,
            corpCostOfRide: 5.50,
            corpCostPerKm: 1.25,
            corpCostPerMin: 0.30,
            corpFloatPercent: 15.0,
            createdAt: now,
            updatedAt: now,
          ),
          RegionModel(
            id: '',
            name: 'Suburban',
            description: 'Suburban and outskirt areas',
            activeDrivers: 0,
            totalRides: 0,
            isActive: true,
            costOfRide: 5.50,
            costPerKm: 1.50,
            costPerMin: 0.35,
            floatPercent: 12.0,
            corpCostOfRide: 7.00,
            corpCostPerKm: 1.75,
            corpCostPerMin: 0.40,
            corpFloatPercent: 18.0,
            createdAt: now,
            updatedAt: now,
          ),
        ];

        for (final region in defaultRegions) {
          await _firestore.collection('regions').add(region.toJson());
        }
        
        debugPrint('Default regions created successfully');
        await fetchRegions();
      }
    } catch (e) {
      debugPrint('Error initializing default regions: $e');
    }
  }

  /// Get region pricing summary for display
  Map<String, dynamic> getRegionPricingSummary(RegionModel region, {bool isCorporate = false}) {
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
