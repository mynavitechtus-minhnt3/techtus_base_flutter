import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/ui/component/ui_kit/paged_view/error_view/common_new_page_error_indicator.dart';
import '../../../../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('basic', (tester) async {
        await tester.testWidget(
          filename: 'common_new_page_error_indicator/basic',
          widget: const UnconstrainedBox(
            child: CommonNewPageErrorIndicator(),
          ),
        );
      });

      testGoldens('in sized box', (tester) async {
        await tester.testWidget(
          filename: 'common_new_page_error_indicator/in sized box',
          widget: const SizedBox(
            width: 50,
            height: 50,
            child: CommonNewPageErrorIndicator(),
          ),
        );
      });
    },
  );
}
