import 'package:flutter/material.dart';

import '../../../index.dart';

class CommonPopup {
  const CommonPopup._({
    required this.builder,
    required this.id,
  });

  final String id;
  final Widget Function(BuildContext, AppNavigator) builder;

  @override
  String toString() {
    return id;
  }

  static CommonPopup errorDialog(
    String message,
  ) {
    return CommonPopup._(
      id: 'errorDialog_$message'.hardcoded,
      builder: (context, _) => ErrorDialog(
        message: message,
      ),
    );
  }

  static CommonPopup errorWithRetryDialog({
    required String message,
    required VoidCallback onRetryPressed,
  }) {
    return CommonPopup._(
      id: 'errorWithRetryDialog_$message'.hardcoded,
      builder: (context, navigator) => ErrorWithRetryDialog(
        message: message,
        onRetryPressed: onRetryPressed,
      ),
    );
  }

  static CommonPopup maintenanceModeDialog({
    required String message,
  }) {
    return CommonPopup._(
      id: 'maintenanceModeDialog_$message'.hardcoded,
      builder: (context, navigator) => MaintenanceModeDialog(
        message: message,
      ),
    );
  }

  static CommonPopup errorSnackBar(String message) {
    return CommonPopup._(
      id: 'errorSnackBar_$message'.hardcoded,
      builder: (context, navigator) => SnackBar(
        content: CommonText(
          message,
          style: null,
        ),
        duration: Constant.snackBarDuration,
        backgroundColor: color.black,
      ),
    );
  }

  static CommonPopup confirmDialog({
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    String? confirmButtonText,
    String? cancelButtonText,
  }) {
    return CommonPopup._(
      id: 'confirmDialog_$message'.hardcoded,
      builder: (context, navigator) => ConfirmDialog(
        message: message,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
      ),
    );
  }
}
