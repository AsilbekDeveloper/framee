import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      title: const Text('Parolni tiklash'),
      content: TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Email manzilingiz',
          hintText: 'example@mail.com',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Bekor qilish'),
        ),
        TextButton(
          onPressed: () {
            final email = _emailCtrl.text.trim();
            context.pop();
            widget.onSend(email);
          },
          child: const Text('Yuborish'),
        ),
      ],
    );
  }
}
