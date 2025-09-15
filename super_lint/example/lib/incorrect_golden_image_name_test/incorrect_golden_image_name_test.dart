// ignore_for_file: avoid_hard_coded_strings, prefer_single_widget_per_file, avoid_dynamic, avoid_unnecessary_async_function, prefer_named_parameters
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

// Valid case: correct page name prefix and description
void validGoldenTest1() {
  testGoldens(
    'email + password empty',
    (tester) async {
      await tester.testWidget(
        filename: 'incorrect_golden_image_name/email + password empty',
        widget: const MockWidget(),
      );
    },
  );
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~

// Invalid case: wrong page name prefix
void invalidGoldenTest1() {
  testGoldens(
    'normal state',
    (tester) async {
      await tester.testWidget(
        // expect_lint: incorrect_golden_image_name
        filename: 'wrong_page/normal state',
        widget: const MockWidget(),
      );
    },
  );
}

// Invalid case: missing page name prefix
void invalidGoldenTest2() {
  testGoldens(
    'error state',
    (tester) async {
      await tester.testWidget(
        // expect_lint: incorrect_golden_image_name
        filename: 'error state',
        widget: const MockWidget(),
      );
    },
  );
}

// Invalid case: filename with wrong description
void invalidGoldenTest3() {
  testGoldens(
    'success state',
    (tester) async {
      await tester.testWidget(
        // expect_lint: incorrect_golden_image_name
        filename: 'incorrect_golden_image_name/different description',
        widget: const MockWidget(),
      );
    },
  );
}

// Invalid case: wrong page name pattern
void invalidGoldenTest4() {
  testGoldens(
    'default state',
    (tester) async {
      await tester.testWidget(
        // expect_lint: incorrect_golden_image_name
        filename: 'incorrect_golden_image_name_page/default state',
        widget: const MockWidget(),
      );
    },
  );
}

// Invalid case: empty filename
void invalidGoldenTest5() {
  testGoldens(
    'empty test',
    (tester) async {
      await tester.testWidget(
        // expect_lint: incorrect_golden_image_name
        filename: '',
        widget: const MockWidget(),
      );
    },
  );
}

// Mock classes and functions for testing
class MockWidget {
  const MockWidget();
}

void testGoldens(String description, dynamic Function(dynamic) test) {}

class WidgetTester {
  Future<void> testWidget({
    required String filename,
    required dynamic widget,
  }) async {}
}
