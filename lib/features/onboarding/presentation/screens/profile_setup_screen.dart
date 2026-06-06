import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/app_avatar.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/components/app_text_field.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_router.dart';
import '../providers/profile_setup_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  // 1. Controllers live safely in the UI state
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    // 2. Dispose of controllers to prevent memory leaks
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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            _SetupHeader(step: state.step),
            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPadding,
                  vertical: AppDimens.vxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar upload
                    Center(
                      child: AvatarUpload(
                        imageUrl: state.avatarUrl,
                        onTap: notifier.pickAvatar,
                        size: 96,
                        label: AppStrings.addProfilePhoto,
                      ),
                    ),
                    Gap(AppDimens.vxxxl),

                    // Username
                    AppTextField(
                      controller: _usernameController, // Bound to local controller
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
                          ? Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: AppDimens.iconSm,
                      )
                          : state.isUsernameAvailable == false
                          ? Icon(
                        Icons.cancel_rounded,
                        color: AppColors.error,
                        size: AppDimens.iconSm,
                      )
                          : null,
                      onChanged: notifier.onUsernameChanged,
                      textInputAction: TextInputAction.next,
                    ),
                    if (state.isUsernameAvailable == true) ...[
                      Gap(AppDimens.vxs),
                      Text(
                        AppStrings.usernameAvailable,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                    if (state.isUsernameAvailable == false) ...[
                      Gap(AppDimens.vxs),
                      Text(
                        AppStrings.usernameTaken,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                    ],
                    Gap(AppDimens.vlg),

                    // Display Name
                    AppTextField(
                      controller: _displayNameController, // Bound to local controller
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

                    // Bio
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
                          controller: _bioController, // Bound to local controller
                          hint: AppStrings.bioPlaceholder,
                          maxLines: 3,
                          maxLength: 150,
                          // Pass the string value directly to the notifier
                          onChanged: notifier.onBioChanged,
                          textInputAction: TextInputAction.next,
                        ),
                        Gap(4.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${state.bioLength} / 150',
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

                    // Website
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
                          controller: _websiteController, // Bound to local controller
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
                      onPressed: () async {
                        // 3. Pass values to the notifier's save method
                        await notifier.save(
                          username: _usernameController.text,
                          displayName: _displayNameController.text,
                          bio: _bioController.text,
                          website: _websiteController.text,
                        );

                        if (context.mounted) {
                          context.go(AppRoutes.home);
                        }
                      },
                      isLoading: state.isSaving,
                    ),
                    Gap(AppDimens.vmd),
                    AppButton(
                      label: AppStrings.skipForNow,
                      variant: AppButtonVariant.ghost,
                      onPressed: () => context.go(AppRoutes.home),
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

class _SetupHeader extends StatelessWidget {
  const _SetupHeader({required this.step});
  final int step;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPadding,
        AppDimens.vxl,
        AppDimens.screenPadding,
        0,
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.setUpProfile, style: AppTextStyles.h2),
          Gap(4.h),
          Text(
            AppStrings.setUpProfileSub,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          Gap(AppDimens.vlg),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: step / 3,
              backgroundColor:
              isDark ? AppColors.darkElevated : AppColors.lightElevated,
              color: AppColors.primary,
              minHeight: 3.h,
            ),
          ),
        ],
      ),
    );
  }
}