import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/ui/component/paged_view/no_more_items_view/common_no_more_items_indicator.dart';
import '../../../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('basic', (tester) async {
        await tester.testWidget(
          filename: 'common_no_more_items_indicator/basic',
          widget: const UnconstrainedBox(
            child: CommonNoMoreItemsIndicator(),
          ),
        );
      });

      testGoldens('in sized box', (tester) async {
        await tester.testWidget(
          filename: 'common_no_more_items_indicator/in sized box',
          widget: const SizedBox(
            width: 50,
            height: 50,
            child: CommonNoMoreItemsIndicator(),
          ),
        );
      });
    },
  );
}
