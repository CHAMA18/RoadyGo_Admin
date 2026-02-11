import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/models/ride_model.dart';
import 'package:roadygo_admin/pages/admin_dashboard_page.dart';
import 'package:roadygo_admin/services/ride_service.dart';

const String _fontFamily = 'Satoshi';

/// Rides Section Widget
class RidesSection extends StatefulWidget {
  final bool isDark;

  const RidesSection({super.key, required this.isDark});

  @override
  State<RidesSection> createState() => _RidesSectionState();
}

class _RidesSectionState extends State<RidesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideService>().fetchActiveRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Rides Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Active Rides',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ActivePulse(),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DashboardColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'VIEW MAP',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: DashboardColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Ride Cards from Firestore
        Consumer<RideService>(
          builder: (context, rideService, _) {
            if (rideService.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (rideService.error != null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Failed to load rides',
                      style: TextStyle(
                        color: widget.isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => rideService.fetchActiveRides(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final rides = rideService.activeRides;

            if (rides.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_car_outlined,
                        size: 48,
                        color: widget.isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active rides',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16,
                          color: widget.isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: rides.map((ride) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RideCard(ride: ride, isDark: widget.isDark),
                )).toList(),
              ),
            );
          },
        ),

        // Create New Ride Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Create new ride
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create New Ride'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isDark ? Colors.white : const Color(0xFF0F172A),
                foregroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Ride Card Widget
class RideCard extends StatelessWidget {
  final RideModel ride;
  final bool isDark;

  const RideCard({
    super.key,
    required this.ride,
    required this.isDark,
  });

  Color get _statusColor {
    switch (ride.status) {
      case RideStatus.enRoute:
        return DashboardColors.primary;
      case RideStatus.arrived:
        return Colors.blue;
      case RideStatus.pending:
        return Colors.grey;
      case RideStatus.completed:
        return Colors.green;
      case RideStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = ride.isPending;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPending 
            ? (isDark ? DashboardColors.surfaceDark.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.6))
            : (isDark ? DashboardColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPending 
              ? (isDark ? DashboardColors.borderDark : const Color(0xFFE2E8F0))
              : (isDark ? DashboardColors.borderDark : const Color(0xFFF1F5F9)),
          style: isPending ? BorderStyle.solid : BorderStyle.solid,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: isPending ? null : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Driver Image
              _buildDriverImage(),
              const SizedBox(width: 16),
              
              // Driver Info and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPending ? 'Assigning Driver...' : (ride.driverName ?? 'Unknown Driver'),
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                                  color: isPending 
                                      ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8))
                                      : (isDark ? DashboardColors.textMainDark : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPending ? 'Fleet Class: ${ride.fleetClass}' : ride.vehicleInfo,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 12,
                                  color: isDark ? DashboardColors.textMutedDark : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Route Timeline
                    _buildRouteTimeline(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverImage() {
    if (ride.isPending) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.person_outline,
          size: 32,
          color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8),
        ),
      );
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _statusColor.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ride.driverPhotoUrl != null && ride.driverPhotoUrl!.isNotEmpty
                ? Image.network(
                    ride.driverPhotoUrl!,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.person, color: _statusColor),
                    ),
                  )
                : Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.person, color: _statusColor),
                  ),
          ),
        ),
        if (ride.isDriverVerified && !ride.isPending)
          Positioned(
            bottom: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark ? DashboardColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.verified,
                size: 16,
                color: _statusColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    Color borderColor;

    if (ride.isPending) {
      bgColor = isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9);
      textColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);
      borderColor = Colors.transparent;
    } else if (ride.status == RideStatus.enRoute) {
      bgColor = DashboardColors.primary.withValues(alpha: 0.15);
      textColor = isDark ? DashboardColors.primary : const Color(0xFF0F172A);
      borderColor = DashboardColors.primary.withValues(alpha: 0.2);
    } else {
      bgColor = Colors.blue.withValues(alpha: 0.1);
      textColor = Colors.blue.shade600;
      borderColor = Colors.blue.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        ride.statusText.toUpperCase(),
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildRouteTimeline() {
    final isPending = ride.isPending;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dots and line
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPending 
                        ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0))
                        : (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1)),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 24,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: isPending 
                    ? (isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9))
                    : (isDark ? const Color(0xFF374151) : const Color(0xFFF1F5F9)),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPending 
                      ? null 
                      : _statusColor,
                  border: isPending 
                      ? Border.all(
                          color: isDark ? const Color(0xFF4B5563) : const Color(0xFFE2E8F0),
                          width: 2,
                        )
                      : null,
                  boxShadow: isPending ? null : [
                    BoxShadow(
                      color: _statusColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Route text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isPending)
                Text(
                  'PICKUP',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8),
                  ),
                ),
              Text(
                isPending ? 'Pickup: ${ride.pickupLocation}' : ride.pickupLocation,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                  color: isPending 
                      ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8))
                      : (isDark ? DashboardColors.textMutedDark : const Color(0xFF64748B)),
                ),
              ),
              const SizedBox(height: 12),
              if (!isPending)
                Text(
                  'DROPOFF',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8),
                  ),
                ),
              Text(
                isPending ? 'Dest: ${ride.dropoffLocation}' : ride.dropoffLocation,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                  color: isPending 
                      ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8))
                      : (isDark ? DashboardColors.textMainDark : const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Active Pulse Indicator
class ActivePulse extends StatefulWidget {
  const ActivePulse({super.key});

  @override
  State<ActivePulse> createState() => _ActivePulseState();
}

class _ActivePulseState extends State<ActivePulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DashboardColors.primary.withValues(alpha: _animation.value),
            boxShadow: [
              BoxShadow(
                color: DashboardColors.primary.withValues(alpha: _animation.value * 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
