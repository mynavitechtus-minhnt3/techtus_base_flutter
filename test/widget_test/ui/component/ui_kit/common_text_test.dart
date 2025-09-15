//ignore_for_file: avoid_using_text_style_constructor_directly
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/ui/component/ui_kit/common_text.dart';
import '../../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('basic', (tester) async {
        await tester.testWidget(
          filename: 'common_text/basic',
          widget: const UnconstrainedBox(
            child: CommonText(
              'Hello',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      });

      testGoldens('with linkify', (tester) async {
        await tester.testWidget(
          filename: 'common_text/with_linkify',
          widget: const UnconstrainedBox(
            child: CommonText(
              'Visit https://example.com',
              style: TextStyle(fontSize: 16),
              enableLinkify: true,
            ),
          ),
        );
      });

      testGoldens('with max lines and overflow', (tester) async {
        await tester.testWidget(
          filename: 'common_text/with_max_lines_and_overflow',
          widget: const SizedBox(
            width: 100,
            child: CommonText(
              'This is a very long text that should overflow',
              style: TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      });
    },
  );
}
