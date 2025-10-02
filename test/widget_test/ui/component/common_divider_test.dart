import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/ui/component/common_divider.dart';
import '../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('horizontal', (tester) async {
        await tester.testWidget(
          filename: 'common_divider/horizontal',
          widget: const CommonDivider(
            color: Colors.black,
            thickness: 2,
          ),
          includeTextScalingCase: false,
        );
      });

      testGoldens('vertical', (tester) async {
        await tester.testWidget(
          filename: 'common_divider/vertical',
          widget: const SizedBox(
            height: 100,
            child: CommonDivider(
              direction: DividerDirection.vertical,
              color: Colors.black,
              thickness: 2,
            ),
          ),
          includeTextScalingCase: false,
        );
      });

      testGoldens('horizontal with indent', (tester) async {
        await tester.testWidget(
          filename: 'common_divider/horizontal with indent',
          widget: const CommonDivider(
            color: Colors.black,
            thickness: 2,
            indent: 8,
            endIndent: 8,
          ),
          includeTextScalingCase: false,
        );
      });
    },
  );
}
