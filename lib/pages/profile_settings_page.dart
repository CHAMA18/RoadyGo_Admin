import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:roadygo_admin/l10n/app_localizations.dart';
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
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                        title: context.tr('Account'),
                        isDark: isDark,
                        items: [
                          _SettingItemData(
                            icon: Icons.person_outline_rounded,
                            title: context.tr('Personal Information'),
                            subtitle: context.tr('Name, email & phone number'),
                            gradientColors: const [
                              Color(0xFF667EEA),
                              Color(0xFF764BA2)
                            ],
                            onTap: () =>
                                context.pushNamed('personalInformation'),
                          ),
                          _SettingItemData(
                            icon: Icons.security_rounded,
                            title: context.tr('Security'),
                            subtitle: context.tr('Password & authentication'),
                            gradientColors: const [
                              Color(0xFF11998E),
                              Color(0xFF38EF7D)
                            ],
                            onTap: () => context.pushNamed('security'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Preferences Section
                      _SettingsSection(
                        title: context.tr('Preferences'),
                        isDark: isDark,
                        items: [
                          _SettingItemData(
                            icon: Icons.palette_outlined,
                            title: context.tr('App Theme'),
                            subtitle: context.tr('Appearance & display'),
                            gradientColors: const [
                              Color(0xFFF093FB),
                              Color(0xFFF5576C)
                            ],
                            isExpandable: true,
                            expandableType: 'theme',
                            onTap: () {},
                          ),
                          _SettingItemData(
                            icon: Icons.language_rounded,
                            title: context.tr('Language'),
                            subtitle: context.tr('App language'),
                            gradientColors: const [
                              Color(0xFF667EEA),
                              Color(0xFF764BA2)
                            ],
                            isExpandable: true,
                            expandableType: 'language',
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Management Section
                      _SettingsSection(
                        title: context.tr('Management'),
                        isDark: isDark,
                        items: [
                          _SettingItemData(
                            icon: Icons.attach_money_rounded,
                            title: context.tr('Edit Rates'),
                            subtitle:
                                context.tr('Pricing & fare configuration'),
                            gradientColors: const [
                              Color(0xFFFDA085),
                              Color(0xFFF6D365)
                            ],
                            onTap: () => context.push(AppRoutes.editRates),
                          ),
                          _SettingItemData(
                            icon: Icons.rule_rounded,
                            title: context.tr('Edit Rules'),
                            subtitle: context.tr('Service regions & policies'),
                            gradientColors: const [
                              Color(0xFF4FACFE),
                              Color(0xFF00F2FE)
                            ],
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
                          '${context.tr('RoadyGo Admin')} v1.0.0',
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                    .withValues(alpha: 0.5)
                                : AppColors.lightTextSecondary
                                    .withValues(alpha: 0.5),
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
      backgroundColor: isDark
          ? AppColors.darkBackgroundSecondary
          : AppColors.lightBackgroundSecondary,
      leading: _BackButton(isDark: isDark),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Solid background
            Container(
              color: isDark
                  ? AppColors.darkBackgroundSecondary
                  : AppColors.primary.withValues(alpha: 0.08),
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
                  color: AppColors.primary.withValues(alpha: 0.08),
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
                  color: AppColors.primary.withValues(alpha: 0.06),
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
                    : AppColors.lightBackgroundSecondary
                        .withValues(alpha: 0.9)),
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
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}

/// Profile Avatar Section
class _ProfileAvatarSection extends StatefulWidget {
  final bool isDark;

  const _ProfileAvatarSection({required this.isDark});

  @override
  State<_ProfileAvatarSection> createState() => _ProfileAvatarSectionState();
}

class _ProfileAvatarSectionState extends State<_ProfileAvatarSection> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<({Uint8List bytes, String fileName})?> _selectProfileImage() async {
    try {
      final selectedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 88,
      );

      if (selectedImage != null) {
        final fileName =
            selectedImage.name.trim().isEmpty ? 'profile.jpg' : selectedImage.name;
        return (bytes: await selectedImage.readAsBytes(), fileName: fileName);
      }
    } on MissingPluginException {
      // Fallback for environments where image_picker plugin is not registered.
    } on PlatformException {
      // Fallback to file picker below.
    }

    final fileResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (fileResult == null || fileResult.files.isEmpty) return null;
    final picked = fileResult.files.single;

    Uint8List? bytes = picked.bytes;
    if (bytes == null && picked.path != null) {
      bytes = await XFile(picked.path!).readAsBytes();
    }
    if (bytes == null) return null;

    final fileName = (picked.name.trim().isEmpty) ? 'profile.jpg' : picked.name;
    return (bytes: bytes, fileName: fileName);
  }

  Future<void> _pickAndUploadPhoto() async {
    final authService = context.read<AuthService>();
    if (authService.firebaseUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be signed in to upload a photo.')),
      );
      return;
    }

    try {
      final selectedImage = await _selectProfileImage();

      if (selectedImage == null) return;

      setState(() => _isUploading = true);
      final uploadResult = await authService.uploadProfilePhoto(
        imageBytes: selectedImage.bytes,
        fileName: selectedImage.fileName,
      );

      if (!mounted) return;
      if (!uploadResult.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(uploadResult.errorMessage ?? 'Failed to upload photo.'),
          ),
        );
      } else {
        final successMessage = uploadResult.syncedToFirestore
            ? 'Profile photo updated successfully.'
            : 'Photo uploaded successfully. Firestore sync is pending.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo upload failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

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
                isDark: widget.isDark,
                isUploading: _isUploading,
                onCameraTap: _isUploading ? null : _pickAndUploadPhoto,
              ),

              const SizedBox(height: 16),

              // Name
              Text(
                displayName,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              // Role Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
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
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
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
  final bool isUploading;
  final VoidCallback? onCameraTap;

  const _AnimatedAvatar({
    required this.photoUrl,
    required this.displayName,
    required this.isDark,
    required this.isUploading,
    required this.onCameraTap,
  });

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showAnimatedRing = !kIsWeb && _controller != null;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Animated Gradient Ring
        if (showAnimatedRing)
          AnimatedBuilder(
            animation: _controller!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller!.value * 2 * 3.14159,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                ),
              );
            },
          )
        else
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45), width: 3),
            ),
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
            child:
                (widget.photoUrl != null && widget.photoUrl!.trim().isNotEmpty)
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
            onTap: widget.onCameraTap,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary,
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
              child: widget.isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
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
        color: AppColors.primary.withValues(alpha: 0.12),
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
                    key: ValueKey(item.expandableType),
                    data: item,
                    isDark: isDark,
                    showDivider: !isLast,
                    expandableType: item.expandableType,
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
  final String expandableType;

  _SettingItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
    this.isExpandable = false,
    this.expandableType = 'theme',
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
          onTap: () {
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
                    color: widget.data.gradientColors.first,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradientColors.first
                            .withValues(alpha: 0.3),
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

/// Expandable Setting Item for Theme & Language
class _ExpandableSettingItem extends StatefulWidget {
  final _SettingItemData data;
  final bool isDark;
  final bool showDivider;
  final String expandableType;

  const _ExpandableSettingItem({
    super.key,
    required this.data,
    required this.isDark,
    required this.showDivider,
    required this.expandableType,
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

  String _getSubtitle(BuildContext context) {
    if (widget.expandableType == 'theme') {
      return context.tr(context.watch<ThemeService>().themeModeDisplayName);
    } else if (widget.expandableType == 'language') {
      return context.watch<ThemeService>().languageDisplayName;
    }
    return widget.data.subtitle;
  }

  Widget _getExpandedPanel() {
    if (widget.expandableType == 'theme') {
      return _ThemeOptionsPanel(isDark: widget.isDark);
    } else if (widget.expandableType == 'language') {
      return _LanguageOptionsPanel(isDark: widget.isDark);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTap: () {
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
                    color: widget.data.gradientColors.first,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.data.gradientColors.first
                            .withValues(alpha: 0.3),
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
                        _getSubtitle(context),
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

        // Expandable Options Panel
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: _getExpandedPanel(),
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
            label: context.tr('Light'),
            isSelected: themeService.themeMode == ThemeMode.light,
            isDark: isDark,
            onTap: () => themeService.setThemeMode(ThemeMode.light),
          ),
          const SizedBox(width: 8),
          _ThemeOptionButton(
            icon: Icons.dark_mode_rounded,
            label: context.tr('Dark'),
            isSelected: themeService.themeMode == ThemeMode.dark,
            isDark: isDark,
            onTap: () => themeService.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(width: 8),
          _ThemeOptionButton(
            icon: Icons.brightness_auto_rounded,
            label: context.tr('Auto'),
            isSelected: themeService.themeMode == ThemeMode.system,
            isDark: isDark,
            onTap: () => themeService.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

/// Language Options Panel
class _LanguageOptionsPanel extends StatelessWidget {
  final bool isDark;

  const _LanguageOptionsPanel({required this.isDark});

  static const Map<String, String> _flags = {
    'en': '🇬🇧',
    'sq': '🇦🇱',
    'mk': '🇲🇰',
    'tr': '🇹🇷',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'es': '🇪🇸',
    'it': '🇮🇹',
    'pt': '🇵🇹',
    'nl': '🇳🇱',
    'pl': '🇵🇱',
    'ro': '🇷🇴',
    'el': '🇬🇷',
    'cs': '🇨🇿',
    'hu': '🇭🇺',
    'sv': '🇸🇪',
    'da': '🇩🇰',
    'fi': '🇫🇮',
    'no': '🇳🇴',
    'bg': '🇧🇬',
    'hr': '🇭🇷',
    'sk': '🇸🇰',
    'sl': '🇸🇮',
    'sr': '🇷🇸',
    'uk': '🇺🇦',
    'ru': '🇷🇺',
    'lt': '🇱🇹',
    'lv': '🇱🇻',
    'et': '🇪🇪',
  };

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 280),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ThemeService.supportedLanguageCodes.map((code) {
              final flag = _flags[code] ?? '🌐';
              final label = ThemeService.supportedLanguageNames[code] ?? code;
              return _CompactLanguageButton(
                flag: flag,
                label: label,
                languageCode: code,
                isTranslationLocked:
                    !AppLocalizations.isLanguageFullyTranslated(code),
                isSelected: themeService.languageCode == code,
                isDark: isDark,
                onTap: () => themeService.setLanguage(code),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Compact Language Button for grid layout
class _CompactLanguageButton extends StatelessWidget {
  final String flag;
  final String label;
  final String languageCode;
  final bool isTranslationLocked;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CompactLanguageButton({
    required this.flag,
    required this.label,
    required this.languageCode,
    required this.isTranslationLocked,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '$label (${languageCode.toUpperCase()})',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (isTranslationLocked)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(
                Icons.lock_rounded,
                size: 12,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.95)
                    : (isDark
                        ? AppColors.darkTextSecondary.withValues(alpha: 0.85)
                        : AppColors.lightTextSecondary.withValues(alpha: 0.85)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Language Option Button
class _LanguageOptionButton extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOptionButton({
    required this.flag,
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
            color: isSelected
                ? AppColors.primary
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
              Text(
                flag,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
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
            color: isSelected
                ? AppColors.primary
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
              color: isDark ? AppColors.darkLine : AppColors.lightLine,
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
                          color:
                              isDark ? AppColors.darkLine : AppColors.lightLine,
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
