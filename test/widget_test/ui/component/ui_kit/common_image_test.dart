import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('icon_data', (tester) async {
        await tester.testWidget(
          filename: 'common_image/icon_data',
          widget: UnconstrainedBox(
            child: CommonImage.iconData(
              iconData: Icons.add,
              size: 48,
            ),
          ),
          includeTextScalingCase: false,
        );
      });

      testGoldens('asset', (tester) async {
        await tester.testWidget(
          filename: 'common_image/asset',
          widget: UnconstrainedBox(
            child: CommonImage.asset(
              path: image.appIcon,
              width: 48,
              height: 48,
            ),
          ),
          includeTextScalingCase: false,
        );
      });

      testGoldens('svg', (tester) async {
        await tester.testWidget(
          filename: 'common_image/svg',
          widget: UnconstrainedBox(
            child: CommonImage.svg(
              path: image.iconBack,
              width: 48,
              height: 48,
            ),
          ),
          includeTextScalingCase: false,
        );
      });

      testGoldens('memory', (tester) async {
        final bytes = File('assets/images/image_app_icon.png').readAsBytesSync();
        await tester.testWidget(
          filename: 'common_image/memory',
          widget: UnconstrainedBox(
            child: CommonImage.memory(
              bytes: bytes,
              width: 48,
              height: 48,
            ),
          ),
          includeTextScalingCase: false,
        );
      });
    },
  );
}
