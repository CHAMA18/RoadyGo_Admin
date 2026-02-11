import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/schedule_model.dart';

/// Service for managing schedule data in Firestore
class ScheduleService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ScheduleModel> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<ScheduleModel> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all schedules
  Future<void> fetchSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('isActive', isEqualTo: true)
          .orderBy('startTime')
          .limit(100)
          .get();

      _schedules = snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch schedules: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching schedules: $e');
    }
  }

  /// Fetch schedules for a specific driver
  Future<List<ScheduleModel>> getDriverSchedules(String driverId) async {
    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('driverId', isEqualTo: driverId)
          .where('isActive', isEqualTo: true)
          .orderBy('startTime')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching driver schedules: $e');
      return [];
    }
  }

  /// Fetch today's schedules
  Future<void> fetchTodaySchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('schedules')
          .where('isActive', isEqualTo: true)
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('startTime', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('startTime')
          .limit(50)
          .get();

      _schedules = snapshot.docs
          .map((doc) => ScheduleModel.fromJson(doc.data(), doc.id))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to fetch today schedules: $e';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error fetching today schedules: $e');
    }
  }

  /// Create a new schedule
  Future<bool> createSchedule(ScheduleModel schedule) async {
    try {
      await _firestore.collection('schedules').add(schedule.toJson());
      await fetchSchedules();
      return true;
    } catch (e) {
      debugPrint('Error creating schedule: $e');
      return false;
    }
  }

  /// Update schedule
  Future<bool> updateSchedule(ScheduleModel schedule) async {
    try {
      await _firestore.collection('schedules').doc(schedule.id).update(schedule.toJson());
      await fetchSchedules();
      return true;
    } catch (e) {
      debugPrint('Error updating schedule: $e');
      return false;
    }
  }

  /// Delete (deactivate) a schedule
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection('schedules').doc(scheduleId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
      await fetchSchedules();
      return true;
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
