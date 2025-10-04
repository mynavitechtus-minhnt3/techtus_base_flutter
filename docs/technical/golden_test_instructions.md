# Golden Test Instructions

## Overview

This document provides comprehensive guidelines for writing golden tests in the this project, ensuring consistent UI testing across all components and pages.

## Core Rules

### 1. File Structure Requirements
- Test files must end with `_test.dart`
- Test file paths must mirror the structure of the `lib` folder. Ex:
  - Code file: `apps/user_app/lib/ui/page/account_information/account_information_page.dart`
  - Test file: `apps/user_app/test/widget_test/ui/page/account_information/account_information_page_test.dart`
- Must reuse variables, functions, and classes from `apps/shared/test/common` - do not create new ones

### 2. Test Group Organization
Only 2 test groups are allowed:
- **"design"**: Test cases must match file names in the `design/` folder with mock data that matches the design images
- **"others"**: Must cover all edge cases and hidden cases not covered in the "design" group

### 3. Quality Standards
- Ensure Unit Tests and Golden Tests cover all edge cases and hidden cases
- Verify that all golden images have no overflow errors or other issues
- Ensure all golden images in the `goldens/` folder that match names with expected UI in the `design/` folder are identical with no UI bugs

### 4. Other Rules

- Don't write tests for loading cases
- Test case description and filename in group "design" must match the corresponding design image name
- If multiple test cases can be combined into a single case, they should be merged. Ex: Instead of writing separate test cases for each field with long text, create one test case where all fields contain long text.
- If the UI has a Network Image, pass `hasNetworkImage: true` and pass the `testImageUrl` variable to all dummy image urls
- If the dummy data has a local image path, pass "" or null

## testWidget Parameters Guide

The `testWidget` method provides various parameters to customize test behavior based on design requirements:

### Core Parameters

#### `filename` (required)
**Use Case**: Specifies the golden image file path
```dart
filename: 'splash_page/default state'
```

#### `widget` (required)
**Use Case**: The widget to test
```dart
widget: const SplashPage()
```

#### `overrides` (required)
**Use Case**: Provider overrides for mocking dependencies
```dart
overrides: [
  splashViewModelProvider.overrideWith(
    (ref) => MockSplashViewModel(const CommonState(data: SplashState())),
  ),
]
```

### Network & Image Parameters

#### `hasNetworkImage`
**Use Case**: When the UI contains network images
**Default**: `false`
```dart
// Use when testing components with CommonImage.network, user avatars, etc.
hasNetworkImage: true
```

### Time & Date Parameters

#### `mockToday`
**Use Case**: When data/state in UI or mock data using DateTime.now() or clock.now()
**Default**: `clock.now()`
```dart
// Use for date pickers, calendars, time-based content
mockToday: DateTime(2024, 1, 15, 10, 30)
```

### Device & Layout Parameters

#### `additionalDevices`
**Use Case**: Testing on specific device sizes beyond defaults
**Default**: `[]`
```dart
// Use for responsive design testing
additionalDevices: [TestDevice.tabletLandscape]
```

#### `includeFullHeightCase`
**Use Case**: Testing scrollable content and long forms
**Default**: `true`
```dart
// Set to false for fixed-height components like dialogs
includeFullHeightCase: false
```

#### `includeTextScalingCase`
**Use Case**: Testing accessibility with different text sizes
**Default**: `true`
```dart
// Set to false for components that don't support text scaling
includeTextScalingCase: false
```

#### `useMultiScreenGolden`
**Use Case**: Testing multiple device sizes in a single golden image
**Default**: `false`
```dart
// Use for comparison across device sizes
useMultiScreenGolden: true
```

### Interaction Parameters

#### `onCreate`
**Use Case**: Setup interactions before taking screenshots
```dart
onCreate: (tester) async {
  // Tap a button, scroll, enter text, etc.
  await tester.tap(find.byType(CommonButton));
  await tester.pumpAndSettle();
}
```

