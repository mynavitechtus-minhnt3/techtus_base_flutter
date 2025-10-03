import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../index.dart';

class ErrorDialog extends ConsumerWidget {
  const ErrorDialog({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      actions: [
        TextButton(
          onPressed: () => ref.nav.pop(),
          child: CommonText(
            l10n.ok,
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
