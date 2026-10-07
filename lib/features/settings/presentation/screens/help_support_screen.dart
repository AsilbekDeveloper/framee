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
              child: SettingsCard(
                children: [
                  _FaqTile(
                    question: AppStrings.faqResetPasswordQ,
                    answer: AppStrings.faqResetPasswordA,
                  ),
                  const AppDivider(),
                  _FaqTile(
                    question: AppStrings.faqDeleteAccountQ,
                    answer: AppStrings.faqDeleteAccountA,
                  ),
                  const AppDivider(),
                  _FaqTile(
                    question: AppStrings.faqPrivateAccountQ,
                    answer: AppStrings.faqPrivateAccountA,
                  ),
                  const AppDivider(),
                  _FaqTile(
                    question: AppStrings.faqReportQ,
                    answer: AppStrings.faqReportA,
                  ),
                  const AppDivider(),
                  _FaqTile(
                    question: AppStrings.faqContactQ,
                    answer: AppStrings.faqContactA,
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
