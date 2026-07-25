import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_setup_provider.dart';
import '../widgets/setup_header.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<ProfileSetupState>(profileSetupProvider, (prev, next) {
      if (next.isSaved) {
        context.go(AppRoutes.home);
      } else if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        // Surface save failures (e.g. username taken) instead of silently
        // proceeding — the button no longer navigates on its own.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () =>
                ref.read(authProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(AppStrings.logOut),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SetupHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                  vertical: AppDimens.vxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: AvatarUpload(
                        imageUrl: state.avatarLocalPath,
                        onTap: () => notifier.pickAvatar(context),
                        size: 96,
                        label: AppStrings.addProfilePhoto,
                      ),
                    ),
                    Gap(AppDimens.vxxxl),

                    AppTextField(
                      controller: _usernameController,
                      label: AppStrings.username,
                      hint: AppStrings.usernamePlaceholder,
                      prefixIcon: Icon(
                        Icons.alternate_email_rounded,
                        size: AppDimens.iconSm,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                      suffixIcon: state.isUsernameAvailable == true
                          ? Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: AppDimens.iconSm)
                          : state.isUsernameAvailable == false
                              ? Icon(Icons.cancel_rounded,
                                  color: AppColors.error, size: AppDimens.iconSm)
                              : null,
                      onChanged: notifier.onUsernameChanged,
                      textInputAction: TextInputAction.next,
                    ),
                    if (state.isUsernameAvailable == true) ...[
                      Gap(AppDimens.vxs),
                      Text(AppStrings.usernameAvailable,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.success)),
                    ],
                    if (state.isUsernameAvailable == false) ...[
                      Gap(AppDimens.vxs),
                      Text(AppStrings.usernameTaken,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.error)),
                    ],
                    Gap(AppDimens.vlg),

                    AppTextField(
                      controller: _displayNameController,
                      label: AppStrings.displayName,
                      hint: AppStrings.displayNamePlaceholder,
                      prefixIcon: Icon(
                        Icons.edit_outlined,
                        size: AppDimens.iconSm,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    Gap(AppDimens.vlg),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppStrings.bio.toUpperCase(),
                              style: AppTextStyles.inputLabel.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Gap(4.w),
                            Text(
                              AppStrings.optional,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                        Gap(6.h),
                        AppTextField(
                          controller: _bioController,
                          hint: AppStrings.bioPlaceholder,
                          maxLines: 3,
                          maxLength: AppConfig.maxBioLength,
                          onChanged: notifier.onBioChanged,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(4.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${state.bioLength} / ${AppConfig.maxBioLength}',
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(AppDimens.vlg),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppStrings.website.toUpperCase(),
                              style: AppTextStyles.inputLabel.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Gap(4.w),
                            Text(
                              AppStrings.optional,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                        Gap(6.h),
                        AppTextField(
                          controller: _websiteController,
                          hint: AppStrings.websitePlaceholder,
                          prefixIcon: Icon(
                            Icons.link_rounded,
                            size: AppDimens.iconSm,
                            color: isDark
                                ? AppColors.darkTextMuted
                                : AppColors.lightTextMuted,
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                        ),
                      ],
                    ),
                    Gap(AppDimens.vxxxl),

                    AppButton(
                      label: AppStrings.saveAndContinue,
                      // Navigation happens in the ref.listen above, but only on
                      // success (isSaved) — a failed save stays on this screen
                      // and shows the error.
                      onPressed: () => notifier.save(
                        username: _usernameController.text,
                        displayName: _displayNameController.text,
                        bio: _bioController.text,
                        website: _websiteController.text,
                      ),
                      isLoading: state.isSaving,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
