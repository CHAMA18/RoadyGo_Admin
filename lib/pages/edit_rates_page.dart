import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/models/rate_model.dart';
import 'package:roadygo_admin/services/rate_service.dart';
import 'package:roadygo_admin/theme.dart';

const String _fontFamily = 'Satoshi';

/// Edit Rates Page for RoadyGo Admin
class EditRatesPage extends StatefulWidget {
  const EditRatesPage({super.key});

  @override
  State<EditRatesPage> createState() => _EditRatesPageState();
}

class _EditRatesPageState extends State<EditRatesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rateService = context.read<RateService>();
      rateService.fetchRates();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          _EditRatesHeader(isDark: isDark),
          Expanded(
            child: Consumer<RateService>(
              builder: (context, rateService, _) {
                if (rateService.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (rateService.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: isDark ? AppColors.darkError : AppColors.lightError,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          rateService.error!,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => rateService.fetchRates(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final rates = rateService.rates;

                if (rates.isEmpty) {
                  return _EmptyRatesState(isDark: isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rates.length,
                  itemBuilder: (context, index) {
                    return _RateCard(
                      rate: rates[index],
                      isDark: isDark,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRateDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _RateFormDialog(),
    );
  }
}

/// Header with back button
class _EditRatesHeader extends StatelessWidget {
  final bool isDark;

  const _EditRatesHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary)
            .withValues(alpha: 0.8),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_ios,
                size: 20,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Edit Rates',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// Empty state widget
class _EmptyRatesState extends StatelessWidget {
  final bool isDark;

  const _EmptyRatesState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.attach_money,
            size: 64,
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
          ),
          const SizedBox(height: 16),
          Text(
            'No rates configured',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new rate',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rate card widget
class _RateCard extends StatelessWidget {
  final RateModel rate;
  final bool isDark;

  const _RateCard({required this.rate, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getFleetColor(rate.fleetClass).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getFleetColor(rate.fleetClass).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getFleetIcon(rate.fleetClass),
                    color: _getFleetColor(rate.fleetClass),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.fleetClass,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        rate.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          color: rate.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditDialog(context),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(context),
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDark ? AppColors.darkError : AppColors.lightError,
                  ),
                ),
              ],
            ),
          ),
          
          // Rate details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RateDetailRow(
                  label: 'Base Fare',
                  value: '\$${rate.baseFare.toStringAsFixed(2)}',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _RateDetailRow(
                  label: 'Per Kilometer',
                  value: '\$${rate.perKmRate.toStringAsFixed(2)}/km',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _RateDetailRow(
                  label: 'Per Minute',
                  value: '\$${rate.perMinuteRate.toStringAsFixed(2)}/min',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _RateDetailRow(
                  label: 'Minimum Fare',
                  value: '\$${rate.minimumFare.toStringAsFixed(2)}',
                  isDark: isDark,
                ),
                const SizedBox(height: 12),
                _RateDetailRow(
                  label: 'Booking Fee',
                  value: '\$${rate.bookingFee.toStringAsFixed(2)}',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFleetColor(String fleetClass) {
    switch (fleetClass.toLowerCase()) {
      case 'standard':
        return Colors.blue;
      case 'premium':
        return Colors.orange;
      case 'luxury':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getFleetIcon(String fleetClass) {
    switch (fleetClass.toLowerCase()) {
      case 'standard':
        return Icons.directions_car;
      case 'premium':
        return Icons.directions_car_filled;
      case 'luxury':
        return Icons.local_taxi;
      default:
        return Icons.directions_car;
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _RateFormDialog(rate: rate),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Rate',
          style: TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete the ${rate.fleetClass} rate?',
          style: TextStyle(
            fontFamily: _fontFamily,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: _fontFamily,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<RateService>().deleteRate(rate.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightError,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete', style: TextStyle(fontFamily: _fontFamily)),
          ),
        ],
      ),
    );
  }
}

/// Rate detail row
class _RateDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _RateDetailRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

/// Rate form dialog for add/edit
class _RateFormDialog extends StatefulWidget {
  final RateModel? rate;

  const _RateFormDialog({this.rate});

  @override
  State<_RateFormDialog> createState() => _RateFormDialogState();
}

class _RateFormDialogState extends State<_RateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fleetClassController;
  late TextEditingController _baseFareController;
  late TextEditingController _perKmRateController;
  late TextEditingController _perMinuteRateController;
  late TextEditingController _minimumFareController;
  late TextEditingController _bookingFeeController;
  bool _isActive = true;
  bool _isSaving = false;

  bool get isEditing => widget.rate != null;

  @override
  void initState() {
    super.initState();
    _fleetClassController = TextEditingController(text: widget.rate?.fleetClass ?? '');
    _baseFareController = TextEditingController(text: widget.rate?.baseFare.toString() ?? '');
    _perKmRateController = TextEditingController(text: widget.rate?.perKmRate.toString() ?? '');
    _perMinuteRateController = TextEditingController(text: widget.rate?.perMinuteRate.toString() ?? '');
    _minimumFareController = TextEditingController(text: widget.rate?.minimumFare.toString() ?? '');
    _bookingFeeController = TextEditingController(text: widget.rate?.bookingFee.toString() ?? '');
    _isActive = widget.rate?.isActive ?? true;
  }

  @override
  void dispose() {
    _fleetClassController.dispose();
    _baseFareController.dispose();
    _perKmRateController.dispose();
    _perMinuteRateController.dispose();
    _minimumFareController.dispose();
    _bookingFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AlertDialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        isEditing ? 'Edit Rate' : 'Add New Rate',
        style: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      content: SizedBox(
        width: 320,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: _fleetClassController,
                  label: 'Fleet Class',
                  hint: 'e.g., Standard, Premium, Luxury',
                  isDark: isDark,
                  labelColor: labelColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _baseFareController,
                  label: 'Base Fare (\$)',
                  hint: '0.00',
                  isDark: isDark,
                  labelColor: labelColor,
                  textColor: textColor,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _perKmRateController,
                  label: 'Per Kilometer (\$)',
                  hint: '0.00',
                  isDark: isDark,
                  labelColor: labelColor,
                  textColor: textColor,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _perMinuteRateController,
                  label: 'Per Minute (\$)',
                  hint: '0.00',
                  isDark: isDark,
                  labelColor: labelColor,
                  textColor: textColor,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _minimumFareController,
                  label: 'Minimum Fare (\$)',
                  hint: '0.00',
                  isDark: isDark,
                  labelColor: labelColor,
                  textColor: textColor,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bookingFeeController,
                  label: 'Booking Fee (\$)',
                  hint: '0.00',
                  isDark: isDark,
                  labelColor: labelColor,
                  textColor: textColor,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Active',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14,
                        color: labelColor,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: _fontFamily,
              color: labelColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveRate,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isEditing ? 'Update' : 'Add',
                  style: const TextStyle(fontFamily: _fontFamily),
                ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    required Color labelColor,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: _fontFamily,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: labelColor,
        ),
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: labelColor.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Future<void> _saveRate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final rateService = context.read<RateService>();
    final now = DateTime.now();

    final rate = RateModel(
      id: widget.rate?.id ?? '',
      fleetClass: _fleetClassController.text.trim(),
      baseFare: double.tryParse(_baseFareController.text) ?? 0.0,
      perKmRate: double.tryParse(_perKmRateController.text) ?? 0.0,
      perMinuteRate: double.tryParse(_perMinuteRateController.text) ?? 0.0,
      minimumFare: double.tryParse(_minimumFareController.text) ?? 0.0,
      bookingFee: double.tryParse(_bookingFeeController.text) ?? 0.0,
      isActive: _isActive,
      createdAt: widget.rate?.createdAt ?? now,
      updatedAt: now,
    );

    bool success;
    if (isEditing) {
      success = await rateService.updateRate(rate);
    } else {
      final id = await rateService.createRate(rate);
      success = id != null;
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context);
      }
    }
  }
}
