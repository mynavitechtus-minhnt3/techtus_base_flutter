import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:nalsflutter/index.dart';

import '../../../common/index.dart';

void main() {
  group(
    'others',
    () {
      testGoldens('when text is empty', (tester) async {
        await tester.testWidget(
          filename: 'primary_text_field/when text is empty',
          widget: PrimaryTextField(
            title: 'Email',
            hintText: 'Email',
            controller: TextEditingController(text: ''),
          ),
        );
      });

      testGoldens('when text is not empty', (tester) async {
        await tester.testWidget(
          filename: 'primary_text_field/when text is not empty',
          widget: PrimaryTextField(
            title: 'Email',
            hintText: 'Email',
            controller: TextEditingController(text: 'ntminh'),
          ),
        );
      });

      testGoldens('when it has suffixIcon', (tester) async {
        await tester.testWidget(
          filename: 'primary_text_field/when it has suffixIcon',
          widget: PrimaryTextField(
            title: 'Password',
            hintText: 'Password',
            controller: TextEditingController(text: ''),
            suffixIcon: CommonImage.svg(
              path: image.iconClose,
              foregroundColor: Colors.black,
            ),
          ),
        );
      });

      testGoldens(
        'when keyboardType is TextInputType.visiblePassword',
        (tester) async {
          await tester.testWidget(
            filename: 'primary_text_field/when keyboardType is TextInputType.visiblePassword',
            widget: PrimaryTextField(
              title: 'Password',
              hintText: 'Password',
              controller: TextEditingController(text: '123456'),
              keyboardType: TextInputType.visiblePassword,
            ),
          );
        },
      );

      testGoldens(
        'when tapping on the eye icon once',
        (tester) async {
          await tester.testWidget(
            filename: 'primary_text_field/when tapping on the eye icon once',
            widget: PrimaryTextField(
              title: 'Password',
              hintText: 'Password',
              controller: TextEditingController(text: '123456'),
              keyboardType: TextInputType.visiblePassword,
            ),
            onCreate: (tester, key) async {
              final eyeIconFinder = find.byType(GestureDetector).isDescendantOfKeyIfAny(key);

              expect(eyeIconFinder, findsOneWidget);

              await tester.tap(eyeIconFinder);
            },
          );
        },
      );
    },
  );
}
