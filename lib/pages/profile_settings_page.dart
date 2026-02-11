import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/services/auth_service.dart';
import 'package:roadygo_admin/theme.dart';
import 'package:roadygo_admin/nav.dart';

const String _fontFamily = 'Satoshi';

/// Profile Settings Page for RoadyGo Admin
class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          // Header
          _ProfileHeader(isDark: isDark, colorScheme: colorScheme),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  
                  // Profile Avatar Section
                  _ProfileAvatarSection(isDark: isDark),
                  
                  const SizedBox(height: 32),
                  
                  // Settings List
                  _SettingsListSection(isDark: isDark),
                  
                  const SizedBox(height: 64),
                  
                  // Logout Button
                  _LogoutButton(isDark: isDark),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile Header with back button
class _ProfileHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme colorScheme;

  const _ProfileHeader({required this.isDark, required this.colorScheme});

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
          // Back button
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
          
          // Title
          Expanded(
            child: Center(
              child: Text(
                'Profile Settings',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
          
          // Spacer for centering
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

/// Profile Avatar Section with camera button
class _ProfileAvatarSection extends StatelessWidget {
  final bool isDark;

  const _ProfileAvatarSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final displayName = user?.name ?? 'Admin User';
        final role = user?.role.toUpperCase() ?? 'ADMINISTRATOR';
        final photoUrl = user?.photoUrl;

        return Column(
          children: [
            // Avatar with camera button
            Stack(
              children: [
                // Avatar container with border
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: photoUrl != null
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(displayName),
                            )
                          : _buildDefaultAvatar(displayName),
                    ),
                  ),
                ),
                
                // Camera button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement photo picker
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Name
            Text(
              displayName,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Role
            Text(
              role,
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                letterSpacing: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.isNotEmpty 
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'A';
    return Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 40,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Settings List Section
class _SettingsListSection extends StatelessWidget {
  final bool isDark;

  const _SettingsListSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Personal Information
        _SettingsListItem(
          icon: Icons.person_outline,
          iconBackgroundColor: isDark 
              ? const Color(0xFF1E3A5F).withValues(alpha: 0.3) 
              : const Color(0xFFEFF6FF),
          iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          title: 'Personal Information',
          isDark: isDark,
          onTap: () {
            // TODO: Navigate to personal information
          },
        ),
        
        // Divider
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
          ),
        ),
        
        // App Theme
        _SettingsListItem(
          icon: Icons.palette_outlined,
          iconBackgroundColor: isDark 
              ? const Color(0xFF064E3B).withValues(alpha: 0.3) 
              : const Color(0xFFECFDF5),
          iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          title: 'App Theme',
          isDark: isDark,
          onTap: () {
            // TODO: Navigate to app theme settings
          },
        ),
        
        // Divider
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
          ),
        ),
        
        // Edit Rates
        _SettingsListItem(
          icon: Icons.attach_money,
          iconBackgroundColor: isDark 
              ? const Color(0xFF7C2D12).withValues(alpha: 0.3) 
              : const Color(0xFFFFF7ED),
          iconColor: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
          title: 'Edit Rates',
          isDark: isDark,
          onTap: () {
            context.push(AppRoutes.editRates);
          },
        ),
        
        // Divider
        Padding(
          padding: const EdgeInsets.only(left: 56),
          child: Divider(
            height: 1,
            color: isDark ? AppColors.darkLine : AppColors.lightLine,
          ),
        ),
        
        // Edit Rules (Edit Region)
        _SettingsListItem(
          icon: Icons.public,
          iconBackgroundColor: isDark 
              ? const Color(0xFF1E3A5F).withValues(alpha: 0.3) 
              : const Color(0xFFEFF6FF),
          iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
          title: 'Edit Rules',
          isDark: isDark,
          onTap: () {
            context.push(AppRoutes.editRegion);
          },
        ),
      ],
    );
  }
}

/// Settings List Item
class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _SettingsListItem({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: isDark 
            ? AppColors.darkAlternate 
            : AppColors.lightAlternate,
        highlightColor: isDark 
            ? AppColors.darkAlternate.withValues(alpha: 0.5) 
            : AppColors.lightAlternate.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                size: 24,
                color: isDark ? AppColors.darkLine : AppColors.lightLine,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logout Button
class _LogoutButton extends StatelessWidget {
  final bool isDark;

  const _LogoutButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _handleLogout(context),
      icon: const Icon(
        Icons.logout,
        size: 20,
        color: AppColors.lightError,
      ),
      label: const Text(
        'Log Out',
        style: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.lightError,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary;
        final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final labelColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return AlertDialog(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Log Out',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              color: labelColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: _fontFamily,
                  color: labelColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final authService = context.read<AuthService>();
                await authService.signOut();
                if (context.mounted) {
                  context.go(AppRoutes.home);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightError,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Log Out',
                style: TextStyle(fontFamily: _fontFamily),
              ),
            ),
          ],
        );
      },
    );
  }
}
