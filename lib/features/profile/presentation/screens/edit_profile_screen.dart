import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../providers/edit_profile_provider.dart';
import '../widgets/toggle_row.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editProfileProvider);
    final notifier = ref.read(editProfileProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pop the screen and show a success snackbar after a successful save
    ref.listen<EditProfileState>(editProfileProvider, (prev, next) {
      if (next.savedSuccessfully && !(prev?.savedSuccessfully ?? false)) {
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.profileUpdated),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
      // Show error message via SnackBar
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.editProfile),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: AppDimens.lg),
            child: GestureDetector(
              onTap: state.isSaving ? null : notifier.save,
              child: Container(
                height: AppDimens.buttonHeightSm,
                padding: EdgeInsets.symmetric(horizontal: AppDimens.xl),
                decoration: BoxDecoration(
                  gradient: state.isSaving
                      ? null
                      : AppColors.primaryGradient,
                  color: state.isSaving
                      ? (isDark ? AppColors.darkElevated : AppColors.lightElevated)
                      : null,
                  borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Center(
                  child: state.isSaving
                      ? SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                        )
                      : Text(
                          AppStrings.save,
                          style: AppTextStyles.buttonSmall
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.vxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: AvatarUpload(
                imageUrl: state.avatarPreviewPath,
                onTap: () => notifier.pickAvatar(context),
                size: 88,
                label: AppStrings.changePhoto,
              ),
            ),
            Gap(AppDimens.vxxxl),

            // Username
            AppTextField(
              controller: notifier.usernameController,
              label: AppStrings.username,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(
                Icons.alternate_email_rounded,
                size: AppDimens.iconSm,
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            Gap(AppDimens.vlg),

            // Display name
            AppTextField(
              controller: notifier.displayNameController,
              label: AppStrings.displayName,
              textInputAction: TextInputAction.next,
            ),
            Gap(AppDimens.vlg),

            // Bio
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  controller: notifier.bioController,
                  label: AppStrings.bio,
                  maxLines: 3,
                  maxLength: AppConfig.maxBioLength,
                  onChanged: (_) => notifier.onBioChanged(),
                  textInputAction: TextInputAction.next,
                ),
                Gap(4.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${state.bioLength} / ${AppConfig.maxBioLength}',
                    style: AppTextStyles.caption.copyWith(
                      color: state.bioLength > AppConfig.maxBioLength - 10
                          ? AppColors.error
                          : isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                    ),
                  ),
                ),
              ],
            ),
            Gap(AppDimens.vlg),

            // Website
            AppTextField(
              controller: notifier.websiteController,
              label: AppStrings.website,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              prefixIcon: Icon(
                Icons.link_rounded,
                size: AppDimens.iconSm,
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            Gap(AppDimens.vlg),

            // Email (read-only — cannot be changed here)
            AppTextField(
              controller: notifier.emailController,
              label: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              enabled: false,
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: AppDimens.iconSm,
                color:
                    isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            Gap(AppDimens.vxl),

            // Section label
            Divider(
              color: isDark
                  ? AppColors.darkBorderSubtle
                  : AppColors.lightBorderSubtle,
            ),
            Gap(AppDimens.vmd),
            Text(
              AppStrings.accountSettings.toUpperCase(),
              style: AppTextStyles.sectionLabel.copyWith(
                color: isDark
                    ? AppColors.darkTextMuted
                    : AppColors.lightTextMuted,
              ),
            ),
            Gap(AppDimens.vmd),

            // Toggles
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorderSubtle,
                ),
              ),
              child: ToggleRow(
                title: AppStrings.privateAccount,
                subtitle: AppStrings.privateAccountSub,
                value: state.isPrivate,
                onChanged: notifier.setPrivate,
              ),
            ),
            Gap(AppDimens.vmassive),
          ],
        ),
      ),
    );
  }
}
