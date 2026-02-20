import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/models/schedule_model.dart';
import 'package:roadygo_admin/nav.dart';
import 'package:roadygo_admin/pages/regions_section.dart';
import 'package:roadygo_admin/pages/rides_section.dart';
import 'package:roadygo_admin/services/auth_service.dart';
import 'package:roadygo_admin/services/driver_service.dart';
import 'package:roadygo_admin/services/ride_service.dart';
import 'package:roadygo_admin/services/schedule_service.dart';
import 'package:roadygo_admin/theme.dart';

const String _fontFamily = 'Satoshi';

/// Admin Dashboard page for MAXI TAXI
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedTabIndex = 0;
  late final AuthService _authService;
  bool _hasBootstrappedDashboardData = false;

  final List<String> _tabs = [
    'Riders',
    'Regions',
    'Commission',
    'Admins',
    'Schedules',
    'Currency Payout',
  ];

  @override
  void initState() {
    super.initState();
    _authService = context.read<AuthService>();
    _authService.addListener(_onAuthStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthStateChanged());
  }

  void _onAuthStateChanged() {
    if (!mounted) return;

    if (!_authService.isAuthenticated) {
      _hasBootstrappedDashboardData = false;
      return;
    }

    if (_hasBootstrappedDashboardData) return;
    _hasBootstrappedDashboardData = true;

    context.read<DriverService>().fetchOnlineDrivers();
    context.read<ScheduleService>().fetchSchedules();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? DashboardColors.backgroundDark
          : DashboardColors.backgroundLight,
      body: Column(
        children: [
          // Header
          DashboardHeader(isDark: isDark),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats cards
                  const StatsSection(),
                  const SizedBox(height: 16),

                  // Tab buttons
                  TabButtonsSection(
                    tabs: _tabs,
                    selectedIndex: _selectedTabIndex,
                    onTabSelected: (index) =>
                        setState(() => _selectedTabIndex = index),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Content based on selected tab
                  if (_selectedTabIndex == 0)
                    RidesSection(isDark: isDark)
                  else if (_selectedTabIndex == 1)
                    RegionsSection(isDark: isDark)
                  else if (_selectedTabIndex == 2)
                    CommissionSection(isDark: isDark)
                  else if (_selectedTabIndex == 3)
                    OnlineDriversSection(isDark: isDark)
                  else if (_selectedTabIndex == 4)
                    SchedulesSection(isDark: isDark)
                  else
                    CurrencyPayoutSection(isDark: isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard Colors - aligned with app theme
class DashboardColors {
  static const Color primary = AppColors.primary;
  static const Color primaryDark = Color(0xFFC62828);
  static const Color backgroundLight = AppColors.lightBackground;
  static const Color backgroundDark = AppColors.darkBackground;
  static const Color surfaceLight = AppColors.lightBackgroundSecondary;
  static const Color surfaceDark = AppColors.darkBackgroundSecondary;
  static const Color textMainLight = AppColors.lightTextPrimary;
  static const Color textMainDark = AppColors.darkTextPrimary;
  static const Color textMutedLight = AppColors.lightTextSecondary;
  static const Color textMutedDark = AppColors.darkTextSecondary;
  static const Color borderLight = AppColors.lightLine;
  static const Color borderDark = AppColors.darkLine;
}

/// Dashboard Header
class DashboardHeader extends StatelessWidget {
  final bool isDark;

  const DashboardHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: (isDark
                ? DashboardColors.backgroundDark
                : DashboardColors.backgroundLight)
            .withValues(alpha: 0.9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? DashboardColors.textMainDark
                      : DashboardColors.textMainLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fleet Overview',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  color: isDark
                      ? DashboardColors.textMutedDark
                      : DashboardColors.textMutedLight,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.profileSettings),
            child: Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: DashboardColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: DashboardColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuB_HSVBAU1aUwteJAwee5ScqAK1KKdBBA23awNNzuJAIRuPYN5LqMkx3SugkZW7jeZ7eEoJVv_x3bRvL6gQ3twwEFW72Wsu3xMaDu9MXyXqmQMetkHce-kF9d2yAcnhl7yXsD5YuuAOB0anU_GOEaspz7hUJDhsz7toBwLsZcYgU-0a0PSUR9XsYy3tf9EBdGT3vfgmdd3I3tCzM6-64T0DqIS7ZoRL4edjzOmQzVmFD9LZgaoeQvVYcCaNbFnL0f3mMbqNTAD4u08L',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: DashboardColors.primary.withValues(alpha: 0.2),
                        child: const Icon(Icons.person,
                            color: DashboardColors.primary),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? DashboardColors.backgroundDark
                            : DashboardColors.backgroundLight,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats Section
class StatsSection extends StatefulWidget {
  const StatsSection({super.key});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  int? _previousCount;
  double? _previousCommission;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: StreamBuilder<int>(
              stream: context.read<DriverService>().watchActiveDriverCount(),
              builder: (context, snapshot) {
                final count = snapshot.data ?? 0;

                String? change;
                bool isChangePositive = true;

                if (_previousCount != null && _previousCount != count) {
                  final diff = count - _previousCount!;
                  final base =
                      _previousCount == 0 ? count : _previousCount!.abs();

                  if (base > 0) {
                    final percent = ((diff / base) * 100).round().abs();
                    change = '$percent%';
                    isChangePositive = diff >= 0;
                  }
                }

                _previousCount = count;

                return StatCard(
                  icon: Icons.directions_car,
                  label: 'Active Drivers',
                  value: count.toString(),
                  change: change,
                  isChangePositive: isChangePositive,
                  isDark: isDark,
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StreamBuilder<CommissionSummary>(
              stream: context.read<RideService>().watchCommissionSummary(),
              builder: (context, snapshot) {
                final summary = snapshot.data;
                final commission = summary?.platformCommission ?? 0.0;

                String? change;
                bool isChangePositive = true;
                if (_previousCommission != null &&
                    _previousCommission != commission) {
                  final diff = commission - _previousCommission!;
                  final base = _previousCommission == 0
                      ? commission
                      : _previousCommission!.abs();
                  if (base > 0) {
                    final percent = ((diff / base) * 100).round().abs();
                    change = '$percent%';
                    isChangePositive = diff >= 0;
                  }
                }
                _previousCommission = commission;

                return StatCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Commission',
                  value: '\$${commission.toStringAsFixed(2)}',
                  change: change,
                  isChangePositive: isChangePositive,
                  isDark: isDark,
                  isLoading:
                      snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? change;
  final bool isChangePositive;
  final bool isDark;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    this.isChangePositive = true,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? DashboardColors.borderDark : DashboardColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DashboardColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? DashboardColors.textMutedDark
                        : DashboardColors.textMutedLight,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      value,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? DashboardColors.textMainDark
                            : DashboardColors.textMainLight,
                      ),
                    ),
              if (change != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isChangePositive ? Colors.green : Colors.red)
                        .withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isChangePositive
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: isChangePositive ? Colors.green : Colors.red,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        change!,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isChangePositive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tab Buttons Section
class TabButtonsSection extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;
  final bool isDark;

  const TabButtonsSection({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? DashboardColors.primary
                    : (isDark
                        ? DashboardColors.surfaceDark
                        : DashboardColors.surfaceLight),
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? null
                    : Border.all(
                        color: isDark
                            ? DashboardColors.borderDark
                            : DashboardColors.borderLight),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: DashboardColors.primary.withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? DashboardColors.textMutedDark
                          : DashboardColors.textMutedLight),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnlineDriversSection extends StatelessWidget {
  final bool isDark;

  const OnlineDriversSection({super.key, required this.isDark});

  Future<void> _openAllDriversSheet(
    BuildContext context,
    List<DriverModel> drivers,
  ) async {
    if (drivers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No online drivers available.'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final textColor = isDark
            ? DashboardColors.textMainDark
            : DashboardColors.textMainLight;
        final subtextColor = isDark
            ? DashboardColors.textMutedDark
            : DashboardColors.textMutedLight;
        final tileColor = isDark
            ? DashboardColors.surfaceDark
            : DashboardColors.surfaceLight;

        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: subtextColor.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Online Drivers',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${drivers.length}',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: subtextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: drivers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    return Material(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: Text(
                          driver.name.isEmpty ? 'Unknown driver' : driver.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          driver.isOnBreak ? 'On break' : 'Online',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            color: subtextColor,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.push(
                            AppRoutes.driverDetails,
                            extra: driver,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Online Drivers'),
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? DashboardColors.textMainDark
                      : DashboardColors.textMainLight,
                ),
              ),
              TextButton(
                onPressed: () {
                  final driverService = context.read<DriverService>();
                  final drivers = [...driverService.onlineDrivers]
                    ..sort((a, b) => a.name.compareTo(b.name));
                  _openAllDriversSheet(context, drivers);
                },
                child: Text(
                  context.tr('See All'),
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DashboardColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Consumer<DriverService>(
          builder: (context, driverService, _) {
            if (driverService.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (driverService.error != null) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      context.tr('Failed to load drivers'),
                      style: TextStyle(
                        color: isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => driverService.fetchOnlineDrivers(),
                      child: Text(context.tr('Retry')),
                    ),
                  ],
                ),
              );
            }

            final drivers = driverService.onlineDrivers;
            if (drivers.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 48,
                        color: isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.tr('No drivers online'),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16,
                          color: isDark
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
                children: drivers
                    .map((driver) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DriverCard(driver: driver, isDark: isDark),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SchedulesSection extends StatelessWidget {
  final bool isDark;

  const SchedulesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScheduleService, DriverService>(
      builder: (context, scheduleService, driverService, _) {
        final isLoading = scheduleService.isLoading || driverService.isLoading;
        if (isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (scheduleService.error != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Failed to load schedules',
                  style: TextStyle(
                    color: isDark
                        ? DashboardColors.textMutedDark
                        : DashboardColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => scheduleService.fetchSchedules(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (driverService.error != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  context.tr('Failed to load drivers'),
                  style: TextStyle(
                    color: isDark
                        ? DashboardColors.textMutedDark
                        : DashboardColors.textMutedLight,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => driverService.fetchOnlineDrivers(),
                  child: Text(context.tr('Retry')),
                ),
              ],
            ),
          );
        }

        final registeredDriversById = {
          for (final driver in driverService.drivers) driver.id: driver,
        };
        final now = DateTime.now();
        final takenSchedules = scheduleService.schedules.where((schedule) {
          final driverId = schedule.driverId.trim();
          if (driverId.isEmpty) return false;
          if (!registeredDriversById.containsKey(driverId)) return false;
          return schedule.endTime.isAfter(now);
        }).toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scheduled Rides',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? DashboardColors.textMainDark
                          : DashboardColors.textMainLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => scheduleService.fetchSchedules(),
                    child: Text(
                      'Refresh',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (takenSchedules.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 48,
                        color: isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No scheduled rides taken up yet',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16,
                          color: isDark
                              ? DashboardColors.textMutedDark
                              : DashboardColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: takenSchedules
                      .map((schedule) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ScheduledRideCard(
                              schedule: schedule,
                              driver: registeredDriversById[schedule.driverId],
                              isDark: isDark,
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class CurrencyPayoutSection extends StatefulWidget {
  final bool isDark;

  const CurrencyPayoutSection({super.key, required this.isDark});

  @override
  State<CurrencyPayoutSection> createState() => _CurrencyPayoutSectionState();
}

class _CurrencyPayoutSectionState extends State<CurrencyPayoutSection> {
  String? _selectedCurrencyCode;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('regions')
          .orderBy('name')
          .limit(300)
          .snapshots(),
      builder: (context, regionsSnapshot) {
        if (regionsSnapshot.connectionState == ConnectionState.waiting &&
            !regionsSnapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (regionsSnapshot.hasError) {
          return _CurrencyDataState(
            title: 'Unable to load region currencies',
            subtitle: '${regionsSnapshot.error}',
            isDark: widget.isDark,
          );
        }

        final regionDocs = regionsSnapshot.data?.docs ?? const [];
        if (regionDocs.isEmpty) {
          return _CurrencyDataState(
            title: 'No regions configured',
            subtitle: 'Create regions first to enable currency payout analytics.',
            isDark: widget.isDark,
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('rides')
              .where('status', isEqualTo: 'completed')
              .snapshots(),
          builder: (context, ridesSnapshot) {
            if (ridesSnapshot.connectionState == ConnectionState.waiting &&
                !ridesSnapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (ridesSnapshot.hasError) {
              return _CurrencyDataState(
                title: 'Unable to load payout rides',
                subtitle: '${ridesSnapshot.error}',
                isDark: widget.isDark,
              );
            }

            final rideDocs = ridesSnapshot.data?.docs ?? const [];
            final dataset = _CurrencyPayoutDataset.fromSnapshots(
              regionDocs: regionDocs,
              rideDocs: rideDocs,
              now: DateTime.now(),
            );

            if (dataset.currencies.isEmpty) {
              return _CurrencyDataState(
                title: 'No currencies found on regions',
                subtitle:
                    'Add a currency field (e.g. currencyCode: USD) to your region documents.',
                isDark: widget.isDark,
              );
            }

            final selectedCode =
                dataset.resolveSelectedCode(_selectedCurrencyCode);
            final selectedMetric = dataset.metrics[selectedCode]!;
            final performance = dataset.performanceFor(selectedCode);
            final textMain = widget.isDark
                ? DashboardColors.textMainDark
                : DashboardColors.textMainLight;
            final textMuted = widget.isDark
                ? DashboardColors.textMutedDark
                : DashboardColors.textMutedLight;
            final surface = widget.isDark
                ? DashboardColors.surfaceDark
                : DashboardColors.surfaceLight;
            final border = widget.isDark
                ? DashboardColors.borderDark
                : DashboardColors.borderLight;
            final moneyParts = _moneyParts(selectedMetric.totalRevenue);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFE7DA),
                          border: Border.all(
                              color: const Color(0xFFF4D0BF), width: 1.3),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFFEE7C47), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Global Earnings',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                color: textMain,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      _CircleIconButton(
                        icon: Icons.notifications_none_rounded,
                        background: widget.isDark
                            ? DashboardColors.surfaceDark
                            : const Color(0xFFF5F8FC),
                        iconColor: textMain,
                      ),
                      const SizedBox(width: 10),
                      const _CircleIconButton(
                        icon: Icons.account_balance_wallet_rounded,
                        background: Color(0xFFFF5A1F),
                        iconColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'SELECT CURRENCY',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dataset.currencies.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final spec = dataset.currencies[index];
                        return _CurrencySelectorChip(
                          spec: spec,
                          selected: spec.code == selectedCode,
                          isDark: widget.isDark,
                          onTap: () => setState(() => _selectedCurrencyCode = spec.code),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  TweenAnimationBuilder<double>(
                    key: ValueKey('summary-$selectedCode'),
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - value) * 14),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1C1D3A),
                            Color(0xFF101B4A),
                            Color(0xFF1F112A),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF101B4A).withValues(alpha: 0.35),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Revenue',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 15,
                                  color: Color(0xFFB0B9D6),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F2840),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _formatPercent(selectedMetric.growthPercent),
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: selectedMetric.growthPercent >= 0
                                        ? const Color(0xFFFF7A38)
                                        : const Color(0xFFF87171),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '${selectedMetric.spec.symbol}${moneyParts.$1}',
                                    style: const TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 62,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      height: 0.95,
                                      letterSpacing: -1.4,
                                    ),
                                  ),
                                  TextSpan(
                                    text: moneyParts.$2,
                                    style: const TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 62,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFF5A1F),
                                      height: 0.95,
                                      letterSpacing: -1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              _RevenuePeriodPill(
                                label: 'RG ${selectedMetric.regionCount}',
                                isActive: false,
                                isDark: widget.isDark,
                              ),
                              const SizedBox(width: 6),
                              _RevenuePeriodPill(
                                label: 'RD ${selectedMetric.completedRides}',
                                isActive: false,
                                isDark: widget.isDark,
                              ),
                              const SizedBox(width: 6),
                              _RevenuePeriodPill(
                                label: _formatPercent(selectedMetric.growthPercent),
                                isActive: true,
                                isDark: widget.isDark,
                              ),
                              const Spacer(),
                              Text(
                                selectedMetric.updatedLabel,
                                style: const TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 13,
                                  color: Color(0xFF8994B5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Earnings Trend',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textMain,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'LAST 7 DAYS',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                                color: textMuted,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                color: textMuted, size: 18),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 160,
                          child: _CurrencyTrendChart(
                            values: selectedMetric.normalizedTrend,
                            accent: selectedMetric.spec.accent,
                            peakLabel: selectedMetric.peakLabel,
                            peakIndex: selectedMetric.peakIndex,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _TrendAxisLabel('MON'),
                            _TrendAxisLabel('WED'),
                            _TrendAxisLabel('FRI'),
                            _TrendAxisLabel('SUN'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Currency Performance',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textMain,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...performance.asMap().entries.map((entry) {
                          final metric = entry.value;
                          final isLast = entry.key == performance.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                            child: _CurrencyPerformanceRow(
                              metric: metric,
                              isDark: widget.isDark,
                              highlighted: metric.spec.code == selectedCode,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}

class _CurrencySelectorChip extends StatelessWidget {
  final _CurrencySpec spec;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _CurrencySelectorChip({
    required this.spec,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? const Color(0xFFFF5A1F)
        : (isDark ? DashboardColors.textMainDark : const Color(0xFF56627A));
    final background = selected
        ? Colors.white
        : (isDark ? DashboardColors.surfaceDark : const Color(0xFFF8FBFF));
    final border = selected
        ? const Color(0xFFFF5A1F)
        : (isDark ? DashboardColors.borderDark : const Color(0xFFDCE4F0));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: 126,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border, width: selected ? 2 : 1),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: const Color(0xFFFF5A1F).withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        spec.iconColor.withValues(alpha: 0.9),
                        spec.iconColor.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    spec.chipLabel,
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _RevenuePeriodPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isDark;

  const _RevenuePeriodPill({
    required this.label,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFFF5A1F)
            : const Color(0xFF253760).withValues(alpha: isDark ? 0.7 : 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CurrencyTrendChart extends StatelessWidget {
  final List<double> values;
  final Color accent;
  final String peakLabel;
  final int peakIndex;

  const _CurrencyTrendChart({
    required this.values,
    required this.accent,
    required this.peakLabel,
    required this.peakIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (values.isEmpty) return const SizedBox.shrink();
        final safePeakIndex = peakIndex.clamp(0, values.length - 1) as int;
        final peakX =
            (safePeakIndex / (values.length - 1).toDouble()) * constraints.maxWidth;
        final peakY = (1 - values[safePeakIndex]) * constraints.maxHeight;
        const tooltipWidth = 96.0;
        final tooltipLeft =
            (peakX + 8).clamp(0.0, constraints.maxWidth - tooltipWidth);
        final tooltipTop = (peakY - 22).clamp(2.0, constraints.maxHeight - 28);

        return Stack(
          children: [
            Positioned.fill(
              child: TweenAnimationBuilder<double>(
                key: ValueKey(peakLabel),
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 720),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return CustomPaint(
                    painter: _CurrencyTrendPainter(
                      values: values,
                      accent: accent,
                      progress: value,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: tooltipLeft,
              top: tooltipTop,
              child: Container(
                width: tooltipWidth,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2438),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '• Peak: $peakLabel',
                  style: const TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CurrencyTrendPainter extends CustomPainter {
  final List<double> values;
  final Color accent;
  final double progress;

  _CurrencyTrendPainter({
    required this.values,
    required this.accent,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final y = (1 - values[i]) * size.height;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final dx = next.dx - current.dx;
      final cp1 = Offset(current.dx + dx * 0.4, current.dy);
      final cp2 = Offset(next.dx - dx * 0.4, next.dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent.withValues(alpha: 0.32),
          accent.withValues(alpha: 0.08),
          accent.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * progress, size.height));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CurrencyTrendPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accent != accent ||
        oldDelegate.values != values;
  }
}

class _TrendAxisLabel extends StatelessWidget {
  final String label;

  const _TrendAxisLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Color(0xFF9CADC6),
      ),
    );
  }
}

class _CurrencyPerformanceRow extends StatelessWidget {
  final _CurrencyMetric metric;
  final bool isDark;
  final bool highlighted;

  const _CurrencyPerformanceRow({
    required this.metric,
    required this.isDark,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark
        ? DashboardColors.textMainDark
        : const Color(0xFF1B2438);
    final subtitleColor = isDark
        ? DashboardColors.textMutedDark
        : const Color(0xFF7C8AA5);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                metric.spec.iconColor.withValues(alpha: 0.95),
                metric.spec.iconColor.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: metric.spec.iconColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.account_balance, color: Colors.white, size: 15),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${metric.spec.code} Portfolio',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              Text(
                metric.subtitle,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatMoney(metric.totalRevenue, metric.spec.symbol),
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: highlighted
                    ? const Color(0xFFFF5A1F)
                    : (isDark
                        ? DashboardColors.textMainDark
                        : const Color(0xFF475569)),
              ),
            ),
            Text(
              _formatPercent(metric.growthPercent),
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: metric.growthPercent >= 0
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CurrencyDataState extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;

  const _CurrencyDataState({
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark
              ? DashboardColors.surfaceDark
              : DashboardColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? DashboardColors.borderDark
                : DashboardColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.currency_exchange_rounded,
              size: 40,
              color: isDark
                  ? DashboardColors.textMutedDark
                  : DashboardColors.textMutedLight,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? DashboardColors.textMainDark
                    : DashboardColors.textMainLight,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 13,
                color: isDark
                    ? DashboardColors.textMutedDark
                    : DashboardColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySpec {
  final String code;
  final String symbol;
  final Color accent;
  final Color iconColor;

  const _CurrencySpec({
    required this.code,
    required this.symbol,
    required this.accent,
    required this.iconColor,
  });

  String get chipLabel => '$code-$symbol';
}

class _CurrencyMetric {
  final _CurrencySpec spec;
  final int regionCount;
  final List<double> _dailyRevenue = List<double>.filled(7, 0);
  double totalRevenue = 0;
  double currentWeekRevenue = 0;
  double previousWeekRevenue = 0;
  int completedRides = 0;
  DateTime? latestUpdate;

  _CurrencyMetric({
    required this.spec,
    required this.regionCount,
  });

  void registerRide(
    double amount,
    DateTime rideTime,
    DateTime now,
  ) {
    totalRevenue += amount;
    completedRides += 1;
    if (latestUpdate == null || rideTime.isAfter(latestUpdate!)) {
      latestUpdate = rideTime;
    }

    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(rideTime.year, rideTime.month, rideTime.day);
    final daysAgo = today.difference(day).inDays;
    if (daysAgo >= 0 && daysAgo < 7) {
      final index = 6 - daysAgo;
      _dailyRevenue[index] += amount;
      currentWeekRevenue += amount;
    } else if (daysAgo >= 7 && daysAgo < 14) {
      previousWeekRevenue += amount;
    }
  }

  double get growthPercent {
    if (previousWeekRevenue <= 0) return 0;
    return ((currentWeekRevenue - previousWeekRevenue) / previousWeekRevenue) *
        100;
  }

  List<double> get normalizedTrend => _normalizeTrend(_dailyRevenue);

  int get peakIndex {
    var index = 0;
    var best = _dailyRevenue.first;
    for (var i = 1; i < _dailyRevenue.length; i++) {
      if (_dailyRevenue[i] > best) {
        best = _dailyRevenue[i];
        index = i;
      }
    }
    return index;
  }

  String get peakLabel {
    final peak = _dailyRevenue.isEmpty
        ? 0.0
        : _dailyRevenue.reduce((a, b) => a > b ? a : b);
    return _formatCompactMoney(peak, spec.symbol);
  }

  String get updatedLabel => _formatRelativeTime(latestUpdate);

  String get subtitle =>
      'Regions: $regionCount • Completed rides: $completedRides';
}

class _CurrencyPayoutDataset {
  final List<_CurrencySpec> currencies;
  final Map<String, _CurrencyMetric> metrics;

  const _CurrencyPayoutDataset({
    required this.currencies,
    required this.metrics,
  });

  factory _CurrencyPayoutDataset.fromSnapshots({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> regionDocs,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> rideDocs,
    required DateTime now,
  }) {
    final regionCodeById = <String, String>{};
    final regionCodeByName = <String, String>{};
    final regionCountByCurrency = <String, int>{};
    final specsByCode = <String, _CurrencySpec>{};

    for (final doc in regionDocs) {
      final data = doc.data();
      final spec = _extractCurrencySpecFromRegion(data);
      if (spec == null) continue;

      specsByCode.putIfAbsent(spec.code, () => spec);
      regionCodeById[doc.id] = spec.code;
      final regionName = (data['name'] ?? '').toString().trim().toLowerCase();
      if (regionName.isNotEmpty) {
        regionCodeByName.putIfAbsent(regionName, () => spec.code);
      }
      regionCountByCurrency.update(spec.code, (count) => count + 1,
          ifAbsent: () => 1);
    }

    if (specsByCode.isEmpty) {
      return const _CurrencyPayoutDataset(currencies: [], metrics: {});
    }

    final metrics = <String, _CurrencyMetric>{
      for (final entry in specsByCode.entries)
        entry.key: _CurrencyMetric(
          spec: entry.value,
          regionCount: regionCountByCurrency[entry.key] ?? 0,
        ),
    };

    for (final rideDoc in rideDocs) {
      final data = rideDoc.data();
      final currencyCode = _resolveRideCurrencyCode(
        data: data,
        validCodes: specsByCode.keys.toSet(),
        regionCodeById: regionCodeById,
        regionCodeByName: regionCodeByName,
      );
      if (currencyCode == null) continue;

      final amount = _extractRideAmount(data);
      if (amount <= 0) continue;

      final date = _extractRideDate(data);
      metrics[currencyCode]?.registerRide(amount, date, now);
    }

    final currencies = specsByCode.values.toList()
      ..sort((a, b) => a.code.compareTo(b.code));

    return _CurrencyPayoutDataset(
      currencies: currencies,
      metrics: metrics,
    );
  }

  String resolveSelectedCode(String? selected) {
    if (selected != null && metrics.containsKey(selected)) return selected;
    return currencies.first.code;
  }

  List<_CurrencyMetric> performanceFor(String selectedCode) {
    final sorted = metrics.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    sorted.sort((a, b) {
      if (a.spec.code == selectedCode) return -1;
      if (b.spec.code == selectedCode) return 1;
      return b.totalRevenue.compareTo(a.totalRevenue);
    });
    return sorted.take(2).toList();
  }
}

_CurrencySpec? _extractCurrencySpecFromRegion(Map<String, dynamic> data) {
  final candidates = [
    data['currency'],
    data['currencyCode'],
    data['payoutCurrency'],
    data['defaultCurrency'],
    data['regionCurrency'],
  ];

  String? code;
  String? symbol;
  for (final candidate in candidates) {
    final parsed = _parseCurrencyValue(candidate);
    code ??= parsed.$1;
    symbol ??= parsed.$2;
  }
  symbol ??= _parseCurrencyValue(data['currencySymbol']).$2;
  if (code == null || code.isEmpty) return null;

  symbol ??= _currencySymbolForCode(code);
  final palette = _currencyPalette(code);
  return _CurrencySpec(
    code: code,
    symbol: symbol,
    accent: palette.$1,
    iconColor: palette.$2,
  );
}

String? _resolveRideCurrencyCode({
  required Map<String, dynamic> data,
  required Set<String> validCodes,
  required Map<String, String> regionCodeById,
  required Map<String, String> regionCodeByName,
}) {
  final directCandidates = [
    data['currency'],
    data['currencyCode'],
    data['payoutCurrency'],
    data['currencySymbol'],
  ];
  for (final candidate in directCandidates) {
    final parsed = _parseCurrencyValue(candidate);
    final code = parsed.$1;
    if (code != null && validCodes.contains(code)) return code;
  }

  final regionId = (data['regionId'] ?? '').toString().trim();
  if (regionId.isNotEmpty && regionCodeById.containsKey(regionId)) {
    return regionCodeById[regionId];
  }
  final regionName = (data['regionName'] ?? '').toString().trim().toLowerCase();
  if (regionName.isNotEmpty && regionCodeByName.containsKey(regionName)) {
    return regionCodeByName[regionName];
  }
  return null;
}

(String?, String?) _parseCurrencyValue(dynamic value) {
  if (value == null) return (null, null);

  if (value is Map<String, dynamic>) {
    final code = _normalizeCurrencyCode(
      value['code'] ?? value['currencyCode'] ?? value['currency'],
    );
    final symbol = _normalizeCurrencySymbol(
      value['symbol'] ?? value['currencySymbol'],
    );
    if (code != null) {
      return (code, symbol ?? _currencySymbolForCode(code));
    }
    if (symbol != null) {
      final resolvedCode = _currencyCodeForSymbol(symbol);
      return (resolvedCode, symbol);
    }
    return (null, null);
  }

  final raw = value.toString().trim();
  if (raw.isEmpty) return (null, null);

  final codeMatch = RegExp(r'([A-Za-z]{3})').firstMatch(raw);
  final symbolMatch = RegExp(r'[\$€£¥₦₹₵R]').firstMatch(raw);
  final symbol = symbolMatch?.group(0);
  var code = _normalizeCurrencyCode(codeMatch?.group(0));
  if (code == null && symbol != null) {
    code = _currencyCodeForSymbol(symbol);
  }
  if (code == null) return (null, symbol);
  return (code, symbol ?? _currencySymbolForCode(code));
}

String? _normalizeCurrencyCode(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim().toUpperCase();
  if (raw.isEmpty) return null;
  final codeMatch = RegExp(r'[A-Z]{3}').firstMatch(raw);
  return codeMatch?.group(0);
}

String? _normalizeCurrencySymbol(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  final symbolMatch = RegExp(r'[\$€£¥₦₹₵R]').firstMatch(raw);
  return symbolMatch?.group(0);
}

String _currencySymbolForCode(String code) {
  switch (code) {
    case 'USD':
      return '\$';
    case 'EUR':
      return '€';
    case 'GBP':
      return '£';
    case 'JPY':
      return '¥';
    case 'NGN':
      return '₦';
    case 'INR':
      return '₹';
    case 'ZAR':
      return 'R';
    case 'GHS':
      return '₵';
    default:
      return code;
  }
}

String? _currencyCodeForSymbol(String symbol) {
  switch (symbol) {
    case '\$':
      return 'USD';
    case '€':
      return 'EUR';
    case '£':
      return 'GBP';
    case '¥':
      return 'JPY';
    case '₦':
      return 'NGN';
    case '₹':
      return 'INR';
    case 'R':
      return 'ZAR';
    case '₵':
      return 'GHS';
    default:
      return null;
  }
}

(Color, Color) _currencyPalette(String code) {
  switch (code) {
    case 'USD':
      return (const Color(0xFFFF5A1F), const Color(0xFF177245));
    case 'EUR':
      return (const Color(0xFFF97316), const Color(0xFF2E7D32));
    case 'GBP':
      return (const Color(0xFFFB923C), const Color(0xFF5D7F2A));
    case 'NGN':
      return (const Color(0xFF22C55E), const Color(0xFF0E9F6E));
    case 'JPY':
      return (const Color(0xFFEF4444), const Color(0xFF1E3A8A));
    default:
      return (const Color(0xFFFF7A38), const Color(0xFF4F46E5));
  }
}

double _extractRideAmount(Map<String, dynamic> data) {
  final fare = _asDouble(data['fare']) ??
      _asDouble(data['estimatedFare']) ??
      _reconstructRideFare(data);
  return fare > 0 ? fare : 0;
}

double _reconstructRideFare(Map<String, dynamic> data) {
  final baseFare = _asDouble(data['baseFare']) ?? 0;
  final costPerKm = _asDouble(data['costPerKm']) ?? 0;
  final costPerMin = _asDouble(data['costPerMin']) ?? 0;
  final distanceKm = _asDouble(data['distanceKm']) ?? 0;
  final durationMinutes = _asDouble(data['durationMinutes']) ?? 0;
  return baseFare + (costPerKm * distanceKm) + (costPerMin * durationMinutes);
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value == null) return null;
  return double.tryParse(value.toString());
}

DateTime _extractRideDate(Map<String, dynamic> data) {
  final date = _asDate(data['completedAt']) ??
      _asDate(data['updatedAt']) ??
      _asDate(data['createdAt']);
  return date ?? DateTime.now();
}

DateTime? _asDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<double> _normalizeTrend(List<double> values) {
  if (values.isEmpty) return const [];
  var min = values.first;
  var max = values.first;
  for (final value in values) {
    if (value < min) min = value;
    if (value > max) max = value;
  }

  if ((max - min).abs() < 0.0001) {
    return List<double>.filled(values.length, 0.28);
  }
  return values
      .map((value) => 0.16 + ((value - min) / (max - min)) * 0.70)
      .toList();
}

(String, String) _moneyParts(double amount) {
  final cents = (amount.abs() * 100).round();
  final whole = cents ~/ 100;
  final decimal = (cents % 100).toString().padLeft(2, '0');
  return (_withThousands(whole), '.$decimal');
}

String _formatMoney(double amount, String symbol) {
  final parts = _moneyParts(amount);
  return '$symbol${parts.$1}${parts.$2}';
}

String _formatCompactMoney(double amount, String symbol) {
  final abs = amount.abs();
  if (abs >= 1000000) {
    return '$symbol${(amount / 1000000).toStringAsFixed(1)}m';
  }
  if (abs >= 1000) {
    return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
  }
  return _formatMoney(amount, symbol);
}

String _withThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final reverseIndex = digits.length - i;
    buffer.write(digits[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write(',');
    }
  }
  return buffer.toString();
}

String _formatPercent(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(1)}%';
}

String _formatRelativeTime(DateTime? dateTime) {
  if (dateTime == null) return 'No updates';
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inSeconds < 60) return 'Updated now';
  if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
  if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
  if (diff.inDays < 7) return 'Updated ${diff.inDays}d ago';
  return 'Updated ${dateTime.month}/${dateTime.day}';
}

class ScheduledRideCard extends StatelessWidget {
  final ScheduleModel schedule;
  final DriverModel? driver;
  final bool isDark;

  const ScheduledRideCard({
    super.key,
    required this.schedule,
    required this.driver,
    required this.isDark,
  });

  String _formatTime(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _formatDate(DateTime value) {
    const monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${monthNames[value.month]} ${value.day}';
  }

  String _scheduleWindow() {
    final sameDay = schedule.startTime.year == schedule.endTime.year &&
        schedule.startTime.month == schedule.endTime.month &&
        schedule.startTime.day == schedule.endTime.day;
    if (sameDay) {
      return '${_formatDate(schedule.startTime)} - ${_formatTime(schedule.startTime)} to ${_formatTime(schedule.endTime)}';
    }
    return '${_formatDate(schedule.startTime)} ${_formatTime(schedule.startTime)} to ${_formatDate(schedule.endTime)} ${_formatTime(schedule.endTime)}';
  }

  String _statusLabel() {
    final now = DateTime.now();
    if (now.isBefore(schedule.startTime)) return 'Upcoming';
    if (now.isAfter(schedule.endTime)) return 'Completed';
    return 'In Progress';
  }

  Color _statusColor() {
    final status = _statusLabel();
    if (status == 'In Progress') return Colors.green;
    if (status == 'Completed') return Colors.grey;
    return DashboardColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final driverName = driver?.name ?? schedule.driverName;
    final vehicleText = driver?.vehicleDisplay.trim().isNotEmpty == true
        ? driver!.vehicleDisplay
        : 'Vehicle details unavailable';
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? DashboardColors.borderDark : DashboardColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: driver != null && driver!.photoUrl.trim().isNotEmpty
                    ? Image.network(
                        driver!.photoUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                DashboardColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person,
                              color: DashboardColors.primary),
                        ),
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color:
                              DashboardColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            const Icon(Icons.person, color: DashboardColors.primary),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName.trim().isEmpty ? 'Unknown Driver' : driverName,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? DashboardColors.textMainDark
                            : DashboardColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicleText,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        color: isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? DashboardColors.borderDark : DashboardColors.borderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: isDark
                          ? DashboardColors.textMutedDark
                          : DashboardColors.textMutedLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _scheduleWindow(),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? DashboardColors.textMutedDark
                              : DashboardColors.textMutedLight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark
                          ? DashboardColors.textMutedDark
                          : DashboardColors.textMutedLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        schedule.regionName.trim().isEmpty
                            ? 'Region not set'
                            : schedule.regionName,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? DashboardColors.textMutedDark
                              : DashboardColors.textMutedLight,
                        ),
                      ),
                    ),
                    Text(
                      schedule.shiftType.toUpperCase(),
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommissionSection extends StatefulWidget {
  final bool isDark;

  const CommissionSection({super.key, required this.isDark});

  @override
  State<CommissionSection> createState() => _CommissionSectionState();
}

class _CommissionSectionState extends State<CommissionSection> {
  int _selectedChip = 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: widget.isDark
                  ? DashboardColors.textMainDark
                  : DashboardColors.textMainLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: const Text('Overview'),
                selected: _selectedChip == 0,
                onSelected: (_) => setState(() => _selectedChip = 0),
              ),
              ChoiceChip(
                label: const Text('By Driver'),
                selected: _selectedChip == 1,
                onSelected: (_) => setState(() => _selectedChip = 1),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<CommissionSummary>(
            stream: context.read<RideService>().watchCommissionSummary(),
            builder: (context, snapshot) {
              final summary = snapshot.data;
              final total = summary?.platformCommission ?? 0.0;
              final rides = summary?.completedRides ?? 0;
              final drivers = summary?.activeDriversWithCommission ?? 0;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? DashboardColors.surfaceDark
                      : DashboardColors.surfaceLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isDark
                        ? DashboardColors.borderDark
                        : DashboardColors.borderLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Commission Earned',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: DashboardColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$rides completed rides • $drivers drivers',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        color: widget.isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (_selectedChip == 1)
            StreamBuilder<List<DriverCommissionSummary>>(
              stream:
                  context.read<RideService>().watchDriverCommissionBreakdown(),
              builder: (context, snapshot) {
                final items =
                    snapshot.data ?? const <DriverCommissionSummary>[];
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No completed rides for commission breakdown yet.',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 13,
                        color: widget.isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                    ),
                  );
                }

                return Column(
                  children: items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? DashboardColors.surfaceDark
                            : DashboardColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.isDark
                              ? DashboardColors.borderDark
                              : DashboardColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.driverName,
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: widget.isDark
                                        ? DashboardColors.textMainDark
                                        : DashboardColors.textMainLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.completedRides} completed rides',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 12,
                                    color: widget.isDark
                                        ? DashboardColors.textMutedDark
                                        : DashboardColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.commission.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: DashboardColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Driver Card
class DriverCard extends StatelessWidget {
  final DriverModel driver;
  final bool isDark;

  const DriverCard({
    super.key,
    required this.driver,
    required this.isDark,
  });

  void _navigateToDetails(BuildContext context) {
    context.push(AppRoutes.driverDetails, extra: driver);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? DashboardColors.surfaceDark
              : DashboardColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? DashboardColors.borderDark
                : DashboardColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver image with status
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        driver.photoUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color:
                                DashboardColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person,
                              color: DashboardColors.primary),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: driver.isOnline
                          ? const PulsingIndicator()
                          : Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: driver.isOnBreak
                                    ? Colors.amber
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? DashboardColors.surfaceDark
                                      : DashboardColors.surfaceLight,
                                  width: 2,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Driver info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? DashboardColors.textMainDark
                              : DashboardColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        driver.vehicleDisplay,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          color: isDark
                              ? DashboardColors.textMutedDark
                              : DashboardColors.textMutedLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            driver.rating.toString(),
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? DashboardColors.textMainDark
                                  : DashboardColors.textMainLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${driver.formattedRides} rides)',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 10,
                              color: isDark
                                  ? DashboardColors.textMutedDark
                                  : DashboardColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron button
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF374151)
                        : const Color(0xFFF9FAFB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: isDark
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider and location
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? DashboardColors.borderDark
                        : DashboardColors.borderLight,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        driver.isOnBreak ? Icons.schedule : Icons.location_on,
                        size: 14,
                        color: isDark
                            ? DashboardColors.textMutedDark
                            : DashboardColors.textMutedLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        driver.isOnBreak ? 'On Break' : driver.location,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? DashboardColors.textMutedDark
                              : DashboardColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _navigateToDetails(context),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DashboardColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing Online Indicator
class PulsingIndicator extends StatefulWidget {
  const PulsingIndicator({super.key});

  @override
  State<PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<PulsingIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.33, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        _controller == null ||
        _scaleAnimation == null ||
        _opacityAnimation == null) {
      return Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: DashboardColors.primary,
          shape: BoxShape.circle,
        ),
      );
    }

    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation!.value,
                child: Opacity(
                  opacity: _opacityAnimation!.value,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: DashboardColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: DashboardColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