#### `customPump`
**Use Case**: Custom pump logic for animations or async operations. It usually is used for fixing strange UI issues on golden images.
```dart
customPump: (tester) async {
  await tester.pump(Duration(seconds: 1));
}
```

### Performance Parameters

#### `runAsynchronous`
**Use Case**: Control async execution for complex widgets
**Default**: `true`
```dart
// Set to false for simple widgets to improve test performance
runAsynchronous: false
```

## Template Structure

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
          // TODO: Add realistic mock data based on design
          
          await tester.testWidget(
            filename: '[page_name]/i1_S-6-4-8.料金表詳細画面（メインメニュー）',
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

## Parameter Usage Examples

### Example 1: Simple Page Test
```dart
await tester.testWidget(
  filename: 'splash/default state',
  widget: const SplashPage(),
  overrides: [
    splashViewModelProvider.overrideWith(
      (ref) => MockSplashViewModel(const CommonState(data: SplashState())),
    ),
  ],
);
```

### Example 2: Page with Network Images
```dart
await tester.testWidget(
  filename: 'profile/with avatar',
  widget: const ProfilePage(),
  hasNetworkImage: true, // Precache network images
  overrides: [
    profileViewModelProvider.overrideWith(
      (ref) => MockProfileViewModel(
        const CommonState(data: ProfileState(avatarUrl: 'https://example.com/avatar.jpg')),
      ),
    ),
  ],
);
```

### Example 3: Time-Sensitive Component
```dart
await tester.testWidget(
  filename: 'calendar/january 2024',
  widget: const CalendarWidget(),
  mockToday: DateTime(2024, 1, 15), // Fixed date for consistent testing
  overrides: [...],
);
```

### Example 4: Interactive Component
```dart
await tester.testWidget(
  filename: 'form/filled state',
  widget: const FormPage(),
  onCreate: (tester) async {
    // Fill form fields before screenshot
    await tester.enterText(find.byType(CommonTextField).first, 'Test Value');
    await tester.pumpAndSettle();
  },
  overrides: [...],
);
```

### Example 5: Dialog Test (Fixed Size)
```dart
await tester.testWidget(
  filename: 'dialog/confirmation',
  widget: const ConfirmationDialog(),
  includeFullHeightCase: false, // Dialogs don't need full height testing
  includeTextScalingCase: false, // Fixed size dialog
  overrides: [...],
);
```

## Validation Checklist

### ✅ Mock Data Quality
- [ ] Use Japanese text for display content
- [ ] Realistic pricing (e.g., 99999 instead of 1000)
- [ ] Realistic time values (e.g., 999 minutes)
- [ ] Complete item lists (dogBreeds, categories)
- [ ] Long descriptions/notes with line breaks
- [ ] Realistic IDs and numeric values

### ✅ Test Structure
- [ ] Correct import statements
- [ ] Mock ViewModel class follows pattern
- [ ] testGoldens structure is correct
- [ ] Filename convention is correct
- [ ] Provider overrides are correct

### ✅ Parameter Usage
- [ ] `hasNetworkImage` set when UI contains network images
- [ ] `mockToday` used for time-sensitive components
- [ ] `onCreate` used for interaction testing
- [ ] `includeFullHeightCase` set appropriately
- [ ] `includeTextScalingCase` set appropriately

### ✅ Execution
- [ ] Test runs successfully with `--update-goldens`
- [ ] Test passes with `--tags=golden`
- [ ] Test file has no lint errors
- [ ] Golden images are generated completely without errors

### ✅ File Organization
- [ ] Test file follows correct path convention
- [ ] Golden images are in `goldens/` folder
- [ ] Design images are in `design/` folder (if applicable)

## Commands Reference

```bash
# Basic commands
cd apps/[app_name]
flutter test [test_path] --update-goldens --tags=golden
flutter test [test_path] --tags=golden

# Find golden files
find test/widget_test -name "*.png" -type f

# Open images for comparison
open [golden_image_path]
open [design_image_path]

# Run specific test group
flutter test [test_path] --tags=golden --name="design"
flutter test [test_path] --tags=golden --name="others"
```
