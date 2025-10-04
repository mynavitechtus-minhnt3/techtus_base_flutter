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
            filename: 'error_dialog/default',
            widget: const ErrorDialog(
              message: 'An unexpected error occurred.',
            ),
            overrides: [
              appNavigatorProvider.overrideWith((ref) => navigator),
            ],
          );
        },
      );

      testGoldens(
        'long message + line breaks',
        (tester) async {
          await tester.testWidget(
            filename: 'error_dialog/long message + line breaks',
            widget: const ErrorDialog(
              message:
                  'An unexpected error occurred.\nPlease try again later. If this continues, contact support@example.com.',
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
