<!-- omit from toc -->

# All Lint Rules

## Table of Contents

- [Table of Contents](#table-of-contents)
- [All lint rules](#all-lint-rules-1)
  - [prefer_named_parameters](#prefer_named_parameters)
  - [incorrect_todo_comment](#incorrect_todo_comment)
  - [prefer_is_empty_string](#prefer_is_empty_string)
  - [prefer_is_not_empty_string](#prefer_is_not_empty_string)
  - [avoid_unnecessary_async_function](#avoid_unnecessary_async_function)
  - [prefer_async_await](#prefer_async_await)
  - [prefer_lower_case_test_description](#prefer_lower_case_test_description)
  - [test_folder_must_mirror_lib_folder](#test_folder_must_mirror_lib_folder)
  - [incorrect_freezed_default_value_type](#incorrect_freezed_default_value_type)
  - [prefer_single_widget_per_file](#prefer_single_widget_per_file)
  - [util_functions_must_be_static](#util_functions_must_be_static)
  - [missing_extension_method_for_events](#missing_extension_method_for_events)
  - [missing_log_in_catch_block](#missing_log_in_catch_block)
  - [missing_run_catching](#missing_run_catching)
  - [incorrect_event_parameter_type](#incorrect_event_parameter_type)
  - [incorrect_screen_name_enum_value](#incorrect_screen_name_enum_value)
  - [incorrect_screen_name_parameter_value](#incorrect_screen_name_parameter_value)
  - [missing_common_scrollbar](#missing_common_scrollbar)
  - [avoid_using_text_style_constructor_directly](#avoid_using_text_style_constructor_directly)
  - [avoid_using_unsafe_cast](#avoid_using_unsafe_cast)
  - [incorrect_event_name](#incorrect_event_name)
  - [incorrect_event_parameter_name](#incorrect_event_parameter_name)
  - [avoid_dynamic](#avoid_dynamic)
  - [avoid_nested_conditions](#avoid_nested_conditions)
  - [avoid_using_if_else_with_enums](#avoid_using_if_else_with_enums)
  - [avoid_hard_coded_colors](#avoid_hard_coded_colors)
  - [prefer_importing_index_file](#prefer_importing_index_file)
  - [prefer_common_widgets](#prefer_common_widgets)
  - [missing_expanded_or_flexible](#missing_expanded_or_flexible)
  - [incorrect_parent_class](#incorrect_parent_class)
  - [avoid_hard_coded_strings](#avoid_hard_coded_strings)

## All lint rules

### prefer_named_parameters

If a function or constructor takes more parameters than the threshold, use named parameters.

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

  A.a({
    required this.a,
    this.b = '',
  });

  A.b({
    required this.a,
    String? b,
  }) : b = b ?? '';

  void test2({
    required String a,
    String b = '',
  }) {}
}

void test2({
  String a = '',
  String? b,
}) {}
```

**Bad**:

```dart
class B {
  final String a;
  final String b;

  B(this.a, this.b); 
  B.a(this.a, [this.b = '']); 
  B.b(this.a, {this.b = ''}); 
  B.c(this.a, {required this.b}); 
  B.d(this.a, String? b) : b = b ?? ''; 
}

void test4(String a, String b) {} 
void test5(String a, [String b = '']) {} 
void test6(String a, {required String b}) {} 
void test7(String a, {String b = ''}) {} 
void test8(String a, {String? b}) {} 
void test9([String? a, String? b = '']) {} 
```

### incorrect_todo_comment

TODO comments must have username, description and issue number (or #0 if no issue).

Example: `// TODO(username): some description text #123.`

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

// TODO(minhnt3)     : Remove this file when the issue is fixed #-123 .

// TODO   (minhnt3): Remove this file when the issue is fixed #123 .

// TODO(minhnt3):               #123  .

// TODO() Remove this file when the issue is fixed #123.
```

### prefer_is_empty_string

Use `isEmpty` instead of `==` to test whether the string is empty.

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

### prefer_is_not_empty_string

Use `isNotEmpty` instead of `==` to test whether the string is empty.

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

### avoid_unnecessary_async_function

If a function does not have any asynchronous computation, there is no need to create an async function.

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

class AsyncNotifier {
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

class Notifier {
  Future<void> login() async {
    Future(() => print('hello'));

    print('login');
  }

  FutureOr<String> getName() async {
    unawaited(Future<dynamic>.delayed(const Duration(milliseconds: 2000)));

    return 'name';
  }
}
```

### test_folder_must_mirror_lib_folder

Test files must have names ending with '\_test', and their paths must mirror the structure of the 'lib' folder.

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

### prefer_async_await

Prefer using async/await syntax instead of .then invocations.

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


  future.then((value) => null).then((value) => null).then((value) => null);


  future.then((value) {
    print('then');

  }).then((value) {
    print('then');

  }).then((value) {
    print('then');
  });
}
```

### prefer_lower_case_test_description

Lower case the first character when writing tests descriptions.

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
test('_lowercase text', () {});
test('*lowercase text', () {});

blocTest('lowercase text', () {});
blocTest('1lowercase text', () {});
blocTest('_lowercase text', () {});
blocTest('*lowercase text', () {});

stateNotifierTest('Uppercase text', () {});
```

**Bad**:

```dart
test('uppercase text', () {});

blocTest('Uppercase text', () {});
```

### incorrect_freezed_default_value_type

The value passed to `@Default()` in a freezed class must have a compatible type with the annotated field.

```yaml
- incorrect_freezed_default_value_type:
```

**Good**:

```dart
@Default(<ApiUserData>[]) List<ApiUserData> allContacts,
```

**Bad**:

```dart
@Default(0) List<ApiUserData> allContacts,
```

### prefer_single_widget_per_file

Each file should contain only one widget class.

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

### util_functions_must_be_static

Utility functions should be static.

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

### missing_extension_method_for_events

Events should have corresponding extension methods.

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

### missing_log_in_catch_block

Catch blocks should include logging.

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

### missing_run_catching

Use runCatching for error handling.

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

### incorrect_event_parameter_type

Event parameters should have correct types. Parameters must only allow String, int or double values.

```yaml
- incorrect_event_parameter_type:
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
  final dynamic username;
  final dynamic password;
}
```

### incorrect_screen_name_enum_value

Screen name enum values should follow naming conventions.

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

### incorrect_screen_name_parameter_value

Screen name parameter values should match enum values.

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

### missing_common_scrollbar

Use common scrollbar widget for scrollable content.

```yaml
- missing_common_scrollbar:
```

**Good**:

```dart
CommonScrollbar(
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
```

### avoid_using_text_style_constructor_directly

Use predefined text styles instead of direct TextStyle constructor.

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

### avoid_using_unsafe_cast

Avoid unsafe type casting.

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

### incorrect_event_name

Event names should follow naming conventions.

```yaml
- incorrect_event_name:
```

**Good**:

```dart
class UserLoggedInEvent {}
```

**Bad**:

```dart
class userLoggedIn {}
```

### incorrect_event_parameter_name

Event parameter names should follow naming conventions.

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

### avoid_dynamic

Avoid using dynamic type.

```yaml
- avoid_dynamic:
```

**Good**:

```dart
String getValue() {
  return 'value';
}
```

**Bad**:

```dart
dynamic getValue() {
  return 'value';
}
```

### avoid_nested_conditions

Avoid deeply nested conditions.

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

### avoid_using_if_else_with_enums

Use switch statements with enums instead of if-else.

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

### avoid_hard_coded_colors

Use color constants instead of hard-coded colors.

```yaml
- avoid_hard_coded_colors:
```

**Good**:

```dart
Container(
  color: AppColors.primary,
)
```

**Bad**:

```dart
Container(
  color: Color(0xFF000000),
)
```

### prefer_importing_index_file

Import from index files instead of individual files.

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

### prefer_common_widgets

Use common widgets instead of basic Flutter widgets.

```yaml
- prefer_common_widgets:
```

**Good**:

```dart
CommonButton(
  onPressed: () {},
  child: Text('Click me'),
)
```

**Bad**:

```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Click me'),
)
```

### missing_expanded_or_flexible

Use Expanded or Flexible for widgets in Row/Column.

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
    Text('Long text'),
    Icon(Icons.star),
  ],
)
```

### incorrect_parent_class

Widgets should extend the correct parent class.

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
  // Should be StatelessWidget
}
```

### avoid_hard_coded_strings

Use string constants instead of hard-coded strings.

```yaml
- avoid_hard_coded_strings:
```

**Good**:

```dart
Text(AppStrings.welcomeMessage)
```

**Bad**:

```dart
Text('Welcome to the app!')
```
