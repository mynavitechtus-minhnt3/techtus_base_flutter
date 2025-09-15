# 🎯 PROMPT TEMPLATES — Copy & Paste Ready

## 1. Create a New Golden Test File

Use Case: Use when creating a new golden test file for a page/component/popup

```
Create a complete golden test file for [PAGE_FILE_PATH] with both "design" and "others" groups.

Steps:
1. Check if "*_test.dart" file already exists. If not, create the golden test file from scratch. Test file path must mirror the structure of the `lib` folder. Ex:
  - Code file: `apps/user_app/lib/ui/page/account_information/account_information_page.dart`
  - Test file: `apps/user_app/test/widget_test/ui/page/account_information/account_information_page_test.dart`
2. Verify design image exists in the expected design/ folder. If no design image exists, STOP and notify user. design/ folder is placed alongside the test file. Ex:
  - Test file: `apps/user_app/test/widget_test/ui/page/account_information/account_information_page_test.dart`
  - Design image: `apps/user_app/test/widget_test/ui/page/account_information/design/*.png`
3. Analyze code of [PAGE_FILE_PATH] to understand dependencies, props, and state structure.
4. Create "design" group with test cases matching design images in design/ folder. Each test case follow these rules:
   - Test case description must match corresponding design image names.
   - filename must be [page_name]/[test_case_description].
   - Extract text, values, and data of the design images at design/ folder to use for creating mock data.
   - If the UI has a Network Image, pass `hasNetworkImage: true` and pass the `testImageUrl` variable to all dummy image urls
   - If the dummy data has a local image path, pass "" or null
5. Create "others" group with edge cases and abnormal cases:
   - Combine multiple similar cases into single test when possible. Ex:
      - Test case: "long text + max value" -> all fields with long text, not just one field
      - Test case: "empty + min value" -> all fields with empty state and min value
      - Error cases if any. Don't mock `appException` in `CommonState`
   - Don't cover loading states cases. Only use `data` property in `CommonState`.
6. Generate golden images and verify all tests pass by running `flutter test [test_path] --update-goldens --tags=golden`.
7. Compare generated golden image with design image in folder design/ to ensure they match exactly. Their resolutions will be different so we will only compare the contents inside them. If they don't match, update mock data in test cases of group "design". If they still don't match, list up UI bugs.

**Remember**: 
- No lint checks afterwards
- Strictly follow the Golden Test Example
- Always start with fresh context—avoid reusing cached code or test files from previous sessions.

Golden Test Example:
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
        'i1_S-6-4-8.料金表詳細画面（メインメニュー）',
        (tester) async {
          // TODO: Add realistic mock data based on design, use testImageUrl if network images present, use "" or null if local images present
          
          await tester.testWidget(
            filename: '[page_name]/i1_S-6-4-8.料金表詳細画面（メインメニュー）',
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
```

PAGE_FILE_PATH: apps/salon_app/lib/ui/page/option_menu_confirmation/option_menu_confirmation_page.dart
```

## 2. Complete an Incomplete Golden Test File

Use Case: Use when the existing test file lacks proper "design" and "others" groups

```
TEST_FILE_PATH: [TEST_FILE_PATH]
DESIGN_IMAGE_PATH: [DESIGN_IMAGE_PATH] (if available)

Complete the golden test file at [TEST_FILE_PATH] to include both "design" and "others" groups.

Requirements:
1. **PREREQUISITE CHECK**: Verify design image exists in the expected design/ folder. If no design image exists, STOP and notify user.
2. **FILE CHECK**: Verify the test file exists at [TEST_FILE_PATH]. If not found, create it from scratch.
3. Analyze the existing test file and identify missing groups.
4. **CRITICAL**: If design image exists, examine it FIRST to extract exact text, values, and data.
5. Add "design" group if missing:
   - **Mock data MUST match the design image exactly** (exact Japanese text, exact numbers, exact lists).
   - Copy all visible content directly from the design image.
   - Test case names must match corresponding design image names.
6. Add "others" group if missing:
   - Add edge cases and abnormal cases not covered in design.
   - Combine multiple similar cases into single test when possible.
   - Cover: empty states, error states, validation states, overflow cases.
7. Update existing tests to follow proper structure and naming if needed.
8. **STRICT COMPLIANCE**: Follow ALL Core Rules and guidelines in docs/golden_test_instructions.md:
   - Only 2 test groups allowed: "design" and "others"
   - Don't write tests for loading state cases
   - Use hasNetworkImage=true and testImageUrl for network images
   - Use "" or null for local image paths
   - Follow exact testWidget parameter usage patterns
9. Generate golden images and verify all tests pass.
10. **VERIFY**: Compare generated golden image with design image to ensure they match exactly.
```

## 3. Update Existing Golden Test Content

Use Case: Use when the current golden test content does not match the design file

```
TEST_FILE_PATH: [TEST_FILE_PATH]
DESIGN_IMAGE_PATH: [DESIGN_IMAGE_PATH]

Update the golden test content to match the design image at [DESIGN_IMAGE_PATH].

Requirements:
1. **PREREQUISITE CHECK**: Verify design image exists at [DESIGN_IMAGE_PATH]. If no design image exists, STOP and notify user.
2. **FILE CHECK**: Verify the test file exists at [TEST_FILE_PATH]. If not found, create it from scratch.
3. **CRITICAL**: Analyze the design image pixel-by-pixel to understand exact layout and content.
4. Extract and copy ALL visible text, numbers, and data exactly from the design image:
   - Use exact Japanese text shown in the design
   - Use exact pricing/numeric values (e.g., if design shows "99,999円", use exactly 99999)
   - Use exact time values (e.g., if design shows "999分", use exactly 999)
   - Use exact names, categories, and descriptions as shown
5. Update mock data to reflect the design exactly - NO creative interpretation allowed.
6. **STRICT COMPLIANCE**: Follow ALL Core Rules and guidelines in docs/golden_test_instructions.md:
   - Only 2 test groups allowed: "design" and "others"
   - Don't write tests for loading state cases
   - Use hasNetworkImage=true and testImageUrl for network images
   - Use "" or null for local image paths
   - Follow exact testWidget parameter usage patterns
7. Verify by running flutter test [TEST_FILE_PATH] --update-goldens --tags=golden, then compare the golden image to the design.
8. **MANDATORY VERIFICATION**: Generated golden image must be pixel-perfect match with design image.
```

### Example 1: Create New Test File
```
PAGE_NAME: CuttingResultDetailPage
DESIGN_IMAGE_PATH: apps/salon_app/test/widget_test/ui/page/cutting_result_detail/design/S-3-2-2.カット結果詳細画面.png

Create a complete golden test file for CuttingResultDetailPage with both "design" and "others" groups.

Requirements:
1. **PREREQUISITE CHECK**: Verify design image exists in the expected design/ folder. If no design image exists, STOP and notify user.
2. **FILE CHECK**: Check if "*_test.dart" file already exists. If not, create the golden test file from scratch.
3. Analyze CuttingResultDetailPage (dependencies, props, state structure).
4. **CRITICAL**: Examine the design image FIRST to extract exact text, values, and data.
5. Create "design" group with test cases matching design images:
   - **Mock data MUST match design image exactly** (exact Japanese text, exact pricing, exact time values).
   - Test case name: 'S-3-2-2.カット結果詳細画面' (matching design image name).
6. Create "others" group with edge cases:
   - Combine similar cases: 'all fields with long text and overflow scenarios'.
   - Cover: empty pet data, missing images, network errors, validation errors.
7. **STRICT COMPLIANCE**: Follow ALL Core Rules and guidelines in docs/golden_test_instructions.md:
   - Only 2 test groups allowed: "design" and "others"
   - Don't write tests for loading state cases
   - Use hasNetworkImage=true and testImageUrl for network images
   - Use "" or null for local image paths
   - Follow exact testWidget parameter usage patterns
8. Generate goldens and verify tests pass.
9. **VERIFY**: Compare generated golden image with design image to ensure pixel-perfect match.
```

### Example 2: Complete Incomplete Test File
```
TEST_FILE_PATH: apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/option_menu_confirmation_page_test.dart
DESIGN_IMAGE_PATH: apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/design/S-6-4-10.料金表詳細画面（オプションメニュー）.png

Complete the golden test file at apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/option_menu_confirmation_page_test.dart to include both "design" and "others" groups.

Requirements:
1. **PREREQUISITE CHECK**: Verify design image exists in the expected design/ folder. If no design image exists, STOP and notify user.
2. **FILE CHECK**: Verify the test file exists at the specified path. If not found, create it from scratch.
3. Analyze existing test file - currently missing "others" group.
4. **CRITICAL**: Examine the design image FIRST to extract exact content.
5. Keep existing "design" group, update mock data if needed:
   - **Mock data MUST match design image exactly** (exact Japanese text, exact numbers).
   - Test case: 'S-6-4-10.料金表詳細画面（オプションメニュー）' matching design.
6. Add "others" group with edge cases:
   - 'combined edge cases': empty options, very long descriptions, price overflow, unavailable services.
   - 'error states': network error, invalid data, missing required fields.
7. **STRICT COMPLIANCE**: Follow ALL Core Rules and guidelines in docs/golden_test_instructions.md:
   - Only 2 test groups allowed: "design" and "others"
   - Don't write tests for loading state cases
   - Use hasNetworkImage=true and testImageUrl for network images
   - Use "" or null for local image paths
   - Follow exact testWidget parameter usage patterns
8. Generate goldens and verify tests pass.
9. **VERIFY**: Compare generated golden image with design image to ensure pixel-perfect match.
```

### Example 3: Update Existing Test Content
```
TEST_FILE_PATH: apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/option_menu_confirmation_page_test.dart
DESIGN_IMAGE_PATH: apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/design/S-6-4-10.料金表詳細画面（オプションメニュー）.png

Update the golden test content to match the design image at apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/design/S-6-4-10.料金表詳細画面（オプションメニュー）.png

Requirements:
1. **PREREQUISITE CHECK**: Verify design image exists at the specified path. If no design image exists, STOP and notify user.
2. **FILE CHECK**: Verify the test file exists at the specified path. If not found, create it from scratch.
3. **CRITICAL**: Analyze the design image pixel-by-pixel to understand exact layout and content.
4. Extract and copy ALL visible text, numbers, and data exactly from design image:
   - Copy exact Japanese text displayed (no interpretation)
   - Copy exact pricing values (e.g., if shows "99,999円", use exactly 99999)
   - Copy exact time values (e.g., if shows "999分", use exactly 999)
   - Copy exact names, categories, breed lists, descriptions as shown
5. Update mock data to match design exactly - NO creative interpretation.
6. Compliance: Follow docs/golden_test_instructions.md (Core Rules).
7. Verify by running flutter test apps/salon_app/test/widget_test/ui/page/option_menu_confirmation/option_menu_confirmation_page_test.dart --update-goldens --tags=golden, then compare the golden image to the design.
8. **MANDATORY**: Generated golden image must be pixel-perfect match with design image.
9. **STRICT COMPLIANCE**: Ensure ALL Core Rules from docs/golden_test_instructions.md are followed throughout.
```

## Complete Golden Test Template Structure

**IMPORTANT**: This template MUST follow ALL Core Rules from docs/golden_test_instructions.md

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:[app]/index.dart';
import 'package:shared/index.dart';

import '../../../../common/index.dart'; // MUST reuse shared test utilities

class Mock[PageName]ViewModel extends StateNotifier<CommonState<[PageName]State>>
    with Mock
    implements [PageName]ViewModel {
  Mock[PageName]ViewModel(super.state);
}

void main() {
  // CORE RULE: Only 2 test groups allowed - "design" and "others"
  group(
    'design',
    () {
      testGoldens(
        '[exact design image name]', // MUST match design image filename exactly
        (tester) async {
          // **CRITICAL**: Examine design image FIRST and copy ALL content exactly
          // Extract exact Japanese text, exact numbers, exact lists from design
          // NO creative interpretation - copy pixel-by-pixel what is shown
          
          await tester.testWidget(
            filename: '[page_name]/[exact design image name]',
            widget: const [PageName](),
            hasNetworkImage: true, // REQUIRED if UI contains network images
            mockToday: DateTime(2024, 1, 15), // if time-sensitive content
            overrides: [
              [pageProvider].overrideWith(
                (ref) => Mock[PageName]ViewModel(
                  const CommonState(data: [PageName]State(
                    // Mock data MUST match design image exactly
                    // Use testImageUrl for all network image URLs
                  )),
                ),
              ),
            ],
          );
        },
      );
      
      // Add more design test cases if multiple design images exist
    },
  );
  
  group(
    'others',
    () {
      testGoldens(
        'combined edge cases', // CORE RULE: Merge similar cases into one
        (tester) async {
          // Test multiple edge cases in single test:
          // - All fields with very long text
          // - Large numbers causing potential overflow
          // - Maximum list items
          // - Special characters in text
          
          await tester.testWidget(
            filename: '[page_name]/combined edge cases',
            widget: const [PageName](),
            hasNetworkImage: true, // Use testImageUrl if network images present
            overrides: [
              [pageProvider].overrideWith(
                (ref) => Mock[PageName]ViewModel(
                  const CommonState(data: [PageName]State(
                    // Edge case mock data - use testImageUrl for images
                  )),
                ),
              ),
            ],
          );
        },
      );
      
      testGoldens(
        'error and empty states',
        (tester) async {
          // Test error states, empty data, validation errors
          // NO loading states (Core Rule violation)
          
          await tester.testWidget(
            filename: '[page_name]/error and empty states',
            widget: const [PageName](),
            hasNetworkImage: true, // if network images exist
            overrides: [
              [pageProvider].overrideWith(
                (ref) => Mock[PageName]ViewModel(
                  const CommonState(
                    data: [PageName]State(), // Empty/default state
                    appException: AppException.network(), // Error state
                  ),
                ),
              ),
            ],
          );
        },
      );
      
      // CORE RULE: Don't create separate tests for loading states
      // CORE RULE: Combine similar test cases when possible
    },
  );
}
```

## Quick Commands Reference

```bash
# Update a single golden test
cd apps/[APP_NAME] && flutter test [TEST_PATH] --update-goldens --tags=golden

# Verify a golden test
cd apps/[APP_NAME] && flutter test [TEST_PATH] --tags=golden

# Run all golden tests
cd apps/[APP_NAME] && flutter test --tags=golden

# Find golden images
find apps/[APP_NAME]/test/widget_test -name "*.png" -type f

# Open images for comparison
open [GOLDEN_IMAGE_PATH]
open [DESIGN_IMAGE_PATH]

# Run specific test group
flutter test [TEST_PATH] --tags=golden --name="design"
flutter test [TEST_PATH] --tags=golden --name="others"

# Compare images side by side (macOS)
open -a Preview [GOLDEN_IMAGE_PATH] [DESIGN_IMAGE_PATH]
```

## 🔥 CRITICAL DESIGN MATCHING RULES

### MANDATORY: Follow ALL Core Rules from docs/golden_test_instructions.md

### For "design" Group Tests:
1. **EXAMINE DESIGN IMAGE FIRST**: Look at every pixel, text, number, and element
2. **EXTRACT EXACT CONTENT**: Copy exact Japanese text, exact numbers, exact lists
3. **NO INTERPRETATION**: Don't guess or be creative - copy exactly what you see
4. **VERIFY PIXEL-PERFECT MATCH**: Generated golden must match design exactly
5. **USE testImageUrl**: All network image URLs must use testImageUrl variable
6. **REUSE SHARED UTILITIES**: Import and use from apps/shared/test/common

### Common Design Matching Mistakes to Avoid:
- ❌ Using creative/realistic data instead of exact design content
- ❌ Approximating numbers (using 4400 when design shows 99999)
- ❌ Translating or changing Japanese text
- ❌ Adding extra content not shown in design
- ❌ Using generic breed lists instead of exact ones from design
- ❌ Changing time values (using 60 when design shows 999)
- ❌ Not copying exact category names, menu names, descriptions

### Mandatory Verification Steps:
1. **ENSURE CORE RULES COMPLIANCE**: Verify ALL rules from docs/golden_test_instructions.md are followed
2. Run test with `--update-goldens --tags=golden --name="design"`
3. Open both generated golden image and design image side by side
4. Compare pixel-by-pixel for exact match
5. If ANY difference exists, update mock data and repeat
6. **FINAL CHECK**: Confirm hasNetworkImage=true and testImageUrl usage if network images present

## Key Rules for "others" Group

### CORE RULES COMPLIANCE: Follow docs/golden_test_instructions.md

### Edge Cases to Include:
- **Combined text overflow**: All text fields with very long content in single test
- **Data boundaries**: Maximum/minimum values, empty lists, null data
- **Special characters**: Unicode, emojis, special symbols in text
- **Large datasets**: Maximum number of items in lists
- **Validation states**: Form errors, invalid inputs
- **Network states**: Connection errors, timeout scenarios
- **Permission states**: Denied access, missing permissions

### Cases to Merge:
- Instead of separate tests for each field with long text → One test with all fields having long text
- Instead of separate overflow tests → One test covering all potential overflow scenarios
- Instead of separate error tests → One test covering multiple error states
- Instead of separate empty tests → One test covering all empty/null scenarios

### Cases to Avoid:
- ❌ Loading states (CORE RULE: explicitly forbidden)
- ❌ Duplicate similar scenarios 
- ❌ Tests that can be combined into existing ones
- ❌ Not using testImageUrl for network images
- ❌ Creating new test utilities instead of reusing shared ones
- ❌ Having more than 2 test groups ("design" and "others" only)
