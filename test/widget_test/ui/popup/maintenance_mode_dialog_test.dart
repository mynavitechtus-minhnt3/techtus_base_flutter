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
            filename: 'maintenance_mode_dialog/default',
            widget: const MaintenanceModeDialog(
              message: 'The service is temporarily unavailable while we perform maintenance.',
            ),
          );
        },
      );

      testGoldens(
        'long message + line break',
        (tester) async {
          await tester.testWidget(
            filename: 'maintenance_mode_dialog/long message + line break',
            widget: const MaintenanceModeDialog(
              message:
                  'We are currently updating our systems to serve you better.\nThank you for your patience until maintenance is complete.',
            ),
          );
        },
      );
    },
  );
}
