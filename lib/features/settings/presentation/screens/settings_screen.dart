import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/mock_data.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    final user = MockData.currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.settings),
      ),
      body: CustomScrollView(
        slivers: [
          // Profile preview
          SliverToBoxAdapter(
            child: _ProfilePreviewTile(
              user: user,
              onEditTap: () => context.push(AppRoutes.editProfile),
            ),
          ),

          SliverToBoxAdapter(child: _SectionGap()),

          // Appearance
          SliverToBoxAdapter(
            child: SectionLabel(AppStrings.appearance),
          ),
          SliverToBoxAdapter(
            child: _SettingsCard(
              children: [
                _ToggleTile(
                  icon: Icons.dark_mode_outlined,
                  title: AppStrings.darkMode,
                  subtitle: AppStrings.darkModeSub,
                  value: isDark,
                  onChanged: (_) => themeNotifier.toggleDarkMode(),
                ),
                const AppDivider(),
                _NavTile(
                  icon: Icons.language_rounded,
                  title: AppStrings.language,
                  trailing: AppStrings.english,
                  onTap: () {},
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: _SectionGap()),

          // Privacy & Security
          SliverToBoxAdapter(
            child: SectionLabel(AppStrings.privacySecurity),
          ),
          SliverToBoxAdapter(
            child: _SettingsCard(
              children: [
                _NavTile(
                  icon: Icons.shield_outlined,
                  title: AppStrings.privacy,
                  subtitle: AppStrings.privacySub,
                  onTap: () {},
                ),
                const AppDivider(),
                _NavTile(
                  icon: Icons.lock_outline_rounded,
                  title: AppStrings.security,
                  subtitle: AppStrings.securitySub,
                  onTap: () {},
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: _SectionGap()),

          // Notifications
          SliverToBoxAdapter(
            child: SectionLabel(AppStrings.notificationsLabel),
          ),
          SliverToBoxAdapter(
            child: _SettingsCard(
              children: [
                _ToggleTile(
                  icon: Icons.notifications_outlined,
                  title: AppStrings.pushNotifications,
                  value: true,
                  onChanged: (_) {},
                ),
                const AppDivider(),
                _ToggleTile(
                  icon: Icons.mail_outline_rounded,
                  title: AppStrings.emailNotifications,
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: _SectionGap()),

          // About
          SliverToBoxAdapter(
            child: SectionLabel(AppStrings.about),
          ),
          SliverToBoxAdapter(
            child: _SettingsCard(
              children: [
                _NavTile(
                  icon: Icons.help_outline_rounded,
                  title: AppStrings.helpSupport,
                  onTap: () {},
                ),
                const AppDivider(),
                _NavTile(
                  icon: Icons.description_outlined,
                  title: AppStrings.termsOfService,
                  onTap: () {},
                ),
                const AppDivider(),
                _NavTile(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.version,
                  trailing: AppStrings.versionValue,
                  onTap: null,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: _SectionGap()),

          // Danger zone
          SliverToBoxAdapter(
            child: _SettingsCard(
              children: [
                _DangerTile(
                  icon: Icons.logout_rounded,
                  title: AppStrings.logOut,
                  onTap: () => _confirmLogout(context),
                ),
                const AppDivider(),
                _DangerTile(
                  icon: Icons.delete_outline_rounded,
                  title: AppStrings.deleteAccount,
                  onTap: () {},
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(height: AppDimens.vmassive),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.logOut),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.onboarding);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.logOut),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Preview ──────────────────────────────────────────────────────────
class _ProfilePreviewTile extends StatelessWidget {
  const _ProfilePreviewTile({required this.user, required this.onEditTap});

  final dynamic user;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppDimens.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.darkBorderSubtle
                : AppColors.lightBorderSubtle,
          ),
        ),
      ),
      child: Row(
        children: [
          AppAvatar(
            imageUrl: user.avatarUrl,
            initials: user.initials,
            size: AvatarSize.lg,
          ),
          Gap(AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: AppTextStyles.h4.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Gap(2.h),
                Text(
                  '@${user.username}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: AppDimens.buttonHeightSm,
            child: OutlinedButton(
              onPressed: onEditTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: AppDimens.lg),
              ),
              child: Text(AppStrings.edit),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Gap ──────────────────────────────────────────────────────────────
class _SectionGap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 8.h,
      color: isDark ? AppColors.darkBackground : AppColors.lightElevated,
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(children: children),
    );
  }
}

// ─── Toggle Tile ──────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.xl,
        vertical: AppDimens.vmd,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppDimens.iconMd,
            color: AppColors.primary,
          ),
          Gap(AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  Gap(2.h),
                  Text(
                    subtitle!,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Nav Tile ─────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.xl,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimens.iconMd, color: AppColors.primary),
            Gap(AppDimens.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Gap(2.h),
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextMuted
                      : AppColors.lightTextMuted,
                ),
              ),
            if (onTap != null) ...[
              Gap(AppDimens.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimens.iconSm,
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Danger Tile ──────────────────────────────────────────────────────────────
class _DangerTile extends StatelessWidget {
  const _DangerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.xl,
          vertical: AppDimens.vmd,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppDimens.iconMd, color: AppColors.error),
            Gap(AppDimens.lg),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
