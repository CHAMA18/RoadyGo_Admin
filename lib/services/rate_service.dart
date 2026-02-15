import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/rate_model.dart';

/// Service for managing rate data in Firestore
class RateService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'rates';

  List<RateModel> _rates = [];
  bool _isLoading = false;
  String? _error;

  List<RateModel> get rates => _rates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Stream of all rates
  Stream<List<RateModel>> getRatesStream() {
    return _firestore
        .collection(_collection)
        .orderBy('fleetClass')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RateModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  /// Fetch all rates
  Future<void> fetchRates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('fleetClass')
          .get();

      _rates = snapshot.docs
          .map((doc) => RateModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching rates: $e');
      _error = 'Failed to load rates';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get a single rate by ID
  Future<RateModel?> getRateById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return RateModel.fromJson(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error getting rate: $e');
    }
    return null;
  }

  /// Get rate by fleet class
  Future<RateModel?> getRateByFleetClass(String fleetClass) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('fleetClass', isEqualTo: fleetClass)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return RateModel.fromJson(snapshot.docs.first.data(), snapshot.docs.first.id);
      }
    } catch (e) {
      debugPrint('Error getting rate by fleet class: $e');
    }
    return null;
  }

  /// Create a new rate
  Future<String?> createRate(RateModel rate) async {
    try {
      final docRef = await _firestore.collection(_collection).add(rate.toJson());
      await fetchRates();
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating rate: $e');
      _error = 'Failed to create rate';
      notifyListeners();
      return null;
    }
  }

  /// Update an existing rate
  Future<bool> updateRate(RateModel rate) async {
    try {
      await _firestore.collection(_collection).doc(rate.id).update(rate.toJson());
      await fetchRates();
      return true;
    } catch (e) {
      debugPrint('Error updating rate: $e');
      _error = 'Failed to update rate';
      notifyListeners();
      return false;
    }
  }

  /// Delete a rate
  Future<bool> deleteRate(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      await fetchRates();
      return true;
    } catch (e) {
      debugPrint('Error deleting rate: $e');
      _error = 'Failed to delete rate';
      notifyListeners();
      return false;
    }
  }
}
