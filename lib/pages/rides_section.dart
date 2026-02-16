import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/region_model.dart';
import 'package:roadygo_admin/models/ride_model.dart';
import 'package:roadygo_admin/pages/admin_dashboard_page.dart';
import 'package:roadygo_admin/services/pricing_service.dart';
import 'package:roadygo_admin/services/region_service.dart';
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
  Future<void> _openCreateRideFlow() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => _CreateRidePage(isDark: widget.isDark),
      ),
    );
  }

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
                    context.tr('Active Rides'),
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark
                          ? DashboardColors.textMainDark
                          : DashboardColors.textMainLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ActivePulse(),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: DashboardColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.tr('VIEW MAP'),
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
                      context.tr('Failed to load rides'),
                      style: TextStyle(
                        color: widget.isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => rideService.fetchActiveRides(),
                      child: Text(context.tr('Retry')),
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
                        color: widget.isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('No active rides'),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16,
                          color: widget.isDark
                              ? DashboardColors.textMutedDark
                              : DashboardColors.textMutedLight,
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
                children: rides
                    .map((ride) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RideCard(ride: ride, isDark: widget.isDark),
                        ))
                    .toList(),
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
              onPressed: _openCreateRideFlow,
              icon: const Icon(Icons.add, size: 20),
              label: Text(context.tr('Create New Ride')),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    widget.isDark ? Colors.white : const Color(0xFF0F172A),
                foregroundColor:
                    widget.isDark ? const Color(0xFF0F172A) : Colors.white,
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

class _CreateRidePage extends StatefulWidget {
  final bool isDark;

  const _CreateRidePage({required this.isDark});

