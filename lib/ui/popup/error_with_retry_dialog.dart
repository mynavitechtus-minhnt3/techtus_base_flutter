import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../index.dart';

class ErrorWithRetryDialog extends ConsumerWidget {
  const ErrorWithRetryDialog({
    super.key,
    required this.message,
    required this.onRetryPressed,
  });

  final String message;
  final VoidCallback onRetryPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      actions: [
        TextButton(
          onPressed: () => ref.nav.pop(),
          child: CommonText(
            l10n.cancel,
            style: null,
          ),
        ),
        TextButton(
          onPressed: () {
            ref.nav.pop();
            onRetryPressed.call();
          },
          child: CommonText(
            l10n.retry,
            style: null,
          ),
        ),
      ],
      content: CommonText(
        message,
        style: null,
      ),
    );
  }
}
