import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/services/auth_service.dart';
import 'package:roadygo_admin/theme.dart';
import 'package:roadygo_admin/nav.dart';

const String _fontFamily = 'Satoshi';

/// Admin Registration page for RoadyGo
class AdminRegistrationPage extends StatefulWidget {
  const AdminRegistrationPage({super.key});

  @override
  State<AdminRegistrationPage> createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<AdminRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPhoneVerified = false;
  bool _isVerifyingPhone = false;
  _CountryOption _selectedCountry = _CountryOption.defaultCountry;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    if (_isPhoneVerified) {
      setState(() => _isPhoneVerified = false);
    }
  }

  String _normalizePhoneDigits(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _fullPhoneNumber() {
    final digits = _normalizePhoneDigits(_phoneController.text);
    return '${_selectedCountry.dialCode}$digits';
  }

  String? _validatePhone(String? value) {
    final digits = _normalizePhoneDigits(value ?? '');
    if (digits.isEmpty) {
      return context.tr('Please enter your phone number');
    }
    if (digits.length < 6 || digits.length > 15) {
      return context.tr('Please enter a valid phone number');
    }
    return null;
  }

  Future<void> _verifyPhoneNumber() async {
    final error = _validatePhone(_phoneController.text);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    setState(() => _isVerifyingPhone = true);
    final authService = context.read<AuthService>();
    final isAvailable = await authService.isPhoneAvailable(_fullPhoneNumber());
    if (!mounted) return;

    setState(() {
      _isVerifyingPhone = false;
      _isPhoneVerified = isAvailable;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAvailable
              ? context.tr('Phone number verified successfully')
              : context.tr('This phone number is already in use'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isAvailable ? AppColors.lightSuccess : AppColors.lightError,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Header section with logo
          const MaxiTaxiHeader(),
          
          // Form section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        context.tr('Create Account'),
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Error message
                      Consumer<AuthService>(
                        builder: (context, authService, _) {
                          if (authService.error != null) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authService.error!,
                                      style: const TextStyle(
                                        fontFamily: _fontFamily,
                                        fontSize: 13,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => authService.clearError(),
                                    child: const Icon(Icons.close, color: Colors.red, size: 18),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      
                      // Name field
                      FloatingLabelTextField(
                        label: context.tr('Name'),
                        placeholder: context.tr('Enter your full name'),
                        controller: _nameController,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        labelColor: labelColor,
                        borderColor: borderColor,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr('Please enter your name');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Email field
                      FloatingLabelTextField(
                        label: context.tr('Email'),
                        placeholder: context.tr('Enter your email'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        labelColor: labelColor,
                        borderColor: borderColor,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return context.tr('Please enter your email');
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return context.tr('Please enter a valid email');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Phone field with country selector
                      _PhoneVerificationField(
                        label: context.tr('Phone Number'),
                        controller: _phoneController,
                        selectedCountry: _selectedCountry,
                        isVerified: _isPhoneVerified,
                        isVerifying: _isVerifyingPhone,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        labelColor: labelColor,
                        borderColor: borderColor,
                        onCountryTap: _showCountryPicker,
                        onVerifyTap: _verifyPhoneNumber,
                        validator: _validatePhone,
                      ),
                      const SizedBox(height: 24),
                      
                      // Password field
                      PasswordTextField(
                        placeholder: context.tr('Password'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        textColor: textColor,
                        labelColor: labelColor,
                        borderColor: borderColor,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('Please enter a password');
                          }
                          if (value.length < 6) {
                            return context.tr(
                              'Password must be at least 6 characters',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Confirm Password field
                      FloatingLabelTextField(
                        label: context.tr('Confirm Password'),
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        labelColor: labelColor,
                        borderColor: borderColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: labelColor,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('Please confirm your password');
                          }
                          if (value != _passwordController.text) {
                            return context.tr('Passwords do not match');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // Sign Up button
                      Consumer<AuthService>(
                        builder: (context, authService, _) {
                          return SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authService.isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                              ),
                              child: authService.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      context.tr('Sign Up'),
                                      style: TextStyle(
                                        fontFamily: _fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Login link
                      Center(
                        child: TextButton(
                          onPressed: _handleLogin,
                          child: Text(
                            context.tr('Login'),
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isPhoneVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Please verify your phone number first')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    final authService = context.read<AuthService>();
    final success = await authService.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phoneNumber: _fullPhoneNumber(),
      countryCode: _selectedCountry.code,
      countryDialCode: _selectedCountry.dialCode,
      isPhoneVerified: _isPhoneVerified,
    );

    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _handleLogin() {
    context.go(AppRoutes.login);
  }

  Future<void> _showCountryPicker() async {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      onSelect: (country) {
        if (!mounted) return;
        setState(() {
          _selectedCountry = _CountryOption.fromCountry(country);
          _isPhoneVerified = false;
        });
      },
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: InputDecoration(
          hintText: context.tr('Search country'),
          prefixIcon: const Icon(Icons.search_rounded),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}

/// MAXI TAXI Logo Header
class MaxiTaxiHeader extends StatelessWidget {
  const MaxiTaxiHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.35,
      width: double.infinity,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/WhatsApp_Image_2026-02-04_at_00.58.08_4.jpeg',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: -12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Text field with floating label
class FloatingLabelTextField extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color backgroundColor;
  final Color textColor;
  final Color labelColor;
  final Color borderColor;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const FloatingLabelTextField({
    super.key,
    this.label,
    this.placeholder,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    required this.backgroundColor,
    required this.textColor,
    required this.labelColor,
    required this.borderColor,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              color: labelColor,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: false,
            suffixIcon: suffixIcon,
          ),
        ),
        if (label != null)
          Positioned(
            top: -8,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: backgroundColor,
              child: Text(
                label!,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Password text field with visibility toggle
class PasswordTextField extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final Color textColor;
  final Color labelColor;
  final Color borderColor;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    required this.placeholder,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.textColor,
    required this.labelColor,
    required this.borderColor,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: labelColor,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: false,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: labelColor,
            size: 20,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
    );
  }
}

class _PhoneVerificationField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final _CountryOption selectedCountry;
  final bool isVerified;
  final bool isVerifying;
  final Color backgroundColor;
  final Color textColor;
  final Color labelColor;
  final Color borderColor;
  final VoidCallback onCountryTap;
  final VoidCallback onVerifyTap;
  final String? Function(String?)? validator;

  const _PhoneVerificationField({
    required this.label,
    required this.controller,
    required this.selectedCountry,
    required this.isVerified,
    required this.isVerifying,
    required this.backgroundColor,
    required this.textColor,
    required this.labelColor,
    required this.borderColor,
    required this.onCountryTap,
    required this.onVerifyTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          validator: validator,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: context.tr('Enter phone number'),
            hintStyle: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              color: labelColor,
            ),
            contentPadding: const EdgeInsets.only(left: 146, right: 98, top: 18, bottom: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: false,
          ),
        ),
        Positioned(
          left: 10,
          top: 8,
          bottom: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onCountryTap,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkAlternate.withValues(alpha: 0.6)
                      : AppColors.lightAlternate,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(selectedCountry.flag, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      selectedCountry.dialCode,
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: labelColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          bottom: 8,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isVerifying ? null : onVerifyTap,
              borderRadius: BorderRadius.circular(10),
              child: Ink(
                width: 84,
                decoration: BoxDecoration(
                  color: isVerified
                      ? AppColors.lightSuccess.withValues(alpha: 0.16)
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isVerified
                        ? AppColors.lightSuccess.withValues(alpha: 0.4)
                        : AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: isVerifying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isVerified)
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.lightSuccess)
                            else
                              const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              isVerified ? context.tr('Verified') : context.tr('Verify'),
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isVerified ? AppColors.lightSuccess : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -8,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            color: backgroundColor,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: labelColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountryOption {
  final String code;
  final String name;
  final String dialCode;

  const _CountryOption({
    required this.code,
    required this.name,
    required this.dialCode,
  });

  static const _CountryOption defaultCountry = _CountryOption(
    code: 'US',
    name: 'United States',
    dialCode: '+1',
  );

  String get flag => _toFlagEmoji(code);

  factory _CountryOption.fromCountry(Country country) {
    return _CountryOption(
      code: country.countryCode,
      name: country.name,
      dialCode: '+${country.phoneCode}',
    );
  }

  static String _toFlagEmoji(String countryCode) {
    final upper = countryCode.toUpperCase();
    if (upper.length != 2) return '🌐';
    final first = upper.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final second = upper.codeUnitAt(1) - 0x41 + 0x1F1E6;
    return String.fromCharCode(first) + String.fromCharCode(second);
  }
}
