import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/components/shared_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../widgets/settings_tiles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(AppStrings.helpSupport),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: AppDimens.vxl)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.screenPadding),
              child: const SettingsCard(
                children: [
                  _FaqTile(
                    question: 'How do I reset my password?',
                    answer:
                        'Go to Settings → Change Password. Enter your current password and choose a new one. '
                        'If you have forgotten your password, use the "Forgot Password" link on the login screen.',
                  ),
                  AppDivider(),
                  _FaqTile(
                    question: 'How do I delete my account?',
                    answer:
                        'Go to Settings and tap "Delete Account" at the bottom. '
                        'This action is permanent and cannot be undone.',
                  ),
                  AppDivider(),
                  _FaqTile(
                    question: "Why can't I see someone's posts?",
                    answer:
                        'The account may be private. Send them a follow request to access their content.',
                  ),
                  AppDivider(),
                  _FaqTile(
                    question: 'How do I report a post or user?',
                    answer:
                        'Email us at support@framee.app with a link to the post or profile and a brief description. '
                        'We review all reports and take appropriate action within 24 hours.',
                  ),
                  AppDivider(),
                  _FaqTile(
                    question: 'How do I contact support?',
                    answer:
                        'Email us at support@framee.app. '
                        'We respond to all inquiries within 2 business days.',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: AppDimens.vmassive)),
        ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimens.lg,
          vertical: AppDimens.vmd,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: AppDimens.iconMd,
                  color:
                      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ],
            ),
            if (_expanded) ...[
              SizedBox(height: AppDimens.vsm),
              Text(
                widget.answer,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
