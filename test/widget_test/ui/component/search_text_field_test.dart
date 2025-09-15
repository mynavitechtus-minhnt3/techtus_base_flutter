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
          filename: 'search_text_field/when text is empty',
          widget: const SearchTextField(),
        );
      });

      testGoldens('when text is not empty', (tester) async {
        await tester.testWidget(
          filename: 'search_text_field/when text is not empty',
          widget: const SearchTextField(),
          onCreate: (tester, key) async {
            final textFieldFinder = find.byType(TextField).isDescendantOfKeyIfAny(key);
            expect(textFieldFinder, findsOneWidget);

            await tester.enterText(textFieldFinder, 'ntminh');
          },
        );
      });
    },
  );
}
