import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/shared_widgets.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = ref.watch(themeModeProvider).valueOrNull == ThemeMode.dark;
    final currentLocale = ref.watch(localeProvider).valueOrNull ?? AppLocale.en;

    final profile = ref.watch(profileProvider(null)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.settings),
      ),
      body: CustomScrollView(
        slivers: [
          // Profile preview
          if (profile != null)
            SliverToBoxAdapter(
              child: _ProfilePreviewTile(
                profile: profile,
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
                  trailing: _localeName(currentLocale),
                  onTap: () => _showLanguagePicker(context, ref, currentLocale),
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
                  icon: Icons.bookmark_border_rounded,
                  title: AppStrings.saved,
                  onTap: () => context.push(AppRoutes.savedPosts),
                ),
                const AppDivider(),
                _NavTile(
                  icon: Icons.shield_outlined,
                  title: AppStrings.privacy,
                  subtitle: AppStrings.privacySub,
                  onTap: () {},
                ),
                const AppDivider(),
                _NavTile(
                  icon: Icons.lock_outline_rounded,
                  title: AppStrings.changePassword,
                  subtitle: AppStrings.securitySub,
                  onTap: () => _showChangePasswordSheet(context, ref),
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
                  onTap: () => _confirmLogout(context, ref),
                ),
                const AppDivider(),
                _DangerTile(
                  icon: Icons.delete_outline_rounded,
                  title: AppStrings.deleteAccount,
                  onTap: () => _confirmDeleteAccount(context, ref),
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

  String _localeName(AppLocale locale) {
    return switch (locale) {
      AppLocale.en => AppStrings.english,
      AppLocale.uz => AppStrings.uzbek,
      AppLocale.ru => AppStrings.russian,
    };
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, AppLocale current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(current: current),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAccount),
        content: const Text(
          'Hisobingizni o\'chirishni xohlaysizmi? Bu amalni qaytarib bo\'lmaydi.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              final result = await ref
                  .read(deleteAccountUseCaseProvider)
                  .call();
              if (result.isErr && context.mounted) {
                context.showSnackBar('Xatolik yuz berdi. Qayta urinib ko\'ring.');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.deleteAccount),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.logOut),
        content: const Text('Tizimdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              // Supabase sessionini tugatadi â€” router avtomatik /onboarding ga yo'naltiradi
              await ref.read(authProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppStrings.logOut),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Change Password Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final newPw = _newPasswordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (newPw.isEmpty || confirm.isEmpty) {
      setState(() => _errorMessage = 'Barcha maydonlarni to\'ldiring');
      return;
    }
    if (newPw != confirm) {
      setState(() => _errorMessage = AppStrings.passwordMismatch);
      return;
    }
    if (newPw.length < 6) {
      setState(() => _errorMessage = 'Parol kamida 6 ta belgi bo\'lsin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result =
        await ref.read(updatePasswordUseCaseProvider).call(newPw);

    if (!mounted) return;
    setState(() => _isLoading = false);

    switch (result) {
      case Ok():
        context.pop();
        context.showSnackBar(AppStrings.passwordChanged);
      case Err(:final failure):
        setState(() => _errorMessage = failure.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.xl,
        AppDimens.vxl,
        AppDimens.xl,
        AppDimens.vxl + bottomPadding,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(AppDimens.vxl),
          Text(AppStrings.changePassword, style: AppTextStyles.h3),
          Gap(AppDimens.vxl),

          AppTextField(
            controller: _newPasswordController,
            label: AppStrings.newPassword,
            obscureText: true,
          ),
          Gap(AppDimens.vmd),

          AppTextField(
            controller: _confirmController,
            label: AppStrings.confirmPassword,
            obscureText: true,
          ),

          if (_errorMessage != null) ...[
            Gap(AppDimens.vmd),
            Text(
              _errorMessage!,
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
            ),
          ],

          Gap(AppDimens.vlg),
          AppButton(
            label: AppStrings.save,
            onPressed: _submit,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Profile Preview â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ProfilePreviewTile extends StatelessWidget {
  const _ProfilePreviewTile({required this.profile, required this.onEditTap});

  final Profile profile;
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
            imageUrl: profile.avatarUrl,
            initials: profile.initials,
            size: AvatarSize.lg,
          ),
          Gap(AppDimens.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: AppTextStyles.h4.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Gap(2.h),
                Text(
                  '@${profile.username}',
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.darkTextMuted
                        : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onEditTap,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(0, AppDimens.buttonHeightSm),
              padding: EdgeInsets.symmetric(horizontal: AppDimens.lg),
            ),
            child: Text(AppStrings.edit),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Section Gap â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Settings Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Toggle Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Nav Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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

// â”€â”€â”€ Danger Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
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
            Icon(icon, size: AppDimens.iconMd, color: AppColors.error), // danger tile
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

// â”€â”€â”€ Language Picker Sheet â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _LanguagePickerSheet extends ConsumerWidget {
  const _LanguagePickerSheet({required this.current});

  final AppLocale current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final langs = [
      (AppLocale.en, AppStrings.english, 'ðŸ‡ºðŸ‡¸'),
      (AppLocale.uz, AppStrings.uzbek, 'ðŸ‡ºðŸ‡¿'),
      (AppLocale.ru, AppStrings.russian, 'ðŸ‡·ðŸ‡º'),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.xl,
        AppDimens.vxl,
        AppDimens.xl,
        AppDimens.vxl + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBorderSubtle
                    : AppColors.lightBorderSubtle,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(AppDimens.vxl),
          Text(AppStrings.language, style: AppTextStyles.h3),
          Gap(AppDimens.vlg),
          ...langs.map((item) {
            final (locale, name, flag) = item;
            final isSelected = locale == current;
            return InkWell(
              onTap: () async {
                await ref.read(localeProvider.notifier).setLocale(locale);
                if (context.mounted) context.pop();
              },
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AppDimens.vmd,
                  horizontal: AppDimens.sm,
                ),
                child: Row(
                  children: [
                    Text(flag, style: TextStyle(fontSize: 24.sp)),
                    Gap(AppDimens.lg),
                    Expanded(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: AppDimens.iconSm,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

