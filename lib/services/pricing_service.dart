import 'package:flutter/foundation.dart';
import 'package:roadygo_admin/models/region_model.dart';
import 'package:roadygo_admin/models/ride_model.dart';

/// Service for calculating ride fares based on region pricing
class PricingService {
  /// Calculate estimated fare based on region pricing
  /// 
  /// Parameters:
  /// - [region]: The region containing pricing configuration
  /// - [distanceKm]: Estimated distance in kilometers
  /// - [durationMinutes]: Estimated duration in minutes
  /// - [rideType]: Whether it's a standard or corporate ride
  /// 
  /// Returns the calculated fare with float/surge percentage applied
  static double calculateFare({
    required RegionModel region,
    required double distanceKm,
    required int durationMinutes,
    RideType rideType = RideType.standard,
  }) {
    double baseFare;
    double costPerKm;
    double costPerMin;
    double floatPercent;
    
    if (rideType == RideType.corporate) {
      baseFare = region.corpCostOfRide;
      costPerKm = region.corpCostPerKm;
      costPerMin = region.corpCostPerMin;
      floatPercent = region.corpFloatPercent;
    } else {
      baseFare = region.costOfRide;
      costPerKm = region.costPerKm;
      costPerMin = region.costPerMin;
      floatPercent = region.floatPercent;
    }
    
    // Calculate base ride cost
    double rideCost = baseFare + (distanceKm * costPerKm) + (durationMinutes * costPerMin);
    
    // Apply float percentage (surge pricing)
    double floatAmount = rideCost * (floatPercent / 100);
    double totalFare = rideCost + floatAmount;
    
    // Round to 2 decimal places
    return double.parse(totalFare.toStringAsFixed(2));
  }
  
  /// Get pricing breakdown for display to drivers/riders
  static Map<String, dynamic> getPricingBreakdown({
    required RegionModel region,
    required double distanceKm,
    required int durationMinutes,
    RideType rideType = RideType.standard,
  }) {
    double baseFare;
    double costPerKm;
    double costPerMin;
    double floatPercent;
    
    if (rideType == RideType.corporate) {
      baseFare = region.corpCostOfRide;
      costPerKm = region.corpCostPerKm;
      costPerMin = region.corpCostPerMin;
      floatPercent = region.corpFloatPercent;
    } else {
      baseFare = region.costOfRide;
      costPerKm = region.costPerKm;
      costPerMin = region.costPerMin;
      floatPercent = region.floatPercent;
    }
    
    double distanceCost = distanceKm * costPerKm;
    double timeCost = durationMinutes * costPerMin;
    double subtotal = baseFare + distanceCost + timeCost;
    double floatAmount = subtotal * (floatPercent / 100);
    double totalFare = subtotal + floatAmount;
    
    return {
      'baseFare': double.parse(baseFare.toStringAsFixed(2)),
      'costPerKm': costPerKm,
      'costPerMin': costPerMin,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'distanceCost': double.parse(distanceCost.toStringAsFixed(2)),
      'timeCost': double.parse(timeCost.toStringAsFixed(2)),
      'subtotal': double.parse(subtotal.toStringAsFixed(2)),
      'floatPercent': floatPercent,
      'floatAmount': double.parse(floatAmount.toStringAsFixed(2)),
      'totalFare': double.parse(totalFare.toStringAsFixed(2)),
      'regionName': region.name,
      'regionId': region.id,
      'rideType': rideType.name,
    };
  }
  
  /// Create a ride model with pricing from region
  static RideModel createRideWithPricing({
    required RegionModel region,
    required String pickupLocation,
    required String dropoffLocation,
    required double distanceKm,
    required int durationMinutes,
    RideType rideType = RideType.standard,
    String vehicleInfo = '',
    String fleetClass = 'Standard',
  }) {
    double baseFare;
    double costPerKm;
    double costPerMin;
    double floatPercent;
    
    if (rideType == RideType.corporate) {
      baseFare = region.corpCostOfRide;
      costPerKm = region.corpCostPerKm;
      costPerMin = region.corpCostPerMin;
      floatPercent = region.corpFloatPercent;
    } else {
      baseFare = region.costOfRide;
      costPerKm = region.costPerKm;
      costPerMin = region.costPerMin;
      floatPercent = region.floatPercent;
    }
    
    final estimatedFare = calculateFare(
      region: region,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      rideType: rideType,
    );
    
    final now = DateTime.now();
    
    return RideModel(
      id: '',
      vehicleInfo: vehicleInfo,
      fleetClass: fleetClass,
      status: RideStatus.pending,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      createdAt: now,
      updatedAt: now,
      regionId: region.id,
      regionName: region.name,
      rideType: rideType,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      baseFare: baseFare,
      costPerKm: costPerKm,
      costPerMin: costPerMin,
      floatPercent: floatPercent,
      estimatedFare: estimatedFare,
    );
  }
  
  /// Log pricing details for debugging
  static void logPricingDetails({
    required RegionModel region,
    required double distanceKm,
    required int durationMinutes,
    RideType rideType = RideType.standard,
  }) {
    final breakdown = getPricingBreakdown(
      region: region,
      distanceKm: distanceKm,
      durationMinutes: durationMinutes,
      rideType: rideType,
    );
    
    debugPrint('=== Pricing Breakdown ===');
    debugPrint('Region: ${breakdown['regionName']}');
    debugPrint('Ride Type: ${breakdown['rideType']}');
    debugPrint('Base Fare: \$${breakdown['baseFare']}');
    debugPrint('Distance: ${breakdown['distanceKm']} km @ \$${breakdown['costPerKm']}/km = \$${breakdown['distanceCost']}');
    debugPrint('Time: ${breakdown['durationMinutes']} min @ \$${breakdown['costPerMin']}/min = \$${breakdown['timeCost']}');
    debugPrint('Subtotal: \$${breakdown['subtotal']}');
    debugPrint('Float (${breakdown['floatPercent']}%): \$${breakdown['floatAmount']}');
    debugPrint('Total Fare: \$${breakdown['totalFare']}');
    debugPrint('========================');
  }
}