  @override
  State<_CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<_CreateRidePage> {
  final _formKey = GlobalKey<FormState>();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _pickupLatController = TextEditingController();
  final _pickupLngController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _fleetController = TextEditingController(text: 'Standard');
  bool _isSubmitting = false;
  RideType _rideType = RideType.standard;
  String? _selectedRegionId;
  double? _estimatedFare;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final regionService = context.read<RegionService>();
      if (regionService.regions.isEmpty) {
        regionService.fetchRegions();
      }
    });
    _distanceController.addListener(_recalculateEstimatedFare);
    _durationController.addListener(_recalculateEstimatedFare);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _distanceController.dispose();
    _durationController.dispose();
    _pickupLatController.dispose();
    _pickupLngController.dispose();
    _vehicleController.dispose();
    _fleetController.dispose();
    super.dispose();
  }

  RegionModel? _findRegion(List<RegionModel> regions) {
    if (_selectedRegionId == null) return null;
    for (final region in regions) {
      if (region.id == _selectedRegionId) return region;
    }
    return null;
  }

  void _recalculateEstimatedFare() {
    final regionService = context.read<RegionService>();
    final region = _findRegion(regionService.activeRegions);
    final distance = double.tryParse(_distanceController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());

    if (region == null ||
        distance == null ||
        duration == null ||
        distance <= 0 ||
        duration <= 0) {
      if (_estimatedFare != null) {
        setState(() => _estimatedFare = null);
      }
      return;
    }

    final fare = PricingService.calculateFare(
      region: region,
      distanceKm: distance,
      durationMinutes: duration,
      rideType: _rideType,
    );
    if (_estimatedFare != fare) {
      setState(() => _estimatedFare = fare);
    }
  }

  Future<void> _pickLocation({required bool isPickup}) async {
    final picked = await Navigator.of(context).push<_PickedPlace>(
      MaterialPageRoute(
        builder: (context) => _PlacePickerPage(
          isDark: widget.isDark,
          title: isPickup ? 'Select Pickup' : 'Select Dropoff',
        ),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() {
      if (isPickup) {
        _pickupController.text = picked.name;
        _pickupLatController.text = picked.latitude.toStringAsFixed(6);
        _pickupLngController.text = picked.longitude.toStringAsFixed(6);
      } else {
        _dropoffController.text = picked.name;
      }
    });
  }

  Future<void> _createRide(List<RegionModel> regions) async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final region = _findRegion(regions);
    if (region == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Region Name')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final distance = double.tryParse(_distanceController.text.trim());
    final duration = int.tryParse(_durationController.text.trim());
    final pickupLat = double.tryParse(_pickupLatController.text.trim());
    final pickupLng = double.tryParse(_pickupLngController.text.trim());
    if (distance == null ||
        distance <= 0 ||
        duration == null ||
        duration <= 0 ||
        pickupLat == null ||
        pickupLng == null ||
        pickupLat < -90 ||
        pickupLat > 90 ||
        pickupLng < -180 ||
        pickupLng > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Distance/duration must be greater than 0 and pickup coordinates must be valid',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result =
        await context.read<RideService>().createRideAndDispatchToNearbyDrivers(
              region: region,
              pickupLocation: _pickupController.text.trim(),
              dropoffLocation: _dropoffController.text.trim(),
              distanceKm: distance,
              durationMinutes: duration,
              pickupLatitude: pickupLat,
              pickupLongitude: pickupLng,
              rideType: _rideType,
              vehicleInfo: _vehicleController.text.trim(),
              fleetClass: _fleetController.text.trim().isEmpty
                  ? 'Standard'
                  : _fleetController.text.trim(),
            );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create ride'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ride created and sent to ${result.nearbyDriversNotified} nearby drivers',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background =
        widget.isDark ? DashboardColors.surfaceDark : Colors.white;
    final textMuted = widget.isDark
        ? DashboardColors.textMutedDark
        : DashboardColors.textMutedLight;

    return Consumer<RegionService>(
      builder: (context, regionService, _) {
        final regions = regionService.activeRegions;

        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: background,
            surfaceTintColor: background,
            centerTitle: true,
            title: Text(
              context.tr('Create New Ride'),
              style: const TextStyle(
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create and dispatch a new ride request',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRegionId,
                      decoration: const InputDecoration(
                        labelText: 'Region',
                        border: OutlineInputBorder(),
                      ),
                      items: regions
                          .map((region) => DropdownMenuItem<String>(
                                value: region.id,
                                child: Text(region.name),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _selectedRegionId = value;
                        _recalculateEstimatedFare();
                      }),
                      validator: (value) =>
                          value == null ? 'Please select a region' : null,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<RideType>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment<RideType>(
                          value: RideType.standard,
                          label: Text(context.tr('Standard Pricing')),
                        ),
                        ButtonSegment<RideType>(
                          value: RideType.corporate,
                          label: Text(context.tr('Corporate Pricing')),
                        ),
                      ],
                      selected: {_rideType},
                      onSelectionChanged: (value) {
                        setState(() => _rideType = value.first);
                        _recalculateEstimatedFare();
                      },
                    ),
                    const SizedBox(height: 12),
                    _RideTextField(
                      controller: _pickupController,
                      label: 'Pickup',
                      readOnly: true,
                      trailingIcon: const Icon(Icons.place_outlined),
                      onTap: () => _pickLocation(isPickup: true),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Pickup is required'
                              : null,
                    ),
                    const SizedBox(height: 10),
                    _RideTextField(
                      controller: _dropoffController,
                      label: 'Dropoff',
                      readOnly: true,
                      trailingIcon: const Icon(Icons.place_outlined),
                      onTap: () => _pickLocation(isPickup: false),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Dropoff is required'
                              : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _RideTextField(
                            controller: _distanceController,
                            label: 'Distance (km)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (value) =>
                                (double.tryParse(value ?? '') ?? 0) <= 0
                                    ? 'Required'
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RideTextField(
                            controller: _durationController,
                            label: 'Duration (min)',
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                (int.tryParse(value ?? '') ?? 0) <= 0
                                    ? 'Required'
                                    : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _RideTextField(
                      controller: _vehicleController,
                      label: 'Vehicle Info',
                    ),
                    const SizedBox(height: 10),
                    _RideTextField(
                      controller: _fleetController,
                      label: 'Fleet Class',
                    ),
                    if (_estimatedFare != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              DashboardColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                DashboardColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Fare',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12,
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${_estimatedFare!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: DashboardColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Drivers within 5 km will receive ride confirmation requests',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 11,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (regionService.isLoading)
                      const LinearProgressIndicator(minHeight: 2),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Text(context.tr('Cancel')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting || regionService.isLoading
                                ? null
                                : () => _createRide(regions),
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.add_rounded),
                            label: Text(context.tr('Create New Ride')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RideTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? trailingIcon;

  const _RideTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: trailingIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PickedPlace {
  final String name;
  final double latitude;
  final double longitude;

  const _PickedPlace({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class _PlacePickerPage extends StatefulWidget {
  final bool isDark;
  final String title;

  const _PlacePickerPage({
    required this.isDark,
    required this.title,
  });

  @override
  State<_PlacePickerPage> createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<_PlacePickerPage> {
  static const List<_PickedPlace> _allPlaces = [
    _PickedPlace(
        name: 'Downtown Square, NYC', latitude: 40.7580, longitude: -73.9855),
    _PickedPlace(
        name: 'Terminal 4, JFK Airport',
        latitude: 40.6413,
        longitude: -73.7781),
    _PickedPlace(
        name: '88th St, Madison Ave', latitude: 40.7831, longitude: -73.9590),
    _PickedPlace(
        name: 'Metropolitan Museum', latitude: 40.7794, longitude: -73.9632),
    _PickedPlace(
        name: 'Airport Zone, Lusaka', latitude: -15.3875, longitude: 28.3228),
    _PickedPlace(
        name: 'Cairo Road, Lusaka', latitude: -15.4134, longitude: 28.2844),
    _PickedPlace(
        name: 'Arcades Mall, Lusaka', latitude: -15.3878, longitude: 28.3225),
    _PickedPlace(
        name: 'East Park Mall, Lusaka', latitude: -15.3907, longitude: 28.3217),
    _PickedPlace(
        name: 'Kenneth Kaunda Int. Airport',
        latitude: -15.3308,
        longitude: 28.4526),
    _PickedPlace(
        name: 'Sandton City, Johannesburg',
        latitude: -26.1076,
        longitude: 28.0567),
    _PickedPlace(
        name: 'OR Tambo Airport', latitude: -26.1337, longitude: 28.2420),
    _PickedPlace(
        name: 'Victoria Island, Lagos', latitude: 6.4281, longitude: 3.4219),
    _PickedPlace(
        name: 'Murtala Muhammed Airport', latitude: 6.5774, longitude: 3.3212),
    _PickedPlace(
        name: 'Westlands, Nairobi', latitude: -1.2648, longitude: 36.8049),
    _PickedPlace(
        name: 'JKIA Airport, Nairobi', latitude: -1.3192, longitude: 36.9278),
    _PickedPlace(
        name: 'Central London, UK', latitude: 51.5074, longitude: -0.1278),
    _PickedPlace(
        name: 'Heathrow Airport, London',
        latitude: 51.4700,
        longitude: -0.4543),
    _PickedPlace(name: 'Downtown Dubai', latitude: 25.2048, longitude: 55.2708),
    _PickedPlace(
        name: 'Dubai International Airport',
        latitude: 25.2532,
        longitude: 55.3657),
  ];

  final TextEditingController _searchController = TextEditingController();
  List<_PickedPlace> _filteredPlaces = List<_PickedPlace>.from(_allPlaces);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPlaces);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlaces() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlaces = List<_PickedPlace>.from(_allPlaces);
      } else {
        _filteredPlaces = _allPlaces
            .where((place) => place.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark
        ? DashboardColors.backgroundDark
        : const Color(0xFFF8FAFC);
    final cardBg = widget.isDark ? DashboardColors.surfaceDark : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: bg,
        surfaceTintColor: bg,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search place',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _filteredPlaces.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final place = _filteredPlaces[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).pop(place),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.isDark
                                ? DashboardColors.borderDark
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                place.name,
                                style: const TextStyle(
                                  fontFamily: _fontFamily,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              '${place.latitude.toStringAsFixed(3)}, ${place.longitude.toStringAsFixed(3)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: widget.isDark
                                    ? DashboardColors.textMutedDark
                                    : DashboardColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
            ? (isDark
                ? DashboardColors.surfaceDark.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.6))
            : (isDark ? DashboardColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPending
              ? (isDark ? DashboardColors.borderDark : const Color(0xFFE2E8F0))
              : (isDark ? DashboardColors.borderDark : const Color(0xFFF1F5F9)),
          style: isPending ? BorderStyle.solid : BorderStyle.solid,
          width: isPending ? 1.5 : 1,
        ),
        boxShadow: isPending
            ? null
            : [
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
                                isPending
                                    ? 'Assigning Driver...'
                                    : (ride.driverName ?? 'Unknown Driver'),
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: isPending
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: isPending
                                      ? (isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8))
                                      : (isDark
                                          ? DashboardColors.textMainDark
                                          : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPending
                                    ? 'Fleet Class: ${ride.fleetClass}'
                                    : ride.vehicleInfo,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 12,
                                  color: isDark
                                      ? DashboardColors.textMutedDark
                                      : const Color(0xFF64748B),
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
            child:
                ride.driverPhotoUrl != null && ride.driverPhotoUrl!.isNotEmpty
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
                        ? (isDark
                            ? const Color(0xFF4B5563)
                            : const Color(0xFFE2E8F0))
                        : (isDark
                            ? const Color(0xFF4B5563)
                            : const Color(0xFFCBD5E1)),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 24,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: isPending
                    ? (isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF1F5F9))
                    : (isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF1F5F9)),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPending ? null : _statusColor,
                  border: isPending
                      ? Border.all(
                          color: isDark
                              ? const Color(0xFF4B5563)
                              : const Color(0xFFE2E8F0),
                          width: 2,
                        )
                      : null,
                  boxShadow: isPending
                      ? null
                      : [
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
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              Text(
                isPending
                    ? 'Pickup: ${ride.pickupLocation}'
                    : ride.pickupLocation,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                  color: isPending
                      ? (isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF94A3B8))
                      : (isDark
                          ? DashboardColors.textMutedDark
                          : const Color(0xFF64748B)),
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
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              Text(
                isPending
                    ? 'Dest: ${ride.dropoffLocation}'
                    : ride.dropoffLocation,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontStyle: isPending ? FontStyle.italic : FontStyle.normal,
                  color: isPending
                      ? (isDark
                          ? const Color(0xFF6B7280)
                          : const Color(0xFF94A3B8))
                      : (isDark
                          ? DashboardColors.textMainDark
                          : const Color(0xFF0F172A)),
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
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _animation == null) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: DashboardColors.primary,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation!,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DashboardColors.primary.withValues(alpha: _animation!.value),
            boxShadow: [
              BoxShadow(
                color: DashboardColors.primary
                    .withValues(alpha: _animation!.value * 0.5),
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
