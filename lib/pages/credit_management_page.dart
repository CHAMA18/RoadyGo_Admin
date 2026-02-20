import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/services/driver_service.dart';
import 'package:roadygo_admin/theme.dart';

const String _fontFamily = 'Satoshi';

class CreditManagementPage extends StatefulWidget {
  const CreditManagementPage({super.key});

  @override
  State<CreditManagementPage> createState() => _CreditManagementPageState();
}

class _CreditManagementPageState extends State<CreditManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String _selectedReason = 'Balance adjustment';
  String? _selectedDriverId;
  bool _isApplying = false;

  static const List<String> _creditReasons = [
    'Balance adjustment',
    'Trip correction',
    'Promotional bonus',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reloadDrivers();
    });
  }

  Future<void> _reloadDrivers() async {
    final driverService = context.read<DriverService>();
    await driverService.fetchDrivers();
    if (!mounted) return;
    await driverService.fetchOnlineDrivers();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _setQuickAmount(int amount) {
    setState(() {
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  List<DriverModel> _rankedDrivers(DriverService driverService) {
    final source = driverService.onlineDrivers.isNotEmpty
        ? driverService.onlineDrivers
        : driverService.drivers;
    final drivers = [...source];
    drivers.sort((a, b) {
      final statusA = a.isOnline ? 0 : (a.isOnBreak ? 1 : 2);
      final statusB = b.isOnline ? 0 : (b.isOnBreak ? 1 : 2);
      if (statusA != statusB) return statusA.compareTo(statusB);
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return drivers;
  }

  List<DriverModel> _filterDrivers(List<DriverModel> drivers, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return drivers;

    return drivers.where((driver) {
      final name = driver.name.toLowerCase();
      final id = driver.id.toLowerCase();
      final displayId = _driverCode(driver.id).toLowerCase();
      return name.contains(normalized) ||
          id.contains(normalized) ||
          displayId.contains(normalized);
    }).toList();
  }

  DriverModel? _resolveSelectedDriver(List<DriverModel> drivers) {
    if (drivers.isEmpty) return null;
    if (_selectedDriverId == null) return drivers.first;

    for (final driver in drivers) {
      if (driver.id == _selectedDriverId) return driver;
    }
    return drivers.first;
  }

  Future<void> _applyCredit(DriverModel driver) async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Enter a valid credit amount.'),
        ),
      );
      return;
    }

    if (_isApplying) return;
    setState(() => _isApplying = true);

    final success = await context.read<DriverService>().addFunds(driver.id, amount);
    if (!mounted) return;

    setState(() => _isApplying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          success
              ? 'Applied \$${amount.toStringAsFixed(2)} to ${driver.name}.'
              : 'Failed to apply credit. Please try again.',
        ),
      ),
    );

    if (success) {
      _amountController.clear();
    }
  }

  Stream<double> _watchDriverLifetimeEarnings(String driverId) {
    return FirebaseFirestore.instance
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      var total = 0.0;
      for (final doc in snapshot.docs) {
        total += _extractRideFare(doc.data());
      }
      return total;
    });
  }

  double _extractRideFare(Map<String, dynamic> data) {
    final fare = _asDouble(data['fare']) ??
        _asDouble(data['estimatedFare']) ??
        _reconstructFare(data);
    if (fare <= 0) return 0;
    return fare;
  }

  double _reconstructFare(Map<String, dynamic> data) {
    final baseFare = _asDouble(data['baseFare']) ?? 0;
    final costPerKm = _asDouble(data['costPerKm']) ?? 0;
    final costPerMin = _asDouble(data['costPerMin']) ?? 0;
    final distanceKm = _asDouble(data['distanceKm']) ?? 0;
    final durationMinutes = _asDouble(data['durationMinutes']) ?? 0;
    return baseFare + (costPerKm * distanceKm) + (costPerMin * durationMinutes);
  }

  double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _driverCode(String driverId) {
    final sanitized = driverId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (sanitized.isEmpty) return '#DRV-0000';
    final shortCode =
        sanitized.length > 6 ? sanitized.substring(0, 6) : sanitized;
    return '#DRV-$shortCode';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'DR';
    if (parts.length == 1) {
      final single = parts.first;
      return single.length >= 2
          ? single.substring(0, 2).toUpperCase()
          : single.toUpperCase();
    }
    final first = parts[0].isEmpty ? '' : parts[0][0];
    final second = parts[1].isEmpty ? '' : parts[1][0];
    final combined = '$first$second'.toUpperCase();
    return combined.isEmpty ? 'DR' : combined;
  }

  String _statusLabel(DriverModel driver) {
    if (driver.isOnline) return 'ACTIVE NOW';
    if (driver.isOnBreak) return 'ON BREAK';
    return 'OFFLINE';
  }

  Color _statusColor(DriverModel driver) {
    if (driver.isOnline) return const Color(0xFF16C47F);
    if (driver.isOnBreak) return const Color(0xFFF6A21A);
    return const Color(0xFF9AA5B1);
  }

  String _currency(double value) {
    final safeValue = value.isFinite ? value : 0;
    final fixed = safeValue.toStringAsFixed(2);
    final segments = fixed.split('.');
    final whole = segments[0];
    final decimals = segments[1];

    final buffer = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      final indexFromRight = whole.length - i;
      buffer.write(whole[i]);
      if (indexFromRight > 1 && indexFromRight % 3 == 1) {
        buffer.write(',');
      }
    }

    return '\$${buffer.toString()}.$decimals';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF5F6F8);
    final card = isDark ? AppColors.darkBackgroundSecondary : Colors.white;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : const Color(0xFF1B263B);
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF7A8798);
    final line = isDark ? AppColors.darkLine : const Color(0xFFE5E8EE);

    return Scaffold(
      backgroundColor: bg,
      body: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.tr('Credit Management'),
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: line),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search driver name or ID...',
                      hintStyle: TextStyle(
                        fontFamily: _fontFamily,
                        color: textSecondary.withValues(alpha: 0.8),
                      ),
                      prefixIcon: Icon(Icons.search_rounded, color: textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Consumer<DriverService>(
                    builder: (context, driverService, _) {
                      final rankedDrivers = _rankedDrivers(driverService);
                      final drivers =
                          _filterDrivers(rankedDrivers, _searchController.text);
                      final selectedDriver = _resolveSelectedDriver(drivers);

                      if (driverService.isLoading &&
                          driverService.drivers.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (driverService.error != null &&
                          driverService.drivers.isEmpty) {
                        return _ErrorView(
                          message: driverService.error!,
                          onRetry: () {
                            _reloadDrivers();
                          },
                        );
                      }

                      if (drivers.isEmpty || selectedDriver == null) {
                        return _EmptyView(
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        );
                      }

                      final recentDrivers = drivers.take(12).toList();

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'RECENT DRIVERS',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _searchController.clear,
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 112,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: recentDrivers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final driver = recentDrivers[index];
                                  return _RecentDriverAvatar(
                                    driver: driver,
                                    initials: _initials(driver.name),
                                    isDark: isDark,
                                    isSelected: driver.id == selectedDriver.id,
                                    onTap: () => setState(
                                      () => _selectedDriverId = driver.id,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            _DriverBalanceCard(
                              driver: selectedDriver,
                              initials: _initials(selectedDriver.name),
                              statusLabel: _statusLabel(selectedDriver),
                              statusColor: _statusColor(selectedDriver),
                              driverCode: _driverCode(selectedDriver.id),
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              card: card,
                              line: line,
                              currencyFormatter: _currency,
                              lifetimeEarningsStream:
                                  _watchDriverLifetimeEarnings(
                                selectedDriver.id,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Credit Amount',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _amountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                              decoration: InputDecoration(
                                prefixText: '\$ ',
                                prefixStyle: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary.withValues(alpha: 0.7),
                                ),
                                hintText: '0.00',
                                hintStyle: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary.withValues(alpha: 0.5),
                                ),
                                filled: true,
                                fillColor: card,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: line),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: line),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.secondary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'QUICK ADD',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [10, 50, 100].map((amount) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: amount == 100 ? 0 : 10,
                                    ),
                                    child: OutlinedButton(
                                      onPressed: () => _setQuickAmount(amount),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.35),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        backgroundColor: card,
                                      ),
                                      child: Text(
                                        '\$$amount',
                                        style: const TextStyle(
                                          fontFamily: _fontFamily,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Reason for Credit',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: _selectedReason,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: textSecondary,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: card,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: line),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: line),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: AppColors.secondary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textPrimary,
                              ),
                              dropdownColor: card,
                              items: _creditReasons
                                  .map(
                                    (reason) => DropdownMenuItem<String>(
                                      value: reason,
                                      child: Text(reason),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedReason = value);
                              },
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _isApplying
                                    ? null
                                    : () => _applyCredit(selectedDriver),
                                icon: _isApplying
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                      ),
                                label: Text(
                                  _isApplying ? 'APPLYING...' : 'APPLY CREDIT',
                                  style: const TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppColors.secondary.withValues(alpha: 0.6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      AppColors.secondary.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DriverBalanceCard extends StatelessWidget {
  final DriverModel driver;
  final String initials;
  final String statusLabel;
  final Color statusColor;
  final String driverCode;
  final Color textPrimary;
  final Color textSecondary;
  final Color card;
  final Color line;
  final String Function(double value) currencyFormatter;
  final Stream<double> lifetimeEarningsStream;

  const _DriverBalanceCard({
    required this.driver,
    required this.initials,
    required this.statusLabel,
    required this.statusColor,
    required this.driverCode,
    required this.textPrimary,
    required this.textSecondary,
    required this.card,
    required this.line,
    required this.currencyFormatter,
    required this.lifetimeEarningsStream,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _AvatarBlock(driver: driver, initials: initials, size: 68),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name.isEmpty ? 'Unknown driver' : driver.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: $driverCode',
                      style: const TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFF6A21A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      driver.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF6A21A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _BalanceBlock(
                  label: 'CURRENT BALANCE',
                  value: currencyFormatter(driver.floatBalance),
                  valueColor: textPrimary,
                  alignEnd: false,
                ),
              ),
              Expanded(
                child: StreamBuilder<double>(
                  stream: lifetimeEarningsStream,
                  initialData: 0,
                  builder: (context, snapshot) {
                    final value = snapshot.data ?? 0;
                    return _BalanceBlock(
                      label: 'LIFETIME EARNINGS',
                      value: currencyFormatter(value),
                      valueColor: textPrimary,
                      alignEnd: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  final DriverModel driver;
  final String initials;
  final double size;

  const _AvatarBlock({
    required this.driver,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size / 2;
    final hasPhoto = driver.photoUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: hasPhoto
          ? Image.network(
              driver.photoUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _InitialsAvatar(
                initials: initials,
                radius: radius,
                rectangular: true,
              ),
            )
          : _InitialsAvatar(
              initials: initials,
              radius: radius,
              rectangular: true,
            ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double radius;
  final bool rectangular;

  const _InitialsAvatar({
    required this.initials,
    required this.radius,
    this.rectangular = false,
  });

  @override
  Widget build(BuildContext context) {
    if (rectangular) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A8C89), Color(0xFF446D69)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE7ECF2),
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3A4D),
        ),
      ),
    );
  }
}

class _BalanceBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;

  const _BalanceBlock({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF9AA5B1);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _RecentDriverAvatar extends StatelessWidget {
  final DriverModel driver;
  final String initials;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecentDriverAvatar({
    required this.driver,
    required this.initials,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.darkTextSecondary : const Color(0xFF808A99);
    final activeNameColor =
        isDark ? AppColors.darkTextPrimary : const Color(0xFF1B263B);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSelected ? 2 : 0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.secondary, width: 2)
                    : null,
              ),
              child: driver.photoUrl.trim().isNotEmpty
                  ? CircleAvatar(
                      radius: 27,
                      backgroundColor: isDark
                          ? AppColors.darkAlternate
                          : const Color(0xFFE7ECF2),
                      backgroundImage: NetworkImage(driver.photoUrl),
                    )
                  : _InitialsAvatar(initials: initials, radius: 27),
            ),
            const SizedBox(height: 8),
            Text(
              driver.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeNameColor : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.lightError),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: _fontFamily, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(fontFamily: _fontFamily),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _EmptyView({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackgroundSecondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkLine : const Color(0xFFE5E8EE),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 36,
              color: textSecondary,
            ),
            const SizedBox(height: 10),
            Text(
              'No drivers match this search.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
