import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/extensions.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/data/providers/auth_data_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../widgets/change_password_sheet.dart';
import '../widgets/settings_language_tile.dart';
import '../widgets/settings_profile_tile.dart';
import '../widgets/settings_tiles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final isDark = ref.watch(themeModeProvider).valueOrNull == ThemeMode.dark;
    final currentLocale =
        ref.watch(localeProvider).valueOrNull ?? AppLocale.en;
    final profile = ref.watch(profileProvider(null)).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.settings),
      ),
      body: CustomScrollView(
        slivers: [
          if (profile != null)
            SliverToBoxAdapter(
              child: SettingsProfilePreviewTile(
                profile: profile,
                onEditTap: () => context.push(AppRoutes.editProfile),
              ),
            ),

          SliverToBoxAdapter(child: SettingsSectionGap()),

          SliverToBoxAdapter(child: SectionLabel(AppStrings.appearance)),
          SliverToBoxAdapter(
            child: SettingsCard(
              children: [
                SettingsToggleTile(
                  icon: Icons.dark_mode_outlined,
                  title: AppStrings.darkMode,
                  subtitle: AppStrings.darkModeSub,
                  value: isDark,
                  onChanged: (_) => themeNotifier.toggleDarkMode(),
                ),
                const AppDivider(),
                SettingsLanguageTile(currentLocale: currentLocale),
              ],
            ),
          ),

          SliverToBoxAdapter(child: SettingsSectionGap()),

          SliverToBoxAdapter(child: SectionLabel(AppStrings.privacySecurity)),
          SliverToBoxAdapter(
            child: SettingsCard(
              children: [
                SettingsNavTile(
                  icon: Icons.bookmark_border_rounded,
                  title: AppStrings.saved,
                  onTap: () => context.push(AppRoutes.savedPosts),
                ),
                const AppDivider(),
                SettingsNavTile(
                  icon: Icons.shield_outlined,
                  title: AppStrings.privacy,
                  subtitle: AppStrings.privacySub,
                  onTap: () {},
                ),
                const AppDivider(),
                SettingsNavTile(
                  icon: Icons.lock_outline_rounded,
                  title: AppStrings.changePassword,
                  subtitle: AppStrings.securitySub,
                  onTap: () => _showChangePasswordSheet(context),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: SettingsSectionGap()),

          SliverToBoxAdapter(
              child: SectionLabel(AppStrings.notificationsLabel)),
          SliverToBoxAdapter(
            child: SettingsCard(
              children: [
                SettingsToggleTile(
                  icon: Icons.notifications_outlined,
                  title: AppStrings.pushNotifications,
                  value: true,
                  onChanged: (_) {},
                ),
                const AppDivider(),
                SettingsToggleTile(
                  icon: Icons.mail_outline_rounded,
                  title: AppStrings.emailNotifications,
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: SettingsSectionGap()),

          SliverToBoxAdapter(child: SectionLabel(AppStrings.about)),
          SliverToBoxAdapter(
            child: SettingsCard(
              children: [
                SettingsNavTile(
                  icon: Icons.help_outline_rounded,
                  title: AppStrings.helpSupport,
                  onTap: () {},
                ),
                const AppDivider(),
                SettingsNavTile(
                  icon: Icons.description_outlined,
                  title: AppStrings.termsOfService,
                  onTap: () {},
                ),
                const AppDivider(),
                SettingsNavTile(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.version,
                  trailing: AppStrings.versionValue,
                  onTap: null,
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: SettingsSectionGap()),

          SliverToBoxAdapter(
            child: SettingsCard(
              children: [
                SettingsDangerTile(
                  icon: Icons.logout_rounded,
                  title: AppStrings.logOut,
                  onTap: () => _confirmLogout(context, ref),
                ),
                const AppDivider(),
                SettingsDangerTile(
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

  void _showChangePasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChangePasswordSheet(),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.deleteAccount),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
              final result =
                  await ref.read(deleteAccountUseCaseProvider).call();
              if (result.isErr && context.mounted) {
                context.showSnackBar(
                    'Something went wrong. Please try again.');
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
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              ctx.pop();
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
