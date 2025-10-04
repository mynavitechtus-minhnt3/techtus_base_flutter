import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens(
        'default',
        (tester) async {
          await tester.testWidget(
            filename: 'confirm_dialog/default',
            widget: const ConfirmDialog(
              message: 'Are you sure you want to sign out?',
            ),
            overrides: [
              appNavigatorProvider.overrideWith((ref) => navigator),
            ],
          );
        },
      );

      testGoldens(
        'long message + custom button labels',
        (tester) async {
          await tester.testWidget(
            filename: 'confirm_dialog/long message + custom button labels',
            widget: const ConfirmDialog(
              message:
                  'Deleting this conversation is permanent and cannot be undone. Do you want to continue?',
              confirmButtonText: 'Proceed anyway',
              cancelButtonText: 'Never mind',
            ),
            overrides: [
              appNavigatorProvider.overrideWith((ref) => navigator),
            ],
          );
        },
      );
    },
  );
}
