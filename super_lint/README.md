# All Lint Rules

## Table of Contents

- [Common Parameters](#common-parameters)
- [All lint rules](#all-lint-rules)
  - [1. avoid_unnecessary_async_function](#1-avoid_unnecessary_async_function)
  - [2. prefer_named_parameters](#2-prefer_named_parameters)
  - [3. prefer_is_empty_string](#3-prefer_is_empty_string)
  - [4. prefer_is_not_empty_string](#4-prefer_is_not_empty_string)
  - [5. incorrect_todo_comment](#5-incorrect_todo_comment)
  - [6. prefer_async_await](#6-prefer_async_await)
  - [7. prefer_lower_case_test_description](#7-prefer_lower_case_test_description)
  - [8. test_folder_must_mirror_lib_folder](#8-test_folder_must_mirror_lib_folder)
  - [9. avoid_hard_coded_colors](#9-avoid_hard_coded_colors)
  - [10. prefer_common_widgets](#10-prefer_common_widgets)
  - [11. avoid_hard_coded_strings](#11-avoid_hard_coded_strings)
  - [12. incorrect_parent_class](#12-incorrect_parent_class)
  - [13. missing_expanded_or_flexible](#13-missing_expanded_or_flexible)
  - [14. prefer_importing_index_file](#14-prefer_importing_index_file)
  - [15. avoid_using_text_style_constructor_directly](#15-avoid_using_text_style_constructor_directly)
  - [16. incorrect_screen_name_parameter_value](#16-incorrect_screen_name_parameter_value)
  - [17. incorrect_event_parameter_name](#17-incorrect_event_parameter_name)
  - [18. incorrect_event_parameter_type](#18-incorrect_event_parameter_type)
  - [19. incorrect_event_name](#19-incorrect_event_name)
  - [20. incorrect_screen_name_enum_value](#20-incorrect_screen_name_enum_value)
  - [21. avoid_dynamic](#21-avoid_dynamic)
  - [22. avoid_nested_conditions](#22-avoid_nested_conditions)
  - [23. avoid_using_if_else_with_enums](#23-avoid_using_if_else_with_enums)
  - [24. avoid_using_unsafe_cast](#24-avoid_using_unsafe_cast)
  - [25. missing_log_in_catch_block](#25-missing_log_in_catch_block)
  - [26. missing_run_catching](#26-missing_run_catching)
  - [27. util_functions_must_be_static](#27-util_functions_must_be_static)
  - [28. missing_extension_method_for_events](#28-missing_extension_method_for_events)
  - [29. missing_common_scrollbar](#29-missing_common_scrollbar)
  - [30. incorrect_freezed_default_value_type](#30-incorrect_freezed_default_value_type)
  - [31. prefer_single_widget_per_file](#31-prefer_single_widget_per_file)
  - [32. require_matching_file_and_class_name](#32-require_matching_file_and_class_name)
  - [33. missing_golden_test](#33-missing_golden_test)
  - [34. avoid_using_datetime_now](#34-avoid_using_datetime_now)
  - [35. empty_test_group](#35-empty_test_group)
  - [36. incorrect_golden_image_name](#36-incorrect_golden_image_name)
  - [37. invalid_test_group_name](#37-invalid_test_group_name)
  - [38. missing_test_group](#38-missing_test_group)
  - [39. avoid_using_enum_name_as_key](#39-avoid_using_enum_name_as_key)

## Common Parameters

Tất cả các lint rules đều hỗ trợ 3 parameters mặc định sau:

### excludes
- **Type**: `List<String>`
- **Default**: `[]`
- **Description**: Danh sách các file patterns sẽ bị loại trừ khỏi rule này
- **Example**: `["**/*_generated.dart", "**/test/**"]`

### includes
- **Type**: `List<String>`
- **Default**: `[]`
- **Description**: Danh sách các file patterns sẽ được áp dụng rule này (nếu empty thì áp dụng cho tất cả)
- **Example**: `["lib/**/*.dart"]`

### severity
- **Type**: `String`
- **Default**: `error`
- **Description**: Mức độ nghiêm trọng của rule
- **Values**: `error`, `warning`, `info`

## All lint rules

### 1. avoid_unnecessary_async_function

Tránh tạo async function không cần thiết khi không có asynchronous computation.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Tự động remove `async` keyword và `Future` return type

```yaml
- avoid_unnecessary_async_function:
```

**Good**:

```dart
Future<void> login() async {
  await Future<dynamic>.delayed(const Duration(milliseconds: 2000));
  print('login');
}

FutureOr<String> getName() async {
  return Future(() => 'name');
}

FutureOr<int?> getAge() async {
  try {
    print('do something');
    return Future.value(3);
  } catch (e) {
    return null;
  }
}
```

**Bad**:

```dart
Future<void> logout() async {
  print('logout');
}

FutureOr<String> getFullName() async {
  return 'name';
}

FutureOr<int?> getUserAge() async {
  try {
    print('do something');
    return 3;
  } catch (e) {
    return null;
  }
}
```

### 2. prefer_named_parameters

Nếu function hoặc constructor có nhiều parameters hơn threshold, sử dụng named parameters.

**Parameters**:
- `threshold` (int, default: 2): Số lượng parameters tối thiểu để yêu cầu named parameters

**QuickFix**: Tự động convert positional parameters thành named parameters

```yaml
- prefer_named_parameters:
    threshold: 2
```

**Good**:

```dart
class A {
  final String a;
  final String b;

  A({
    required this.a,
    required this.b,
  });

  void test2({
    required String a,
    String b = '',
  }) {}
}
```

**Bad**:

```dart
class B {
  final String a;
  final String b;

  B(this.a, this.b); 
  B.a(this.a, [this.b = '']); 
}

void test4(String a, String b) {} 
```

### 3. prefer_is_empty_string

Sử dụng `isEmpty` thay vì `==` để kiểm tra string rỗng.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Tự động thay thế `== ''` bằng `.isEmpty`

```yaml
- prefer_is_empty_string:
```

**Good**:

```dart
void test(String a) {
  if (a.isEmpty) {}
}
```

**Bad**:

```dart
void test(String a) {
  if (a == '') {}
  if ('' == a) {}
}
```

### 4. prefer_is_not_empty_string

Sử dụng `isNotEmpty` thay vì `!=` để kiểm tra string không rỗng.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Tự động thay thế `!= ''` bằng `.isNotEmpty`

```yaml
- prefer_is_not_empty_string:
```

**Good**:

```dart
void test(String a) {
  if (a.isNotEmpty) {}
}
```

**Bad**:

```dart
void test(String a) {
  if (a != '') {}
  if ('' != a) {}
}
```

### 5. incorrect_todo_comment

TODO comments phải có username, description và issue number (hoặc #0 nếu không có issue).

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_todo_comment:
```

**Good**:

```dart
// TODO(minhnt3): Remove this file when the issue is fixed #123 issue number.
// TODO(minhnt3): Remove this file when the issue is fixed #0
```

**Bad**:

```dart
// TODO(minhnt3): Remove this file when the issue is fixed.
// TODO: Remove this file when the issue is fixed #123.
// TODO(minhnt3): Remove this file when the issue is fixed #-123 .
```

### 6. prefer_async_await

Ưu tiên sử dụng async/await syntax thay vì .then invocations.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- prefer_async_await:
```

**Good**:

```dart
Future<void> test() async {
  final future = Future(() {
    print('future');
  });

  await future;
}
```

**Bad**:

```dart
Future<void> test() async {
  final future = Future(() {
    print('future');
  });

  future.then((value) => print('then'));
  future.then((value) => null).then((value) => null);
}
```

### 7. prefer_lower_case_test_description

Viết thường ký tự đầu tiên khi viết test descriptions.

**Parameters**:
- `test_methods` (List<Map<String, String>>, default: test methods list): Danh sách các test methods và parameter names

**QuickFix**: Tự động lowercase ký tự đầu tiên

```yaml
- prefer_lower_case_test_description:
    test_methods:
      - method_name: "test"
        param_name: "description"
      - method_name: "blocTest"
        param_name: "desc"
```

**Good**:

```dart
test('lowercase text', () {});
test('1lowercase text', () {});
blocTest('lowercase text', () {});
testGoldens('lowercase text', () {});
```

**Bad**:

```dart
test('Uppercase text', () {});
blocTest('Uppercase text', () {});
```

### 8. test_folder_must_mirror_lib_folder

Test files phải có tên kết thúc bằng '_test' và đường dẫn phải mirror cấu trúc thư mục 'lib'.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- test_folder_must_mirror_lib_folder:
```

**Good**:

```
lib/external_interface/repositories/job_repository.dart
test/unit_test/external_interface/repositories/job_repository_test.dart
```

**Bad**:

```
lib/external_interface/repositories/job_repository.dart
test/unit_test/job_repository.dart
```

### 9. avoid_hard_coded_colors

Tránh hard-code colors, ngoại trừ Colors.transparent. Sử dụng color constants thay thế.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_hard_coded_colors:
```

**Good**:

```dart
Container(
  color: AppColors.primary,
)
Container(
  color: Colors.transparent, // Exception allowed
)
```

**Bad**:

```dart
Container(
  color: Color(0xFF000000),
)
Container(
  color: Colors.white,
)
```

### 10. prefer_common_widgets

Sử dụng common widgets thay vì basic Flutter widgets.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- prefer_common_widgets:
```

**Good**:

```dart
CommonButton(
  onPressed: () {},
  child: Text('Click me'),
)
CommonText('Hello World')
CommonScaffold(...)
```

**Bad**:

```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Click me'),
)
Text('Hello World')
Scaffold(...)
```

### 11. avoid_hard_coded_strings

Sử dụng string constants thay vì hard-coded strings.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_hard_coded_strings:
```

**Good**:

```dart
Text(AppStrings.welcomeMessage)
Text(l10n.welcomeMessage)
```

**Bad**:

```dart
Text('Welcome to the app!')
Text('Hard coded string')
```

### 12. incorrect_parent_class

Widgets phải extend đúng parent class.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_parent_class:
```

**Good**:

```dart
class MyScreen extends StatelessWidget {
  // ...
}
```

**Bad**:

```dart
class MyScreen extends StatefulWidget {
  // Should be StatelessWidget if no state management
}
```

### 13. missing_expanded_or_flexible

Sử dụng Expanded hoặc Flexible cho widgets trong Row/Column khi cần thiết.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- missing_expanded_or_flexible:
```

**Good**:

```dart
Row(
  children: [
    Expanded(
      child: Text('Long text'),
    ),
    Icon(Icons.star),
  ],
)
```

**Bad**:

```dart
Row(
  children: [
    Text('Very long text that might overflow'),
    Icon(Icons.star),
  ],
)
```

### 14. prefer_importing_index_file

Import từ index files thay vì individual files.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- prefer_importing_index_file:
```

**Good**:

```dart
import 'package:my_app/features/auth/index.dart';
```

**Bad**:

```dart
import 'package:my_app/features/auth/login_screen.dart';
import 'package:my_app/features/auth/register_screen.dart';
```

### 15. avoid_using_text_style_constructor_directly

Sử dụng predefined text styles thay vì direct TextStyle constructor.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_using_text_style_constructor_directly:
```

**Good**:

```dart
Text(
  'Hello',
  style: AppTextStyles.heading,
)
```

**Bad**:

```dart
Text(
  'Hello',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)
```

### 16. incorrect_screen_name_parameter_value

Screen name parameter values phải match enum values.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_screen_name_parameter_value:
```

**Good**:

```dart
navigateTo(ScreenName.home);
```

**Bad**:

```dart
navigateTo('Home');
```

### 17. incorrect_event_parameter_name

Event parameter names phải follow naming conventions.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_event_parameter_name:
```

**Good**:

```dart
class LoginEvent {
  final String username;
  final String password;
}
```

**Bad**:

```dart
class LoginEvent {
  final String user_name;
  final String pwd;
}
```

### 18. incorrect_event_parameter_type

Event parameters phải có correct types. Parameters chỉ cho phép String, int hoặc double values.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_event_parameter_type:
```

**Good**:

```dart
class LoginEvent {
  final String username;
  final String password;
  final int attempts;
  final double timestamp;
}
```

**Bad**:

```dart
class LoginEvent {
  final dynamic username;
  final Object password;
}
```

### 19. incorrect_event_name

Event names phải follow naming conventions.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_event_name:
```

**Good**:

```dart
class UserLoggedInEvent {}
class ButtonClickedEvent {}
```

**Bad**:

```dart
class userLoggedIn {}
class button_clicked_event {}
```

### 20. incorrect_screen_name_enum_value

Screen name enum values phải follow naming conventions.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_screen_name_enum_value:
```

**Good**:

```dart
enum ScreenName {
  home,
  profile,
  settings,
}
```

**Bad**:

```dart
enum ScreenName {
  Home,
  Profile,
  Settings,
}
```

### 21. avoid_dynamic

Tránh sử dụng dynamic type.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_dynamic:
```

**Good**:

```dart
String getValue() {
  return 'value';
}

Object? getUnknownValue() {
  return someValue;
}
```

**Bad**:

```dart
dynamic getValue() {
  return 'value';
}

dynamic someVariable;
```

### 22. avoid_nested_conditions

Tránh deeply nested conditions.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_nested_conditions:
```

**Good**:

```dart
if (!isValid) return;
if (!isEnabled) return;
if (!hasPermission) return;
// proceed with logic
```

**Bad**:

```dart
if (isValid) {
  if (isEnabled) {
    if (hasPermission) {
      // proceed with logic
    }
  }
}
```

### 23. avoid_using_if_else_with_enums

Sử dụng switch statements với enums thay vì if-else.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_using_if_else_with_enums:
```

**Good**:

```dart
switch (status) {
  case Status.active:
    return 'Active';
  case Status.inactive:
    return 'Inactive';
  case Status.pending:
    return 'Pending';
}
```

**Bad**:

```dart
if (status == Status.active) {
  return 'Active';
} else if (status == Status.inactive) {
  return 'Inactive';
} else {
  return 'Pending';
}
```

### 24. avoid_using_unsafe_cast

Tránh unsafe type casting.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- avoid_using_unsafe_cast:
```

**Good**:

```dart
if (value is String) {
  final stringValue = value;
  // use stringValue
}
```

**Bad**:

```dart
final stringValue = value as String;
```

### 25. missing_log_in_catch_block

Catch blocks phải include logging.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- missing_log_in_catch_block:
```

**Good**:

```dart
try {
  // ...
} catch (e) {
  log('Error occurred: $e');
  rethrow;
}
```

**Bad**:

```dart
try {
  // ...
} catch (e) {
  rethrow;
}
```

### 26. missing_run_catching

Sử dụng runCatching cho error handling.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- missing_run_catching:
```

**Good**:

```dart
final result = runCatching(() {
  return someFunction();
});
```

**Bad**:

```dart
try {
  final result = someFunction();
} catch (e) {
  // handle error
}
```

### 27. util_functions_must_be_static

Utility functions phải là static.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- util_functions_must_be_static:
```

**Good**:

```dart
class StringUtils {
  static String capitalize(String text) {
    return text.toUpperCase();
  }
}
```

**Bad**:

```dart
class StringUtils {
  String capitalize(String text) {
    return text.toUpperCase();
  }
}
```

### 28. missing_extension_method_for_events

Events phải có corresponding extension methods.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- missing_extension_method_for_events:
```

**Good**:

```dart
class LoginEvent {}

extension LoginEventExtension on LoginEvent {
  void handle() {
    // ...
  }
}
```

**Bad**:

```dart
class LoginEvent {}
```

### 29. missing_common_scrollbar

Sử dụng common scrollbar widget cho scrollable content.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- missing_common_scrollbar:
```

**Good**:

```dart
CommonScrollbarWithIosStatusBarTapDetector(
  child: ListView(
    children: [...],
  ),
)
```

**Bad**:

```dart
ListView(
  children: [...],
)
SingleChildScrollView(
  child: Column(...),
)
```

### 30. incorrect_freezed_default_value_type

Giá trị passed to `@Default()` trong freezed class phải có compatible type với annotated field.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- incorrect_freezed_default_value_type:
```

**Good**:

```dart
@Default(<ApiUserData>[]) List<ApiUserData> allContacts,
@Default('') String name,
@Default(0) int count,
```

**Bad**:

```dart
@Default(0) List<ApiUserData> allContacts,
@Default([]) String name,
```

### 31. prefer_single_widget_per_file

Mỗi file chỉ nên chứa một widget class.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- prefer_single_widget_per_file:
```

**Good**:

```dart
// home_screen.dart
class HomeScreen extends StatelessWidget {
  // ...
}
```

**Bad**:

```dart
// screens.dart
class HomeScreen extends StatelessWidget {
  // ...
}

class ProfileScreen extends StatelessWidget {
  // ...
}
```

### 32. require_matching_file_and_class_name

Tên file phải match với tên class.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- require_matching_file_and_class_name:
```

**Good**:

```dart
// home_screen.dart
class HomeScreen extends StatelessWidget {}

// user_profile.dart
class UserProfile extends StatelessWidget {}
```

**Bad**:

```dart
// home.dart
class HomeScreen extends StatelessWidget {}

// profile.dart
class UserProfileWidget extends StatelessWidget {}
```

### 33. missing_golden_test

Widget file phải có corresponding golden test file.

**Parameters**:
- `widget_folders` (List<String>, default: []): Danh sách các folders chứa widgets cần golden test
- `test_folder` (String, default: "test/widget_test"): Thư mục chứa widget tests

**QuickFix**: Không có

```yaml
- missing_golden_test:
    widget_folders:
      - "lib/ui/page"
      - "lib/ui/component"
    test_folder: "test/widget_test"
```

**Good**:

```
lib/ui/page/login/login_page.dart
test/widget_test/ui/page/login/login_page_test.dart
test/widget_test/ui/page/login/goldens/
test/widget_test/ui/page/login/design/ (for page tests only)
```

**Bad**:

```
lib/ui/page/login/login_page.dart
(missing test file)
```

### 34. avoid_using_datetime_now

Tránh sử dụng `DateTime.now()` và `DateTimeUtil.now` trong test widget files. Đối với file thường, sử dụng `DateTimeUtil.now` thay vì `DateTime.now()`.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Tự động thay thế `DateTime.now()` bằng `DateTimeUtil.now` cho file thường, và thay thế fixed DateTime cho test widget files

```yaml
- avoid_using_datetime_now:
```

**Good**:

```dart
// Trong file thường
final current = DateTimeUtil.now;

// Trong test widget files (test/widget_test/ui/*_test.dart)
final mockTime = DateTime(2024, 1, 1); // Sử dụng fixed time cho testing
```

**Bad**:

```dart
// Trong file thường
final current = DateTime.now();

// Trong test widget files
final current = DateTime.now();
final current2 = DateTimeUtil.now; // Cả hai đều không được phép
```

### 35. empty_test_group

Test groups không được để trống.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- empty_test_group:
```

**Good**:

```dart
group('login tests', () {
  test('should login successfully', () {
    // test implementation
  });
});
```

**Bad**:

```dart
group('login tests', () {
  // empty group
});
```

### 36. incorrect_golden_image_name

Golden image filename phải start với page name và equal test description.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Tự động set filename theo format đúng

```yaml
- incorrect_golden_image_name:
```

**Good**:

```dart
// In login_page_test.dart
testGoldens('valid credentials', (tester) async {
  await tester.testWidget(
    filename: 'login_page/valid credentials',
    widget: LoginPage(),
  );
});
```

**Bad**:

```dart
// In login_page_test.dart
testGoldens('valid credentials', (tester) async {
  await tester.testWidget(
    filename: 'wrong_name/test',
    widget: LoginPage(),
  );
});
```

### 37. invalid_test_group_name

Test group names phải hợp lệ và follow conventions.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

```yaml
- invalid_test_group_name:
```

**Good**:

```dart
group('design', () {
  // design tests
});

group('others', () {
  // other tests
});
```

**Bad**:

```dart
group('Design', () {
  // should be lowercase
});

group('random_name', () {
  // should follow conventions
});
```

### 38. missing_test_group

Test files phải declare tất cả required groups.

**Parameters**:
- `required_groups` (List<String>, default: ["design", "others"]): Danh sách các groups bắt buộc

**QuickFix**: Tự động thêm missing test groups

```yaml
- missing_test_group:
    required_groups:
      - "design"
      - "others"
```

**Good**:

```dart
void main() {
  group('design', () {
    // design tests
  });
  
  group('others', () {
    // other tests
  });
}
```

**Bad**:

```dart
void main() {
  group('design', () {
    // design tests
  });
  // missing 'others' group
}
```

### 39. avoid_using_enum_name_as_key

Tránh sử dụng tên enum làm key trong SharedPreferences hoặc các nơi lưu trữ khác. Điều này rất nguy hiểm vì khi refactor tên enum có thể dẫn đến việc get data bị sai.

**Parameters**: Chỉ có [common parameters](#common-parameters)

**QuickFix**: Không có

**Good**:

```dart
class StorageKeys {
  static const String userStatus = 'user_status';
  static const String notificationType = 'notification_type';
  static const String themeMode = 'theme_mode';
}

// Sử dụng string constants
await prefs.setString(StorageKeys.userStatus, UserStatus.active.name);
await prefs.setString(StorageKeys.notificationType, NotificationType.email.name);
await prefs.setString(StorageKeys.themeMode, ThemeMode.light.name);
```

**Bad**:

```dart
// ❌ BAD: Sử dụng enum name trực tiếp làm key
await prefs.setString(UserStatus.active.name, 'user_data');
await prefs.setString(NotificationType.email.name, 'notification_settings');
await prefs.setString(ThemeMode.light.name, 'theme_preference');

// ❌ BAD: Sử dụng enum trong string interpolation
await prefs.setString('${UserStatus.active.name}_preference', 'value');
await prefs.setString('user_${NotificationType.push.name}_enabled', 'true');
```
