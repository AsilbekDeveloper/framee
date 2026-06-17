import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({
    super.key,
    required this.initialEmail,
    required this.onSend,
  });

  final String initialEmail;
  final ValueChanged<String> onSend;

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.resetPassword),
      content: TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        decoration: InputDecoration(
          labelText: AppStrings.emailAddressLabel,
          hintText: 'example@mail.com',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            final email = _emailCtrl.text.trim();
            context.pop();
            widget.onSend(email);
          },
          child: Text(AppStrings.send),
        ),
      ],
    );
  }
}
