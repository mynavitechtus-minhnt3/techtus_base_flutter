import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../common/index.dart';

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
              path: image.imageAppIcon,
              width: 234,
              height: 506,
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

      testGoldens(
        'with solid border',
        (tester) async {
          await tester.testWidget(
            filename: 'common_image/with solid border',
            includeTextScalingCase: false,
            widget: UnconstrainedBox(
              child: CommonImage.asset(
                path: image.imageAppIcon,
                width: 234,
                height: 506,
                fit: BoxFit.cover,
                border: SolidBorder.allRadius(radius: 12, borderColor: Colors.red, borderWidth: 4),
              ),
            ),
          );
        },
      );

      testGoldens(
        'with dash border',
        (tester) async {
          await tester.testWidget(
            filename: 'common_image/with dash border',
            includeTextScalingCase: false,
            widget: UnconstrainedBox(
              child: CommonImage.asset(
                path: image.imageAppIcon,
                width: 234,
                height: 506,
                fit: BoxFit.cover,
                border: DashBorder.allRadius(
                  radius: 12,
                  borderColor: Colors.red,
                  borderWidth: 4,
                  dash: [6, 3],
                ),
              ),
            ),
          );
        },
      );

      testGoldens(
        'circle image',
        (tester) async {
          await tester.testWidget(
            filename: 'common_image/circle image',
            includeTextScalingCase: false,
            widget: UnconstrainedBox(
              child: CommonImage.asset(
                path: image.imageAppIcon,
                width: 234,
                height: 234,
                fit: BoxFit.cover,
                border: SolidBorder.allRadius(radius: 12, borderColor: Colors.red, borderWidth: 4),
                shape: CommonShape.circle,
              ),
            ),
          );
        },
      );
    },
  );
}
