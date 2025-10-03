import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../common/index.dart';

void _noop() {}

void main() {
  group(
    'others',
    () {
      testGoldens(
        'default',
        (tester) async {
          await tester.testWidget(
            filename: 'error_with_retry_dialog/default',
            widget: const ErrorWithRetryDialog(
              message: 'We could not complete your request. Please try again.',
              onRetryPressed: _noop,
            ),
            overrides: [
              appNavigatorProvider.overrideWith((ref) => navigator),
            ],
          );
        },
      );

      testGoldens(
        'long message + line break',
        (tester) async {
          await tester.testWidget(
            filename: 'error_with_retry_dialog/long message + line break',
            widget: const ErrorWithRetryDialog(
              message:
                  'We lost the connection to the server.\nTap retry after checking your internet connection.',
              onRetryPressed: _noop,
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
