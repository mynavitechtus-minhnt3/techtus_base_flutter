Create a complete golden test file for [PAGE_FILE_PATH]
with both "design" and "others" groups.

## Steps:

1. Check if "*_test.dart" file already exists. If not, create the golden test file from
scratch. Test file path must mirror the structure of the `lib` folder. Ex:
  - Code file: `lib/ui/page/account_information/
account_information_page.dart`
  - Test file: `test/widget_test/ui/page/account_information/
account_information_page_test.dart`

2. Verify design image exists in the expected design/ folder. If no design image exists,
STOP and notify user. design/ folder is placed alongside the test file. Ex:
  - Test file: `test/widget_test/ui/page/account_information/
account_information_page_test.dart`
  - Design image: `test/widget_test/ui/page/account_information/design/
*.png`

3. Analyze code of [PAGE_FILE_PATH] to understand dependencies, props, and state
structure.

4. Create "design" group with test cases matching design images in design/ folder. Each
test case follow these rules:
   - Test case description must match corresponding design image names.
   - filename must be [page_name]/[test_case_description].
   - Extract text, values, and data of the design images at design/ folder to use for
creating mock data.
   - If the UI has a Network Image, pass `hasNetworkImage: true` and pass the
`testImageUrl` variable to all dummy image urls
   - If the dummy data has a local image path, pass "" or null

5. Create "others" group with edge cases and abnormal cases:
   - Combine multiple similar cases into single test when possible. Ex:
      - Test case: "long text + max value" -> all fields with long text, not just one
field
      - Test case: "empty + min value" -> all fields with empty state and min value
      - Error cases if any. Don't mock `appException` in `CommonState`
   - Don't cover loading states cases. Only use `data` property in `CommonState`.

6. Generate golden images and verify all tests pass by running `flutter test [test_path]
--update-goldens --tags=golden`.

7. Compare generated golden image with design image in folder design/ to ensure they match
exactly. Their resolutions will be different so we will only compare the contents inside
them. If they don't match, update mock data in test cases of group "design". If they still
don't match, list up UI bugs.

## Remember: 

- No lint checks afterwards
- Strictly follow the Golden Test Example
- Always start with fresh context—avoid reusing cached code or test files from previous
sessions.

## Golden Test Example:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:[app]/index.dart';
import 'package:shared/index.dart';

import '../../../../common/index.dart';

class Mock[PageName]ViewModel extends StateNotifier<CommonState<[PageName]State>>
    with Mock
    implements [PageName]ViewModel {
  Mock[PageName]ViewModel(super.state);
}

void main() {
  group(
    'design',
    () {
      testGoldens(
        'i1_S-6-4-8.メインメニュー',
        (tester) async {
          // TODO: Add realistic mock data based on design, use testImageUrl if network images present, use "" or null if local images present
          
          await tester.testWidget(
            filename: '[page_name]/i1_S-6-4-8.メインメニュー',
            widget: const [PageName](),
            hasImageNetwork: true, // if network images present
            overrides: [
              [pageProvider].overrideWith(
                (ref) => Mock[PageName]ViewModel(
                  const CommonState(data: [PageName]State()),
                ),
              ),
            ],
          );
        },
      );
    },
  );
  
  group(
    'others',
    () {
      testGoldens(
        'empty state',
        (tester) async {
          await tester.testWidget(
            filename: '[page_name]/empty state',
            widget: const [PageName](),
            overrides: [
              [pageProvider].overrideWith(
                (ref) => Mock[PageName]ViewModel(
                  const CommonState(data: [PageName]State()),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

PAGE_FILE_PATH: [YOUR_PAGE_FILE_PATH]