import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/region_model.dart';
import 'package:roadygo_admin/nav.dart';
import 'package:roadygo_admin/services/region_service.dart';
import 'package:roadygo_admin/theme.dart';

const String _fontFamily = 'Satoshi';

/// Regions Section for displaying region statistics and configuration
class RegionsSection extends StatefulWidget {
  final bool isDark;

  const RegionsSection({super.key, required this.isDark});

  @override
  State<RegionsSection> createState() => _RegionsSectionState();
}

class _RegionsSectionState extends State<RegionsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegionService>().fetchRegions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RegionService>(
      builder: (context, regionService, _) {
        final regions = regionService.regions;
        final isLoading = regionService.isLoading;
        final error = regionService.error;

        // Use computed statistics from Firestore data
        final totalRegions = regionService.totalConfiguredRegions;
        final activeRegions = regionService.totalActiveRegions;
        final totalActiveDrivers = regionService.totalDriversAcrossRegions;
        final totalRides = regionService.totalRidesAcrossRegions;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Region Stats Summary
              RegionStatsCard(
                totalRegions: totalRegions,
                activeRegions: activeRegions,
                totalDrivers: totalActiveDrivers,
                totalRides: totalRides,
                isDark: widget.isDark,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),

              // Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('Configured Regions'),
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.editRegion),
                    icon: Icon(Icons.add, size: 18, color: AppColors.primary),
                    label: Text(
                      context.tr('Add New'),
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Content based on state
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null)
                _ErrorWidget(
                  error: error,
                  onRetry: () => regionService.fetchRegions(),
                  isDark: widget.isDark,
                )
              else if (regions.isEmpty)
                _EmptyRegionsWidget(isDark: widget.isDark)
              else
                Column(
                  children: regions.map((region) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RegionCard(region: region, isDark: widget.isDark),
                  )).toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Region Stats Card showing overall region configuration summary
class RegionStatsCard extends StatelessWidget {
  final int totalRegions;
  final int activeRegions;
  final int totalDrivers;
  final int totalRides;
  final bool isDark;
  final bool isLoading;

  const RegionStatsCard({
    super.key,
    required this.totalRegions,
    required this.activeRegions,
    required this.totalDrivers,
    required this.totalRides,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary;
    final borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textMain = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.map_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REGIONS SETUP',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '$totalRegions Regions Configured',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textMain,
                            ),
                          ),
                  ],
                ),
              ),
              if (!isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '$activeRegions Active',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!isLoading) ...[
            const SizedBox(height: 20),
            Divider(color: borderColor, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatItem(
                  icon: Icons.person,
                  label: 'Total Drivers',
                  value: _formatNumber(totalDrivers),
                  isDark: isDark,
                ),
                const SizedBox(width: 24),
                _StatItem(
                  icon: Icons.directions_car,
                  label: 'Total Rides',
                  value: _formatNumber(totalRides),
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMain = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: textMuted),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 10,
                  color: textMuted,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textMain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual Region Card
class RegionCard extends StatelessWidget {
  final RegionModel region;
  final bool isDark;

  const RegionCard({
    super.key,
    required this.region,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary;
    final borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textMain = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.editRegion, extra: region),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Region Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 14),

                // Region Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              region.name,
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textMain,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: region.isActive
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              region.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: region.isActive ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        region.description.isNotEmpty ? region.description : 'No description',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          color: textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, size: 14, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${region.activeDrivers} drivers',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.directions_car, size: 14, color: textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${_formatNumber(region.totalRides)} rides',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 11,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
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

            // Pricing Summary
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  _PricingChip(
                    label: 'Base',
                    value: '\$${region.costOfRide.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _PricingChip(
                    label: 'Per Km',
                    value: '\$${region.costPerKm.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _PricingChip(
                    label: 'Per Min',
                    value: '\$${region.costPerMin.toStringAsFixed(2)}',
                    isDark: isDark,
                  ),
                  const Spacer(),
                  Text(
                    'Edit Pricing',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _PricingChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _PricingChip({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);
    final textMuted = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textMain = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 9,
              color: textMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorWidget({
    required this.error,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.lightError,
          ),
          const SizedBox(height: 16),
          Text(
            context.tr('Failed to load regions'),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(context.tr('Retry')),
          ),
        ],
      ),
    );
  }
}

class _EmptyRegionsWidget extends StatelessWidget {
  final bool isDark;

  const _EmptyRegionsWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No regions configured',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first region to start\nmanaging area-based pricing',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.editRegion),
              icon: const Icon(Icons.add),
              label: Text(context.tr('Add Region')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
