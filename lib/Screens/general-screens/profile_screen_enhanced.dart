import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_toast.dart';

/// Enhanced Profile Screen using Project Zoe Design System
class EnhancedProfileScreen extends StatelessWidget {
  const EnhancedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
            title: Text(
              'Profile',
              style: AppTextStyles.h2,
            ),
            // Temporarily commented out settings
            // actions: [
            //   IconButton(
            //     icon: Icon(
            //       Icons.settings,
            //       color: AppColors.primaryText,
            //     ),
            //     onPressed: () {
            //       ToastHelper.showInfo(context, 'Settings coming soon');
            //     },
            //   ),
            // ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(authProvider),
                
                const SizedBox(height: AppSpacing.sectionSpacing),

                // Profile Options
                _buildProfileOptions(context, authProvider),
                
                const SizedBox(height: AppSpacing.sectionSpacing),

                // App Info
                _buildAppInfo(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    final user = authProvider.user;
    final userName = user?.fullName ?? 'User';
    final userRole = user?.primaryRole ?? 'Member';
    final fellowshipName = _getUserLocation(user);

    return ZoeCard(
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: AppSpacing.iconXl,
              color: AppColors.primaryGreen,
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // User Info
          Text(
            userName,
            style: AppTextStyles.h2.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          
          const SizedBox(height: AppSpacing.xs),
          
          Text(
            userRole,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.growthTint.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Text(
              fellowshipName,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, AuthProvider authProvider) {
    final profileOptions = [
      // Temporarily commented out menu items
      // _ProfileOption(
      //   icon: Icons.edit,
      //   title: 'Edit Profile',
      //   subtitle: 'Update your personal information',
      //   onTap: () => ToastHelper.showInfo(context, 'Edit profile coming soon'),
      // ),
      // _ProfileOption(
      //   icon: Icons.notifications,
      //   title: 'Notifications',
      //   subtitle: 'Manage your notification preferences',
      //   onTap: () => ToastHelper.showInfo(context, 'Notifications coming soon'),
      // ),
      // _ProfileOption(
      //   icon: Icons.security,
      //   title: 'Privacy & Security',
      //   subtitle: 'Manage your account security',
      //   onTap: () => ToastHelper.showInfo(context, 'Security settings coming soon'),
      // ),
      // _ProfileOption(
      //   icon: Icons.help,
      //   title: 'Help & Support',
      //   subtitle: 'Get help and contact support',
      //   onTap: () => ToastHelper.showInfo(context, 'Help coming soon'),
      // ),
      _ProfileOption(
        icon: Icons.logout,
        title: 'Sign Out',
        subtitle: 'Sign out of your account',
        onTap: () => _showSignOutDialog(context, authProvider),
        isDestructive: true,
      ),
    ];

    return Column(
      children: profileOptions.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildProfileOptionCard(option),
        );
      }).toList(),
    );
  }

  Widget _buildProfileOptionCard(_ProfileOption option) {
    return ZoeCard(
      onTap: option.onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: option.isDestructive 
                  ? AppColors.error.withOpacity(0.1)
                  : AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: Icon(
              option.icon,
              color: option.isDestructive 
                  ? AppColors.error
                  : AppColors.primaryGreen,
              size: AppSpacing.iconMd,
            ),
          ),
          
          const SizedBox(width: AppSpacing.lg),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: AppTextStyles.label.copyWith(
                    color: option.isDestructive 
                        ? AppColors.error
                        : AppColors.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (option.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    option.subtitle!,
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          
          Icon(
            Icons.arrow_forward_ios,
            size: AppSpacing.iconSm,
            color: AppColors.secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return ZoeCard(
      backgroundColor: AppColors.growthTint.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.church,
                color: AppColors.primaryGreen,
                size: AppSpacing.iconMd,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Project Zoe',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            'Shepherding people well with technology that serves',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Version 1.0.0',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.secondaryText,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Made with ❤️',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserLocation(user) {
    if (user == null) return 'No location assigned';

    // Simple approach: Just show the user's location
    if (user.hierarchy.locationGroups.isNotEmpty) {
      return user.hierarchy.locationGroups.first.name;
    }

    // Fallback: Show any group they belong to
    if (user.hierarchy.myGroups.isNotEmpty) {
      return user.hierarchy.myGroups.first.name;
    }

    return 'No location assigned';
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: Text(
          'Sign Out',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
          ZoeButton.primary(
            label: 'Sign Out',
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.logout();
              ToastHelper.showInfo(context, 'Signed out successfully');
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileOption {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  _ProfileOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });
}