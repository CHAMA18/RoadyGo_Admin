import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/driver_model.dart';
import 'package:roadygo_admin/models/activity_model.dart';
import 'package:roadygo_admin/pages/admin_dashboard_page.dart';
import 'package:roadygo_admin/services/driver_service.dart';

const String _fontFamily = 'Satoshi';

/// Driver Details page
class DriverDetailsPage extends StatefulWidget {
  final DriverModel driver;

  const DriverDetailsPage({super.key, required this.driver});

  @override
  State<DriverDetailsPage> createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  List<ActivityModel> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final driverService = context.read<DriverService>();
    final activities = await driverService.getDriverActivities(widget.driver.id);
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DashboardColors.backgroundDark : DashboardColors.backgroundLight,
      body: Column(
        children: [
          // Header
          DriverDetailsHeader(isDark: isDark),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile image with overlay
                        DriverProfileImage(driver: widget.driver, isDark: isDark),
                        const SizedBox(height: 16),

                        // Vehicle info card
                        VehicleInfoCard(
                          vehicleName: '${widget.driver.vehicleMake} ${widget.driver.vehicleModel}',
                          vehicleColor: widget.driver.vehicleColor,
                          plateNumber: widget.driver.licensePlate,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 16),

                        // Float balance card
                        FloatBalanceCard(
                          balance: widget.driver.floatBalance,
                          driverId: widget.driver.id,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),

                        // Action buttons
                        ActionButtonsRow(phone: widget.driver.phone, isDark: isDark),
                        const SizedBox(height: 32),

                        // Activity history section
                        Text(
                          context.tr('Activity History'),
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Activity list
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_activities.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.history,
                                    size: 48,
                                    color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No activity history',
                                    style: TextStyle(
                                      fontFamily: _fontFamily,
                                      fontSize: 16,
                                      color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._activities.map((activity) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ActivityCard(activity: activity, isDark: isDark),
                          )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Driver Details Header
class DriverDetailsHeader extends StatelessWidget {
  final bool isDark;

  const DriverDetailsHeader({super.key, required this.isDark});

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
          // Back button
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
              ),
            ),
          ),

          // Title
          Text(
            context.tr('Driver Details'),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
              letterSpacing: -0.5,
            ),
          ),

          // More options button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.more_vert,
              size: 20,
              color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Driver Profile Image with overlay
class DriverProfileImage extends StatelessWidget {
  final DriverModel driver;
  final bool isDark;

  const DriverProfileImage({super.key, required this.driver, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            Image.network(
              driver.photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: DashboardColors.primary.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 80, color: DashboardColors.primary),
              ),
            ),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),

            // Content overlay
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Name and phone
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: const TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        driver.phone,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  // Rating badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          driver.rating.toString(),
                          style: const TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

/// Vehicle Info Card
class VehicleInfoCard extends StatelessWidget {
  final String vehicleName;
  final String vehicleColor;
  final String plateNumber;
  final bool isDark;

  const VehicleInfoCard({
    super.key,
    required this.vehicleName,
    required this.vehicleColor,
    required this.plateNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DashboardColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.electric_car,
              color: DashboardColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Vehicle info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$vehicleColor • ',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 12,
                        color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                      ),
                    ),
                    Text(
                      plateNumber,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
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

/// Float Balance Card
class FloatBalanceCard extends StatelessWidget {
  final double balance;
  final String driverId;
  final bool isDark;

  const FloatBalanceCard({
    super.key,
    required this.balance,
    required this.driverId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Balance info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FLOAT BALANCE',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${balance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                ),
              ),
            ],
          ),

          // Add funds button
          GestureDetector(
            onTap: () => _showAddFundsDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: DashboardColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: DashboardColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Text(
                context.tr('Add Funds'),
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('Add Funds')),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: context.tr('Amount'),
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await context.read<DriverService>().addFunds(driverId, amount);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(context.tr('Add')),
          ),
        ],
      ),
    );
  }
}

/// Action Buttons Row
class ActionButtonsRow extends StatelessWidget {
  final String phone;
  final bool isDark;

  const ActionButtonsRow({super.key, required this.phone, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Call Driver button
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Call driver action
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DashboardColors.primary,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.call,
                    color: DashboardColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('Call Driver'),
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: DashboardColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Message button
        Expanded(
          child: GestureDetector(
            onTap: () {
              // Message action
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: DashboardColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: DashboardColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('Message'),
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Activity Card
class ActivityCard extends StatelessWidget {
  final ActivityModel activity;
  final bool isDark;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = _getStatusColors(activity.statusText);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? DashboardColors.surfaceDark : DashboardColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
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
      child: Row(
        children: [
          // Status icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColors.backgroundColor.withValues(alpha: isDark ? 0.3 : 1.0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusColors.icon,
              color: statusColors.iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.formattedDateTime,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 10,
                    color: isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),

          // Amount and status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${activity.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: activity.status == ActivityStatus.cancelled
                      ? (isDark ? DashboardColors.textMutedDark : DashboardColors.textMutedLight)
                      : (isDark ? DashboardColors.textMainDark : DashboardColors.textMainLight),
                  decoration: activity.status == ActivityStatus.cancelled ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColors.badgeBackground.withValues(alpha: isDark ? 0.2 : 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _capitalizeFirst(activity.statusText),
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: statusColors.badgeText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _StatusColors _getStatusColors(String status) {
    switch (status) {
      case 'completed':
        return _StatusColors(
          icon: Icons.check_circle,
          iconColor: const Color(0xFF249689),
          backgroundColor: const Color(0xFF249689).withValues(alpha: 0.15),
          badgeBackground: const Color(0xFF249689).withValues(alpha: 0.1),
          badgeText: const Color(0xFF249689),
        );
      case 'scheduled':
        return _StatusColors(
          icon: Icons.schedule,
          iconColor: const Color(0xFFF9CF58),
          backgroundColor: const Color(0xFFF9CF58).withValues(alpha: 0.15),
          badgeBackground: const Color(0xFFF9CF58).withValues(alpha: 0.1),
          badgeText: const Color(0xFFF59E0B),
        );
      case 'cancelled':
        return _StatusColors(
          icon: Icons.cancel,
          iconColor: const Color(0xFFFF5963),
          backgroundColor: const Color(0xFFFF5963).withValues(alpha: 0.15),
          badgeBackground: const Color(0xFFFF5963).withValues(alpha: 0.1),
          badgeText: const Color(0xFFFF5963),
        );
      default:
        return _StatusColors(
          icon: Icons.help,
          iconColor: Colors.grey.shade600,
          backgroundColor: Colors.grey.shade100,
          badgeBackground: Colors.grey.shade50,
          badgeText: Colors.grey.shade500,
        );
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _StatusColors {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color badgeBackground;
  final Color badgeText;

  _StatusColors({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.badgeBackground,
    required this.badgeText,
  });
}
