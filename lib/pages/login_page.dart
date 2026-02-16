import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
import 'package:roadygo_admin/services/auth_service.dart';
import 'package:roadygo_admin/theme.dart';
import 'package:roadygo_admin/nav.dart';
import 'package:roadygo_admin/pages/admin_registration_page.dart';

const String _fontFamily = 'Satoshi';

/// Login page for RoadyGo Admin
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: labelColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      
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
                      
                      // Password field
                      FloatingLabelTextField(
                        label: context.tr('Password'),
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        backgroundColor: backgroundColor,
                        textColor: textColor,
                        labelColor: labelColor,
                        borderColor: borderColor,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: labelColor,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.tr('Please enter your password');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      
                      // Forgot Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            context.tr('Forgot Password?'),
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Login button
                      Consumer<AuthService>(
                        builder: (context, authService, _) {
                          return SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authService.isLoading ? null : _handleLogin,
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
                                      context.tr('Login'),
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
                      const SizedBox(height: 24),
                      
                      // Sign Up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontFamily: _fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: labelColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: _handleSignUp,
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: _fontFamily,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = context.read<AuthService>();
    final success = await authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  void _handleSignUp() {
    context.go(AppRoutes.home);
  }

  void _handleForgotPassword() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary;
        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        final borderColor = isDark ? AppColors.darkLine : AppColors.lightLine;

        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            context.tr('Reset Password'),
            style: TextStyle(
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                ),
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 16,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  hintText: context.tr('Email address'),
                  hintStyle: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 16,
                    color: labelColor,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr('Cancel'),
                style: TextStyle(
                  fontFamily: _fontFamily,
                  color: labelColor,
                ),
              ),
            ),
            Consumer<AuthService>(
              builder: (context, authService, _) {
                return ElevatedButton(
                  onPressed: authService.isLoading
                      ? null
                      : () async {
                          final email = emailController.text.trim();
                          if (email.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('Please enter your email')),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          
                          final success = await authService.sendPasswordResetEmail(email);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? context.tr(
                                          'Password reset email sent! Check your inbox.',
                                        )
                                      : authService.error ??
                                          context.tr('Failed to send reset email'),
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authService.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          context.tr('Send Reset Link'),
                          style: TextStyle(fontFamily: _fontFamily),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
