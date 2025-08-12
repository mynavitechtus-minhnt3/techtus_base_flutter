import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/ui/component/ui_kit/paged_view/error_view/common_first_page_error_indicator.dart';
import '../../../../../../common/index.dart';

void main() {
  group(
    'CommonFirstPageErrorIndicator',
    () {
      testGoldens('basic', (tester) async {
        await tester.testWidget(
          filename: 'common_first_page_error_indicator/basic',
          widget: const UnconstrainedBox(
            child: CommonFirstPageErrorIndicator(),
          ),
        );
      });

      testGoldens('in sized box', (tester) async {
        await tester.testWidget(
          filename: 'common_first_page_error_indicator/in_sized_box',
          widget: const SizedBox(
            width: 50,
            height: 50,
            child: CommonFirstPageErrorIndicator(),
          ),
        );
      });
    },
  );
}
