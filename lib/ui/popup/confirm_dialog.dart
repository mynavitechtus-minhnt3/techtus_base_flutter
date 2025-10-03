import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../index.dart';

class ConfirmDialog extends ConsumerWidget {
  const ConfirmDialog({
    super.key,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonText,
    this.cancelButtonText,
  });

  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmButtonText;
  final String? cancelButtonText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog.adaptive(
      title: CommonText(
        message,
        style: style(
          color: color.black,
          fontSize: 14.rps,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.nav.pop(result: false);
            onCancel?.call();
          },
          child: CommonText(cancelButtonText ?? l10n.cancel, style: null),
        ),
        TextButton(
          onPressed: () {
            ref.nav.pop(result: true);
            onConfirm?.call();
          },
          child: CommonText(confirmButtonText ?? l10n.ok, style: null),
        ),
      ],
    );
  }
}
