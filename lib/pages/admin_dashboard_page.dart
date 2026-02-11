import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/nav.dart';
import 'package:roadygo_admin/pages/rides_section.dart';
import 'package:roadygo_admin/services/driver_service.dart';
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

  final List<String> _tabs = ['Riders', 'Regions', 'Admins', 'Schedules'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriverService>().fetchOnlineDrivers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? DashboardColors.backgroundDark : DashboardColors.backgroundLight,
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
                        onTabSelected: (index) => setState(() => _selectedTabIndex = index),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      
                      // Content based on selected tab
                      if (_selectedTabIndex == 0)
                        RidesSection(isDark: isDark)
                      else ...[
                        // Online Drivers section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Online Drivers',
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'See All',
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
                        
                        // Driver cards from Firestore
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
                                      'Failed to load drivers',
                                      style: TextStyle(
                                        color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton(
                                      onPressed: () => driverService.fetchOnlineDrivers(),
                                      child: const Text('Retry'),
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
                                        color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No drivers online',
                                        style: TextStyle(
                                          fontFamily: _fontFamily,
                                          fontSize: 16,
                                          color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
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
                                children: drivers.map((driver) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DriverCard(driver: driver, isDark: isDark),
                                )).toList(),
                              ),
                            );
                          },
                        ),
                      ],
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
        color: (isDark ? DashboardColors.backgroundDark : DashboardColors.backgroundLight).withValues(alpha: 0.9),
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
                  color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Fleet Overview',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
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
                    border: Border.all(color: DashboardColors.primary, width: 2),
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
                        child: const Icon(Icons.person, color: DashboardColors.primary),
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
                        color: isDark ? DashboardColors.backgroundDark : DashboardColors.backgroundLight,
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
class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StreamBuilder<int>(
        stream: context.read<DriverService>().watchActiveDriverCount(),
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          // Calculate change percentage (mock for now, could be stored/computed)
          final change = count > 0 ? '12%' : '0%';
          
          return StatCard(
            icon: Icons.directions_car,
            label: 'Active Drivers',
            value: count.toString(),
            change: change,
            isDark: isDark,
            isLoading: snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData,
          );
        },
      ),
    );
  }
}

/// Stat Card
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String change;
  final bool isDark;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.change,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? DashboardColors.borderDark : DashboardColors.borderLight,
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
                    color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
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
                        color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                      ),
                    ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green, size: 10),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.green,
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
                    : (isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight),
                borderRadius: BorderRadius.circular(16),
                border: isSelected 
                    ? null 
                    : Border.all(color: isDark ? DashboardColors.borderDark : DashboardColors.borderLight),
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
                      : (isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight),
                ),
              ),
            ),
          );
        },
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
        color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? DashboardColors.borderDark : DashboardColors.borderLight,
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
                          color: DashboardColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person, color: DashboardColors.primary),
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
                              color: driver.isOnBreak ? Colors.amber : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
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
                        color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      driver.vehicleDisplay,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
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
                            color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${driver.formattedRides} rides)',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 10,
                            color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
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
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
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
                  color: isDark ? DashboardColors.borderDark : DashboardColors.borderLight,
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
                      color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      driver.isOnBreak ? 'On Break' : driver.location,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.33, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
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
