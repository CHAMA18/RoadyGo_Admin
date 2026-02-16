import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/rate_model.dart';
import 'package:roadygo_admin/services/rate_service.dart';
import 'package:roadygo_admin/theme.dart';

const String _fontFamily = 'Satoshi';
const List<String> _towFleetClasses = ['Car Tow', 'Truck Tow'];

String _normalizeFleetClass(String fleetClass) {
  final normalized = fleetClass.trim().toLowerCase();
  if (normalized == 'car tow' ||
      normalized == 'car tow pricing' ||
      normalized == 'standard') {
    return 'Car Tow';
  }
  if (normalized == 'truck tow' ||
      normalized == 'truck tow pricing' ||
      normalized == 'corporate' ||
      normalized == 'premium' ||
      normalized == 'luxury') {
    return 'Truck Tow';
  }
  return fleetClass.trim();
}

List<RateModel> _towRatesOnly(List<RateModel> rates) {
  final byFleetClass = <String, RateModel>{};
  for (final rate in rates) {
    final fleetClass = _normalizeFleetClass(rate.fleetClass);
    if (!_towFleetClasses.contains(fleetClass)) continue;
    final normalizedRate = rate.fleetClass == fleetClass
        ? rate
        : rate.copyWith(fleetClass: fleetClass);
    final existing = byFleetClass[fleetClass];
    if (existing == null ||
        normalizedRate.updatedAt.isAfter(existing.updatedAt)) {
      byFleetClass[fleetClass] = normalizedRate;
    }
  }
  return _towFleetClasses
      .where(byFleetClass.containsKey)
      .map((fleetClass) => byFleetClass[fleetClass]!)
      .toList();
}

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
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                          color: isDark
                              ? AppColors.darkError
                              : AppColors.lightError,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          rateService.error!,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => rateService.fetchRates(),
                          child: Text(context.tr('Retry')),
                        ),
                      ],
                    ),
                  );
                }

                final rates = _towRatesOnly(rateService.rates);

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
      floatingActionButton: Consumer<RateService>(
        builder: (context, rateService, _) {
          final rates = _towRatesOnly(rateService.rates);
          if (rates.length >= _towFleetClasses.length) {
            return const SizedBox.shrink();
          }
          final existingClasses = rates.map((rate) => rate.fleetClass).toSet();
          final missingClass = _towFleetClasses.firstWhere(
            (fleetClass) => !existingClasses.contains(fleetClass),
            orElse: () => _towFleetClasses.first,
          );
          return FloatingActionButton(
            onPressed: () => _showAddRateDialog(
              context,
              presetFleetClass: missingClass,
            ),
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  void _showAddRateDialog(
    BuildContext context, {
    String? presetFleetClass,
  }) {
    showDialog(
      context: context,
      builder: (context) => _RateFormDialog(
        presetFleetClass: presetFleetClass,
      ),
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
        color: (isDark
                ? AppColors.darkBackgroundSecondary
                : AppColors.lightBackgroundSecondary)
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
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                context.tr('Edit Rates'),
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
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
            context.tr('No rates configured'),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Tap the + button to add a new rate'),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
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
        color: isDark
            ? AppColors.darkBackgroundSecondary
            : AppColors.lightBackgroundSecondary,
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
                    color:
                        _getFleetColor(rate.fleetClass).withValues(alpha: 0.2),
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
                        _normalizeFleetClass(rate.fleetClass),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        rate.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          color: rate.isActive
                              ? AppColors.primary
                              : AppColors.lightError,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditDialog(context),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
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
    switch (_normalizeFleetClass(fleetClass).toLowerCase()) {
      case 'car tow':
        return AppColors.primary;
      case 'truck tow':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getFleetIcon(String fleetClass) {
    switch (_normalizeFleetClass(fleetClass).toLowerCase()) {
      case 'car tow':
        return Icons.directions_car;
      case 'truck tow':
        return Icons.local_shipping;
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
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}

/// Rate form dialog for add/edit
class _RateFormDialog extends StatefulWidget {
  final RateModel? rate;
  final String? presetFleetClass;

  const _RateFormDialog({this.rate, this.presetFleetClass});

  @override
  State<_RateFormDialog> createState() => _RateFormDialogState();
}

class _RateFormDialogState extends State<_RateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedFleetClass;
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
    _selectedFleetClass = _normalizeFleetClass(
      widget.rate?.fleetClass ??
          widget.presetFleetClass ??
          _towFleetClasses.first,
    );
    if (!_towFleetClasses.contains(_selectedFleetClass)) {
      _selectedFleetClass = _towFleetClasses.first;
    }
    _baseFareController =
        TextEditingController(text: widget.rate?.baseFare.toString() ?? '');
    _perKmRateController =
        TextEditingController(text: widget.rate?.perKmRate.toString() ?? '');
    _perMinuteRateController = TextEditingController(
        text: widget.rate?.perMinuteRate.toString() ?? '');
    _minimumFareController =
        TextEditingController(text: widget.rate?.minimumFare.toString() ?? '');
    _bookingFeeController =
        TextEditingController(text: widget.rate?.bookingFee.toString() ?? '');
    _isActive = widget.rate?.isActive ?? true;
  }

  @override
  void dispose() {
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
    final backgroundColor = isDark
        ? AppColors.darkBackgroundSecondary
        : AppColors.lightBackgroundSecondary;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

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
                DropdownButtonFormField<String>(
                  initialValue: _selectedFleetClass,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Select Tow Type',
                    labelStyle: TextStyle(
                      fontFamily: _fontFamily,
                      color: labelColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.darkLine : AppColors.lightLine,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color:
                            isDark ? AppColors.darkLine : AppColors.lightLine,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items: _towFleetClasses
                      .map((fleetClass) => DropdownMenuItem<String>(
                            value: fleetClass,
                            child: Text(
                              fleetClass,
                              style: const TextStyle(fontFamily: _fontFamily),
                            ),
                          ))
                      .toList(),
                  onChanged: isEditing
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _selectedFleetClass = value);
                        },
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
            context.tr('Cancel'),
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
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

    if (!isEditing) {
      final alreadyExists = _towRatesOnly(rateService.rates).any(
        (rate) => _normalizeFleetClass(rate.fleetClass) == _selectedFleetClass,
      );
      if (alreadyExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('$_selectedFleetClass pricing already exists.')),
        );
        setState(() => _isSaving = false);
        return;
      }
    }

    final rate = RateModel(
      id: widget.rate?.id ?? '',
      fleetClass: _selectedFleetClass,
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
