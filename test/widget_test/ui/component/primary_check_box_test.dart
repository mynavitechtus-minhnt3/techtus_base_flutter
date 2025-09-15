// ignore_for_file: prefer_common_widgets
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('when text is null and init value is false and isEnabled is false',
          (tester) async {
        await tester.testWidget(
          filename:
              'primary_check_box/when text is null and init value is false and isEnabled is false',
          widget: const PrimaryCheckBox(
            text: null,
            initValue: false,
            isEnabled: false,
          ),
        );
      });

      testGoldens('when text is not null and init value is true and isEnabled is true',
          (tester) async {
        await tester.testWidget(
          filename:
              'primary_check_box/when text is not null and init value is true and isEnabled is true',
          widget: PrimaryCheckBox(
            text: Text('long long long long text' * 10),
            initValue: true,
            isEnabled: true,
          ),
        );
      });

      testGoldens('when text is not null and init value is true and isEnabled is false',
          (tester) async {
        await tester.testWidget(
          filename:
              'primary_check_box/when text is not null and init value is true and isEnabled is false',
          widget: const PrimaryCheckBox(
            text: Text('Minh'),
            initValue: true,
            isEnabled: false,
          ),
        );
      });
    },
  );
}
