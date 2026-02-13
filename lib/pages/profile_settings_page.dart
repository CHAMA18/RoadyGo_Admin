import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/services/auth_service.dart';
import 'package:roadygo_admin/services/theme_service.dart';
import 'package:roadygo_admin/theme.dart';
import 'package:roadygo_admin/nav.dart';

const String _fontFamily = 'Satoshi';

/// Profile Settings Page for RoadyGo Admin - World-Class Design
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Custom App Bar with Profile Header
          _ProfileSliverAppBar(isDark: isDark),
          
          // Content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Section
                      _SettingsSection(
                        title: 'Account',
                        isDark: isDark,
                        items: [
                          _SettingItemData(
                            icon: Icons.person_outline_rounded,
                            title: 'Personal Information',
                            subtitle: 'Name, email & phone number',
                            gradientColors: const [Color(0xFF667EEA), Color(0xFF764BA2)],
                            onTap: () {},
                          ),
                          _SettingItemData(
                            icon: Icons.security_rounded,
                            title: 'Security',
                            subtitle: 'Password & authentication',
                            gradientColors: const [Color(0xFF11998E), Color(0xFF38EF7D)],
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Preferences Section
                      _SettingsSection(
                        title: 'Preferences',
                        isDark: isDark,
                        items: [
                          _SettingItemData(
                            icon: Icons.palette_outlined,
                            title: 'App Theme',
                            subtitle: 'Appearance & display',
                            gradientColors: const [Color(0xFFF093FB), Color(0xFFF5576C)],
                            isExpandable: true,
                            onTap: () {},
                          ),
                          _SettingItemData(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: 'Alerts & reminders',
                            gradientColors: const [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
                            onTap: () {},
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Management Section
                      _SettingsSection(
                        title: 'Management',
                        isDark: isDark,
                        items: [
                          _SettingItemData(
                            icon: Icons.attach_money_rounded,
                            title: 'Edit Rates',
                            subtitle: 'Pricing & fare configuration',
                            gradientColors: const [Color(0xFFFDA085), Color(0xFFF6D365)],
                            onTap: () => context.push(AppRoutes.editRates),
                          ),
                          _SettingItemData(
                            icon: Icons.rule_rounded,
                            title: 'Edit Rules',
                            subtitle: 'Service regions & policies',
                            gradientColors: const [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                            onTap: () => context.push(AppRoutes.editRegion),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Logout Section
                      _LogoutCard(isDark: isDark),
                      
                      const SizedBox(height: 24),
                      
                      // App Version
                      Center(
                        child: Text(
                          'RoadyGo Admin v1.0.0',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                                : AppColors.lightTextSecondary.withValues(alpha: 0.5),
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
}

/// Custom Sliver App Bar with Profile Header
class _ProfileSliverAppBar extends StatelessWidget {
  final bool isDark;

  const _ProfileSliverAppBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : AppColors.lightBackgroundSecondary,
      leading: _BackButton(isDark: isDark),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.darkBackgroundSecondary,
                        ]
                      : [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.lightBackgroundSecondary,
                        ],
                ),
              ),
            ),
            
            // Decorative Circles
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: -60,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                ),
              ),
            ),
            
            // Profile Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _ProfileAvatarSection(isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Back Button
class _BackButton extends StatefulWidget {
  final bool isDark;

  const _BackButton({required this.isDark});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.pop();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.isDark ? AppColors.darkLine : AppColors.lightLine)
                : (widget.isDark
                    ? AppColors.darkBackgroundSecondary.withValues(alpha: 0.8)
                    : AppColors.lightBackgroundSecondary.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: widget.isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}

/// Profile Avatar Section
class _ProfileAvatarSection extends StatelessWidget {
  final bool isDark;

  const _ProfileAvatarSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        final user = authService.currentUser;
        final firebaseUser = authService.firebaseUser;
        
        // Use Firestore user data first, then Firebase Auth user data as fallback
        final displayName = user?.name ?? 
            firebaseUser?.displayName ?? 
            (firebaseUser?.email?.split('@').first ?? 'User');
        final role = user?.role ?? 'Administrator';
        final email = user?.email ?? firebaseUser?.email ?? 'No email';
        final photoUrl = user?.photoUrl ?? firebaseUser?.photoURL;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          child: Column(
            children: [
              // Avatar with animated ring
              _AnimatedAvatar(
                photoUrl: photoUrl,
                displayName: displayName,
                isDark: isDark,
              ),
              
              const SizedBox(height: 16),
              
              // Name
              Text(
                displayName,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              
              const SizedBox(height: 6),
              
              // Role Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Email
              Text(
                email,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated Avatar with Gradient Ring
class _AnimatedAvatar extends StatefulWidget {
  final String? photoUrl;
  final String displayName;
  final bool isDark;

  const _AnimatedAvatar({
    required this.photoUrl,
    required this.displayName,
    required this.isDark,
  });

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated Gradient Ring
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        
        // Avatar Container
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isDark
                ? AppColors.darkBackgroundSecondary
                : AppColors.lightBackgroundSecondary,
          ),
          child: ClipOval(
            child: widget.photoUrl != null
                ? Image.network(
                    widget.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildDefaultAvatar(),
                  )
                : _buildDefaultAvatar(),
          ),
        ),
        
        // Camera Button
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              // TODO: Implement photo picker
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isDark
                      ? AppColors.darkBackgroundSecondary
                      : AppColors.lightBackgroundSecondary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    final initials = widget.displayName.isNotEmpty
        ? widget.displayName
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'A';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.secondary.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Settings Section with Title
class _SettingsSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<_SettingItemData> items;

  const _SettingsSection({
    required this.title,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.7)
                  : AppColors.lightTextSecondary.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        
        // Settings Card
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBackgroundSecondary
                : AppColors.lightBackgroundSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.darkLine.withValues(alpha: 0.3)
                  : AppColors.lightLine.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isLast = index == items.length - 1;
                
                if (item.isExpandable) {
                  return _ExpandableSettingItem(
                    data: item,
                    isDark: isDark,
                    showDivider: !isLast,
                  );
                }
                
                return _SettingItem(
                  data: item,
                  isDark: isDark,
                  showDivider: !isLast,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Setting Item Data Model
class _SettingItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final bool isExpandable;

  _SettingItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
    this.isExpandable = false,
  });
}

/// Setting Item Widget
class _SettingItem extends StatefulWidget {
  final _SettingItemData data;
  final bool isDark;
  final bool showDivider;

  const _SettingItem({
    required this.data,
    required this.isDark,
    required this.showDivider,
  });

  @override
  State<_SettingItem> createState() => _SettingItemState();
}

class _SettingItemState extends State<_SettingItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.data.onTap();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: _isPressed
                ? (widget.isDark
                    ? AppColors.darkLine.withValues(alpha: 0.3)
                    : AppColors.lightLine.withValues(alpha: 0.5))
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.data.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.data.icon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(width: 14),
                
                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.data.subtitle,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.darkLine.withValues(alpha: 0.3)
                        : AppColors.lightLine.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 74),
            child: Divider(
              height: 1,
              color: widget.isDark
                  ? AppColors.darkLine.withValues(alpha: 0.3)
                  : AppColors.lightLine.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}

/// Expandable Setting Item for Theme
class _ExpandableSettingItem extends StatefulWidget {
  final _SettingItemData data;
  final bool isDark;
  final bool showDivider;

  const _ExpandableSettingItem({
    required this.data,
    required this.isDark,
    required this.showDivider,
  });

  @override
  State<_ExpandableSettingItem> createState() => _ExpandableSettingItemState();
}

class _ExpandableSettingItemState extends State<_ExpandableSettingItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isPressed = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _toggle();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: _isPressed
                ? (widget.isDark
                    ? AppColors.darkLine.withValues(alpha: 0.3)
                    : AppColors.lightLine.withValues(alpha: 0.5))
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Gradient Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.data.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradientColors[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.data.icon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(width: 14),
                
                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.data.title,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        themeService.themeModeDisplayName,
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 12,
                          color: widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Animated Arrow Icon
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkLine.withValues(alpha: 0.3)
                          : AppColors.lightLine.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Expandable Theme Options
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: _ThemeOptionsPanel(isDark: widget.isDark),
        ),
        
        if (widget.showDivider && !_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 74),
            child: Divider(
              height: 1,
              color: widget.isDark
                  ? AppColors.darkLine.withValues(alpha: 0.3)
                  : AppColors.lightLine.withValues(alpha: 0.5),
            ),
          ),
      ],
    );
  }
}

/// Theme Options Panel
class _ThemeOptionsPanel extends StatelessWidget {
  final bool isDark;

  const _ThemeOptionsPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withValues(alpha: 0.5)
            : AppColors.lightBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _ThemeOptionButton(
            icon: Icons.light_mode_rounded,
            label: 'Light',
            isSelected: themeService.themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () => themeService.setThemeMode(ThemeMode.light),
          ),
          const SizedBox(width: 8),
          _ThemeOptionButton(
            icon: Icons.dark_mode_rounded,
            label: 'Dark',
            isSelected: themeService.themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () => themeService.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(width: 8),
          _ThemeOptionButton(
            icon: Icons.brightness_auto_rounded,
            label: 'Auto',
            isSelected: themeService.themeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () => themeService.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

/// Theme Option Button
class _ThemeOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeOptionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.secondary],
                  )
                : null,
            color: isSelected
                ? null
                : (isDark
                    ? AppColors.darkBackgroundSecondary.withValues(alpha: 0.5)
                    : AppColors.lightBackgroundSecondary),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? null
                : Border.all(
                    color: isDark
                        ? AppColors.darkLine.withValues(alpha: 0.3)
                        : AppColors.lightLine.withValues(alpha: 0.5),
                    width: 1,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logout Card
class _LogoutCard extends StatefulWidget {
  final bool isDark;

  const _LogoutCard({required this.isDark});

  @override
  State<_LogoutCard> createState() => _LogoutCardState();
}

class _LogoutCardState extends State<_LogoutCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showLogoutDialog(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _isPressed
              ? AppColors.lightError.withValues(alpha: 0.15)
              : AppColors.lightError.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.lightError.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.lightError.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: AppColors.lightError,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Sign Out',
              style: TextStyle(
                fontFamily: _fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _LogoutBottomSheet(isDark: widget.isDark),
    );
  }
}

/// Logout Bottom Sheet
class _LogoutBottomSheet extends StatelessWidget {
  final bool isDark;

  const _LogoutBottomSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            16,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackgroundSecondary
            : AppColors.lightBackgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkLine
                  : AppColors.lightLine,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.lightError.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 28,
              color: AppColors.lightError,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Sign Out?',
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            'Are you sure you want to sign out of your account?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Cancel Button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark
                              ? AppColors.darkLine
                              : AppColors.lightLine,
                        ),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Sign Out Button
                Expanded(
                  child: ElevatedButton(
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
