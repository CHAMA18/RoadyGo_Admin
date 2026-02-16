import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/models/region_model.dart';
import 'package:roadygo_admin/services/region_service.dart';
import 'package:roadygo_admin/theme.dart';

const String _fontFamily = 'Satoshi';

/// Edit Region Page for modifying regional pricing
class EditRegionPage extends StatefulWidget {
  final RegionModel? region;

  const EditRegionPage({super.key, this.region});

  @override
  State<EditRegionPage> createState() => _EditRegionPageState();
}

class _EditRegionPageState extends State<EditRegionPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isLoading = true;
  RegionModel? _currentRegion;
  List<RegionModel> _availableRegions = [];
  String? _selectedRegionId;

  // Standard Pricing Controllers
  late TextEditingController _regionNameController;
  late TextEditingController _costOfRideController;
  late TextEditingController _costPerKmController;
  late TextEditingController _costPerMinController;
  late TextEditingController _floatPercentController;

  // Corporate Pricing Controllers
  late TextEditingController _corpCostOfRideController;
  late TextEditingController _corpCostPerKmController;
  late TextEditingController _corpCostPerMinController;
  late TextEditingController _corpFloatPercentController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadRegion();
  }

  void _initControllers() {
    _regionNameController = TextEditingController();
    _costOfRideController = TextEditingController();
    _costPerKmController = TextEditingController();
    _costPerMinController = TextEditingController();
    _floatPercentController = TextEditingController();
    _corpCostOfRideController = TextEditingController();
    _corpCostPerKmController = TextEditingController();
    _corpCostPerMinController = TextEditingController();
    _corpFloatPercentController = TextEditingController();
  }

  Future<void> _loadRegion() async {
    final regionService = context.read<RegionService>();
    await regionService.fetchRegions();
    _availableRegions = regionService.regions;

    if (widget.region != null) {
      _selectedRegionId = widget.region!.id;
      _populateFields(widget.region!);
      setState(() => _isLoading = false);
      return;
    }

    if (_availableRegions.isNotEmpty) {
      final firstRegion = _availableRegions.first;
      _selectedRegionId = firstRegion.id;
      _populateFields(firstRegion);
    } else {
      _prepareNewRegion();
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(RegionModel region) {
    _currentRegion = region;
    _selectedRegionId = region.id;
    _regionNameController.text = region.name;
    _costOfRideController.text = region.costOfRide.toStringAsFixed(2);
    _costPerKmController.text = region.costPerKm.toStringAsFixed(2);
    _costPerMinController.text = region.costPerMin.toStringAsFixed(2);
    _floatPercentController.text = region.floatPercent.toStringAsFixed(0);
    _corpCostOfRideController.text = region.corpCostOfRide.toStringAsFixed(2);
    _corpCostPerKmController.text = region.corpCostPerKm.toStringAsFixed(2);
    _corpCostPerMinController.text = region.corpCostPerMin.toStringAsFixed(2);
    _corpFloatPercentController.text =
        region.corpFloatPercent.toStringAsFixed(0);
  }

  void _prepareNewRegion() {
    _currentRegion = null;
    _selectedRegionId = null;
    _regionNameController.clear();
    _costOfRideController.text = '0.00';
    _costPerKmController.text = '0.00';
    _costPerMinController.text = '0.00';
    _floatPercentController.text = '0';
    _corpCostOfRideController.text = '0.00';
    _corpCostPerKmController.text = '0.00';
    _corpCostPerMinController.text = '0.00';
    _corpFloatPercentController.text = '0';
  }

  void _selectRegionById(String regionId) {
    final selected = _availableRegions.where((region) => region.id == regionId);
    if (selected.isEmpty) return;
    setState(() {
      _populateFields(selected.first);
    });
  }

  @override
  void dispose() {
    _regionNameController.dispose();
    _costOfRideController.dispose();
    _costPerKmController.dispose();
    _costPerMinController.dispose();
    _floatPercentController.dispose();
    _corpCostOfRideController.dispose();
    _corpCostPerKmController.dispose();
    _corpCostPerMinController.dispose();
    _corpFloatPercentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final regionService = context.read<RegionService>();
      final now = DateTime.now();
      final regionName = _regionNameController.text.trim();

      final duplicateExists = _availableRegions.any(
        (region) =>
            region.id != (_currentRegion?.id ?? '') &&
            region.name.trim().toLowerCase() == regionName.toLowerCase(),
      );
      if (duplicateExists) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('A region named "$regionName" already exists.'),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }

      final updatedRegion = RegionModel(
        id: _currentRegion?.id ?? '',
        name: regionName,
        description: _currentRegion?.description ?? '',
        activeDrivers: _currentRegion?.activeDrivers ?? 0,
        totalRides: _currentRegion?.totalRides ?? 0,
        isActive: true,
        costOfRide: double.tryParse(_costOfRideController.text) ?? 0.0,
        costPerKm: double.tryParse(_costPerKmController.text) ?? 0.0,
        costPerMin: double.tryParse(_costPerMinController.text) ?? 0.0,
        floatPercent: double.tryParse(_floatPercentController.text) ?? 0.0,
        corpCostOfRide: double.tryParse(_corpCostOfRideController.text) ?? 0.0,
        corpCostPerKm: double.tryParse(_corpCostPerKmController.text) ?? 0.0,
        corpCostPerMin: double.tryParse(_corpCostPerMinController.text) ?? 0.0,
        corpFloatPercent:
            double.tryParse(_corpFloatPercentController.text) ?? 0.0,
        createdAt: _currentRegion?.createdAt ?? now,
        updatedAt: now,
      );

      bool success = false;
      String? createdRegionId;
      if (_currentRegion != null && _currentRegion!.id.isNotEmpty) {
        success = await regionService.updateRegion(updatedRegion);
      } else {
        createdRegionId = await regionService.createRegion(updatedRegion);
        success = createdRegionId != null;
      }

      if (mounted) {
        setState(() => _isSaving = false);

        if (success) {
          await regionService.fetchRegions();
          if (!mounted) return;
          _availableRegions = regionService.regions;
          if (createdRegionId != null) {
            _selectRegionById(createdRegionId);
          } else if (_currentRegion != null) {
            _selectRegionById(_currentRegion!.id);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('Region pricing saved successfully')),
              backgroundColor: AppColors.lightSuccess,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.tr('Failed to save region pricing')),
              backgroundColor: AppColors.lightError,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tr('Error: {error}', params: {'error': '$e'}),
            ),
            backgroundColor: AppColors.lightError,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    // Colors matching the app theme
    final primaryColor = colorScheme.primary;
    final accentColor = colorScheme.secondary;
    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardColor = isDark
        ? AppColors.darkBackgroundSecondary
        : AppColors.lightBackgroundSecondary;
    final borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subtextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final inputBgColor =
        isDark ? AppColors.darkAlternate : AppColors.lightAlternate;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Title
                Expanded(
                  child: Center(
                    child: Text(
                      context.tr('Edit Region'),
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),

                // Spacer for centering
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description text
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              child: Text(
                                context.tr(
                                  'Edit the App Variables below to\nchange ride costs globally.',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: subtextColor,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Region',
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: subtextColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  key: ValueKey(
                                      _selectedRegionId ?? 'new-region'),
                                  initialValue: _selectedRegionId,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: inputBgColor,
                                    hintText: 'Choose existing region',
                                    hintStyle: TextStyle(
                                      fontFamily: _fontFamily,
                                      color: subtextColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: borderColor),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: borderColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide:
                                          BorderSide(color: primaryColor),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontFamily: _fontFamily,
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  items: _availableRegions
                                      .map(
                                        (region) => DropdownMenuItem<String>(
                                          value: region.id,
                                          child: Text(
                                            region.name,
                                            style: const TextStyle(
                                              fontFamily: _fontFamily,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    _selectRegionById(value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(_prepareNewRegion);
                                    },
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text(
                                      'New Region',
                                      style: TextStyle(fontFamily: _fontFamily),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Standard Pricing Section
                          _SectionHeader(
                            icon: Icons.public,
                            title: context.tr('Car Tow Pricing'),
                            iconColor: primaryColor,
                            textColor: subtextColor,
                          ),

                          const SizedBox(height: 12),

                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                if (_availableRegions.isNotEmpty)
                                  _FloatingLabelDropdown(
                                    label: context.tr('Region Name'),
                                    value: _selectedRegionId,
                                    inputBgColor: inputBgColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    hint: context.tr('Choose existing region'),
                                    items: _availableRegions
                                        .map(
                                          (region) =>
                                              DropdownMenuItem<String>(
                                            value: region.id,
                                            child: Text(
                                              region.name,
                                              style: const TextStyle(
                                                fontFamily: _fontFamily,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      _selectRegionById(value);
                                    },
                                  )
                                else
                                  _FloatingLabelInput(
                                    label: context.tr('Region Name'),
                                    controller: _regionNameController,
                                    inputBgColor: inputBgColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    keyboardType: TextInputType.text,
                                  ),
                                if (_currentRegion == null) ...[
                                  const SizedBox(height: 16),
                                  _FloatingLabelInput(
                                    label: context.tr('New Region Name'),
                                    controller: _regionNameController,
                                    inputBgColor: inputBgColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    keyboardType: TextInputType.text,
                                  ),
                                ],
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context.tr('Cost Of Ride'),
                                  controller: _costOfRideController,
                                  inputBgColor: inputBgColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  prefix: '\$ ',
                                ),
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context.tr('Cost per Kilometer'),
                                  controller: _costPerKmController,
                                  inputBgColor: inputBgColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  prefix: '\$ ',
                                ),
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context.tr('Cost per Minute'),
                                  controller: _costPerMinController,
                                  inputBgColor: inputBgColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  prefix: '\$ ',
                                ),
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context.tr('Float Percent'),
                                  controller: _floatPercentController,
                                  inputBgColor: inputBgColor,
                                  borderColor:
                                      accentColor.withValues(alpha: 0.5),
                                  textColor: textColor,
                                  subtextColor: accentColor,
                                  isAccent: true,
                                  accentColor: accentColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  suffix: '2/2',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Corporate Pricing Section
                          _SectionHeader(
                            icon: Icons.business,
                            title: context.tr('Truck Tow Pricing'),
                            iconColor: primaryColor,
                            textColor: subtextColor,
                          ),

                          const SizedBox(height: 12),

                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _FloatingLabelInput(
                                  label: context.tr('Corporate Cost Of Ride'),
                                  controller: _corpCostOfRideController,
                                  inputBgColor: inputBgColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  prefix: '\$ ',
                                ),
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context
                                      .tr('Corporate Cost per Kilometer'),
                                  controller: _corpCostPerKmController,
                                  inputBgColor: inputBgColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  prefix: '\$ ',
                                ),
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context.tr('Cost per Minute'),
                                  controller: _corpCostPerMinController,
                                  inputBgColor: inputBgColor,
                                  borderColor: borderColor,
                                  textColor: textColor,
                                  subtextColor: subtextColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  prefix: '\$ ',
                                ),
                                const SizedBox(height: 16),
                                _FloatingLabelInput(
                                  label: context.tr('Corporate Float Percent'),
                                  controller: _corpFloatPercentController,
                                  inputBgColor: inputBgColor,
                                  borderColor:
                                      accentColor.withValues(alpha: 0.5),
                                  textColor: textColor,
                                  subtextColor: accentColor,
                                  isAccent: true,
                                  accentColor: accentColor,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveChanges,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_outlined,
                                      color: Colors.white),
                              label: Text(
                                _isSaving
                                    ? context.tr('Saving...')
                                    : context.tr('Save Changes'),
                                style: const TextStyle(
                                  fontFamily: _fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor:
                                    primaryColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color textColor;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating Label Input Widget
class _FloatingLabelInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final Color inputBgColor;
  final Color borderColor;
  final Color textColor;
  final Color subtextColor;
  final bool isAccent;
  final Color? accentColor;
  final TextInputType keyboardType;
  final String? suffix;
  final String? prefix;

  const _FloatingLabelInput({
    required this.label,
    required this.controller,
    required this.inputBgColor,
    required this.borderColor,
    required this.textColor,
    required this.subtextColor,
    this.isAccent = false,
    this.accentColor,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? AppColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isAccent
                ? effectiveAccentColor.withValues(alpha: 0.05)
                : inputBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAccent
                  ? effectiveAccentColor.withValues(alpha: 0.5)
                  : borderColor,
              width: isAccent ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 12),
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isAccent ? effectiveAccentColor : subtextColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 12, top: 4),
                  isDense: true,
                  prefixText: prefix,
                  prefixStyle: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: textColor.withValues(alpha: 0.75),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        if (suffix != null) ...[
          const SizedBox(height: 4),
          Text(
            suffix!,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: effectiveAccentColor,
            ),
          ),
        ],
      ],
    );
  }
}

/// Floating Label Dropdown Widget
class _FloatingLabelDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final Color inputBgColor;
  final Color borderColor;
  final Color textColor;
  final Color subtextColor;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _FloatingLabelDropdown({
    required this.label,
    required this.value,
    required this.inputBgColor,
    required this.borderColor,
    required this.textColor,
    required this.subtextColor,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: inputBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: subtextColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: subtextColor),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 4),
              isDense: true,
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: subtextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
