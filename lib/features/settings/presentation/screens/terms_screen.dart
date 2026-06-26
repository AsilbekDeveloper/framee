import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bodyColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final mutedColor =
        isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.termsOfService),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.screenPadding,
          vertical: AppDimens.vxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: June 2025',
              style: AppTextStyles.caption.copyWith(color: mutedColor),
            ),
            SizedBox(height: AppDimens.vxl),
            _Section(
              title: '1. Acceptance of Terms',
              body:
                  'By using Framee, you agree to these Terms of Service. '
                  'If you do not agree, please do not use the app.',
              bodyColor: bodyColor,
            ),
            _Section(
              title: '2. User Content',
              body:
                  'You retain ownership of content you post. By posting, you grant Framee '
                  'a non-exclusive license to display your content within the app. '
                  'You are responsible for ensuring you have the rights to any content you share.',
              bodyColor: bodyColor,
            ),
            _Section(
              title: '3. Prohibited Conduct',
              body:
                  'You may not use Framee to post illegal content, harass others, '
                  'spread misinformation, or violate any applicable laws. '
                  'We reserve the right to remove content and suspend accounts that violate these terms.',
              bodyColor: bodyColor,
            ),
            _Section(
              title: '4. Privacy',
              body:
                  'We collect only the data necessary to provide the service. '
                  'We do not sell your personal data to third parties. '
                  'See our Privacy Policy for full details.',
              bodyColor: bodyColor,
            ),
            _Section(
              title: '5. Termination',
              body:
                  'We may suspend or terminate your account at any time for violations of these terms. '
                  'You may delete your account at any time from Settings.',
              bodyColor: bodyColor,
            ),
            _Section(
              title: '6. Limitation of Liability',
              body:
                  'Framee is provided "as is" without warranty of any kind. '
                  'We are not liable for any damages arising from your use of the service.',
              bodyColor: bodyColor,
            ),
            _Section(
              title: '7. Changes to Terms',
              body:
                  'We may update these terms periodically. '
                  'Continued use of Framee after changes constitutes acceptance of the new terms.',
              bodyColor: bodyColor,
            ),
            SizedBox(height: AppDimens.vmd),
            Text(
              'For questions, contact us at legal@framee.app',
              style: AppTextStyles.caption.copyWith(color: mutedColor),
            ),
            SizedBox(height: AppDimens.vmassive),
          ],
        ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.body,
    required this.bodyColor,
  });

  final String title;
  final String body;
  final Color bodyColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDimens.vxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(color: bodyColor),
          ),
          SizedBox(height: AppDimens.vsm),
          Text(
            body,
            style: AppTextStyles.bodySmall
                .copyWith(color: bodyColor, height: 1.6),
          ),
        ],
      ),
    );
  }
}
