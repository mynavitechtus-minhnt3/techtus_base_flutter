import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';
import '../../../common/index.dart';

void main() {
  group(
    'CommonContainer',
    () {
      testGoldens('basic', (tester) async {
        await tester.testWidget(
          filename: 'common_container/basic',
          widget: const CommonContainer(
            width: 100,
            height: 100,
            color: Colors.blue,
          ),
        );
      });

      testGoldens('with border', (tester) async {
        await tester.testWidget(
          filename: 'common_container/with_border',
          widget: CommonContainer(
            width: 100,
            height: 100,
            color: Colors.white,
            border: SolidBorder.allRadius(
              radius: 8,
              borderColor: Colors.red,
              borderWidth: 2,
            ),
            padding: const EdgeInsets.all(8),
          ),
        );
      });

      testGoldens('circle shape with gradient', (tester) async {
        await tester.testWidget(
          filename: 'common_container/circle_shape_with_gradient',
          widget: CommonContainer(
            width: 100,
            height: 100,
            shape: CommonShape.circle,
            gradient: const LinearGradient(
              colors: [Colors.red, Colors.blue],
            ),
          ),
        );
      });
    },
  );
}
