# Introduction

A VSCode extension used for this code base.

## Table of Contents

- [Installation guide](#installation-guide)
- [1. Settings](#1-settings)
    - [1.1. uiFolderPath](#11-uifolderpath)
    - [1.2. dataModelPath](#12-datamodelpath)
    - [1.3. riverpodPageTemplate](#13-riverpodpagetemplate)
    - [1.4. widgetTestGlobPatterns](#14-widgettestglobpatterns)
- [2. Commands](#2-commands)
    - [2.1. mynavi:Create new Page](#21-mynavicreate-new-page)
    - [2.2. mynavi:[API] Clipboard to Data Model](#22-mynaviapi-clipboard-to-data-model)
    - [2.3. mynavi:[API] Json to Data Model](#23-mynaviapi-json-to-data-model)
    - [2.4. mynavi:[API] Json to Params](#24-mynaviapi-json-to-params)
    - [2.5. mynavi:Create test file](#25-mynavicreate-test-file)
    - [2.6. mynavi:[API] Extract API URL](#26-mynaviapi-extract-api-url)
    - [2.7. mynavi: Translate and extract value to arb files](#27-mynavi-translate-and-extract-value-to-arb-files)

- [3. Snippets](#3-snippets)
    - [3.1. Data model](#31-data-model)
    - [3.2. UI](#32-ui)
    - [3.3. Shared Preferences](#33-shared-preferences)
    - [3.4. ViewModel](#34-viewmodel)
    - [3.5. Mapper](#35-mapper)
    - [3.6. Load More Executor](#36-load-more-executor)
    - [3.7. Testing](#37-testing)
    - [3.8. Others](#38-others)
    
- [4. Quick Fix](#4-quick-fix)
    - [4.1. Wrap with Widget](#41-wrap-with-widget)
    - [4.2. Convert to Widget](#42-convert-to-widget)

## Installation guide
[Installation guide](https://www.alphr.com/vs-code-how-to-install-extensions/#:~:text=Open%20the%20%E2%80%9CExtensions%E2%80%9D%20sidebar%20(you%20can%20use%20%E2%80%9CCtrl%2BShift%2BX%E2%80%9D))

## 1. Settings

Add this to file `.vscode/settings.json`
```
{
    "mynavimobiletool.uiFolderPath": "lib/ui/page",
    "mynavimobiletool.dataModelPath": "lib/model/api",
    "mynavimobiletool.riverpodPageTemplate": "singleModule",
    "mynavimobiletool.widgetTestGlobPatterns": [
        "**/ui/page/**",
        "**/ui/popup/**",
        "**/ui/component/**"
    ]
}
```

### 1.1. uiFolderPath

Path to the Folder that contains the generated files from the command [mynavi:Create new Page](#21-mynavicreate-new-page)

* Default value: `"lib/ui/page"`

### 1.2. dataModelPath

Path to the Folder that contains the generated files from the command [mynavi:[API] Clipboard to Data Model](#22-mynaviapi-clipboard-to-data-model)

* Default value: `"lib/model/api"`

### 1.3. riverpodPageTemplate

Template set used when creating a new riverpod page. Choose between multi-module or single-module structure.

* Available values: `"multiModule"`, `"singleModule"`
* Default value: `"singleModule"`

### 1.4. widgetTestGlobPatterns

Glob patterns that should create widget tests instead of unit tests when using the [mynavi:Create test file](#25-mynavicreate-test-file) command.

* Default value: `[
        "**/ui/page/**",
        "**/ui/popup/**",
        "**/ui/component/**"
    ]`

## 2. Commands

### 2.1. mynavi:Create new Page

Generate 3 classes in the `[mynavimobiletool.uiFolderPath]` folder: 
- 1 class extends `BasePage`
- 1 class extends `BaseState`
- 1 class extends `BaseViewModel`

### 2.2. mynavi:[API] Clipboard to Data Model

Copy a Json and run this command, it will generate all data model files in the `[mynavimobiletool.dataModelPath]` folder. Both of following text are valid:
```
{
    "id": 13,
    "email": "abc@gmail.com"
}
```
```
"id": 13,
"email": "abc@gmail.com",
```

### 2.3. mynavi:[API] Json to Data Model

It is useful when you implement the GET method APIs.

Input:
```
"id": 13,
"email": "minhnt3@nal.vn",
"created_at": "2021-12-06T03:55:22.000000Z",
"average_mark": 6.5,
"roles": ["admin", "user"],
"isVIP": false,
"marks": [1.5,2.0,3],
"friend_ids": [1,2,3],
"name": null,
"classifies":"[{\"id\":1,\"name\":\"M\n h\c\"}]",
```
Output:
```
@Default(0)  @JsonKey(name: 'id') int id,
@Default('')  @JsonKey(name: 'email') String email,
@Default('')  @JsonKey(name: 'created_at') String createdAt,
@Default(0.0)  @JsonKey(name: 'average_mark') double averageMark,
@Default(<String>[])  @JsonKey(name: 'roles') List<String> roles,
@Default(false)  @JsonKey(name: 'isVIP') bool isVip,
@Default(<double>[])  @JsonKey(name: 'marks') List<double> marks,
@Default(<int>[])  @JsonKey(name: 'friend_ids') List<int> friendIds,
@Default(null)  @JsonKey(name: 'name') dynamic name,
@Default('')  @JsonKey(name: 'classifies') String classifies,
```

### 2.4. mynavi:[API] Json to Params

It is useful when you implement the POST method APIs.

Input:
```
"id": 13,
"email": "minhnt3@nal.vn",
"created_at": "2021-12-06T03:55:22.000000Z",
"average_mark": 6.5,
"roles": ["admin", "user"],
"isVIP": false,
"marks": [1.5,2.0,3],
"friend_ids": [1,2,3],
"name": null,
"classifies":"[{\"id\":1,\"name\":\"M\n h\c\"}]",
```
Output:
```
required int id,
required String email,
required String createdAt,
required double averageMark,
required List<String> roles,
required bool isVip,
required List<double> marks,
required List<int> friendIds,
required dynamic name,
required String classifies,

'id': id,
'email': email,
'created_at': createdAt,
'average_mark': averageMark,
'roles': roles,
'isVIP': isVip,
'marks': marks,
'friend_ids': friendIds,
'name': name,
'classifies': classifies,
```

### 2.5. mynavi:Create test file

It's used to generate a test file for the `.dart` file currently displayed in the active Text Editor. If the test file was generated, it will open the test file in the active Text Editor. The test file path will mirror the code file path in the lib folder. For example, if the code file is `lib/ui/page/login/view_model/login_view_model.dart`, the test file will be `test/unit_test/ui/page/login/view_model/login_view_model_test.dart`.

The type of test file created (unit test vs widget test) depends on the `widgetTestGlobPatterns` setting.

### 2.6. mynavi:[API] Extract API URL

It is used to convert the API URL to args of Dio.

Input:
```
{{url}}/training/my-courses/getJoiningCourse?page=1&limit=10&sortBy=created_at&sortDesc=desc&course_id=13&training_type_id=4&platform=1&onlineLearningFormat=zoom&teacher_id=19&persons_charge_id=6&from_time=2024-05-11&to_time=2024-05-12

or

https://google.com/api/training/my-courses/getJoiningCourse?page=1&limit=10&sortBy=created_at&sortDesc=desc&course_id=13&training_type_id=4&platform=1&onlineLearningFormat=zoom&teacher_id=19&persons_charge_id=6&from_time=2024-05-11&to_time=2024-05-12
```

Output:
```
Future<XXX> get({
  required int page,
  required int limit,
  required String sortBy,
  required String sortDesc,
  required int courseId,
  required int trainingTypeId,
  required int platform,
  required String onlineLearningFormat,
  required int teacherId,
  required int personsChargeId,
  required String fromTime,
  required String toTime,
}) {
  return authAppServerClient.request(
    method: RestMethod.get,
    path: 'training/my-courses/getJoiningCourse',
    queryParameters: {
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortDesc': sortDesc,
      'course_id': courseId,
      'training_type_id': trainingTypeId,
      'platform': platform,
      'onlineLearningFormat': onlineLearningFormat,
      'teacher_id': teacherId,
      'persons_charge_id': personsChargeId,
      'from_time': fromTime,
      'to_time': toTime,
    },
// decoder: XXX.fromJson,
// successResponseMapperType: SuccessResponseMapperType.yyy,
  );
}
```

Input:
```
?course_id=8&platform=2&status=2&time_start=2024-05-08&time_end=2024-05-24

or

course_id=8&platform=2&status=2&time_start=2024-05-08&time_end=2024-05-24
```

Output:
```
Future<XXX> get({
  required int courseId,
  required int platform,
  required int status,
  required String timeStart,
  required String timeEnd,
}) {
  return authAppServerClient.request(
    method: RestMethod.get,
    path: '',
    queryParameters: {
      'course_id': courseId,
      'platform': platform,
      'status': status,
      'time_start': timeStart,
      'time_end': timeEnd,
    },
// decoder: XXX.fromJson,
// successResponseMapperType: SuccessResponseMapperType.yyy,
  );
}
```

Input:
```
v1/training/courses/25/register

or

/v1/training/courses/25/register

or 

api/v1/training/courses/25/register

or

/api/v1/training/courses/25/register
```

Output:
```
Future<XXX> get() {
  return authAppServerClient.request(
    method: RestMethod.get,
    path: 'v1/training/courses/25/register',
// decoder: XXX.fromJson,
// successResponseMapperType: SuccessResponseMapperType.yyy,
  );
}
```

### 2.7. mynavi: Translate and extract value to arb files

Copy a text and run this command, it will generate a key-value pair in all arb files in the `lib/resource/l10n` folder. The arb files will be automatically sorted in alphabetical order.

## 3. Snippets

### 3.1. Data model

* `fr` - Freezed model class
* `am` - API data model class
* `fm` - Firebase data model class
* `im` - Isar data model class

### 3.2. UI

* `sl`: A widget that extends `StatelessWidget`
* `sf`: A widget that extends `StatefulWidget`
* `hk`: A widget that extends `HookWidget`
* `hc`: A widget that extends `HookConsumerWidget`
* `hs`: A widget that extends `StatefulHookConsumerWidget`
* `bp`: A widget that extends `BasePage`
* `bs`: A widget that extends `StatefulHookConsumerWidget` and a class that extends `BaseStatefulPageState`
* `pa`: `EdgeInsets.all(xx.rps)`
* `pv`: `EdgeInsets.symmetric(vertical: xx.rps,)`
* `ph`: `EdgeInsets.symmetric(horizontal: xx.rps,)`
* `sw`: `SizedBox(width: xx.rps),`
* `sh`: `SizedBox(height: xx.rps),`
* `fi`: `https://cdn.pixabay.com/photo/2012/08/27/14/19/mountains-55067_1280.png`
* `po`: `EdgeInsets.only(xx: yy.rps)`
* `di`: `xx.rps`
* `co`: `color.xx`
* `img`: `image.xx`
* `st`: `style(fontSize: xx.rps, color: color.yy,)`
* `ln`: `l10n.xx`
* `ue`: `useEffect(() {Future.microtask(() {})...`
* `sd`: `await ref.nav.showDialog(CommonPopup.xxx());`
* `ssb`: `ref.nav.showSnackBar(CommonPopup.xxx());`
* `sbs`: `await ref.nav.showModalBottomSheet(CommonPopup.xxx());`
* `sb`: `SchedulerBinding.instance.addPostFrameCallback...`

### 3.3. Shared Preferences

- `spb` - setter and getter for `bool` value in Shared Preferences
- `spi` - setter and getter for `int` value in Shared Preferences
- `spd` - setter and getter for `double` value in Shared Preferences
- `sps` - setter and getter for `String` value in Shared Preferences

### 3.4. ViewModel

- `rc` - `await runCatching(action: () async {}...` in ViewModel classes

### 3.5. Mapper

* `mp` - generate a mapper class that converts API data to Local data

### 3.6. Load More Executor

- `lm` - generate a class that extends `LoadMoreExecutor`

### 3.7. Testing

- `nt` - `stateNotifierTest(...)`
- `gt` - `testGoldens(...)` used for Pages using non-family Providers (`StateNotifierProvider.autoDispose`)
- `gtf` - `testGoldens(...)` used for Pages using family Providers (`StateNotifierProvider.autoDispose
    .family`)

### 3.8. Others

- `dl` - `await Future<dynamic>.delayed(const Duration(milliseconds: xx))`
- `pr` - Riverpod provider `Provider.autoDispose<...>((ref) => ...)`

## 4. Quick Fix

### 4.1. Wrap with Widget
- Wrap with Consumer
- Wrap with CommonContainer
- Wrap with Stack
- Wrap with Expanded
- Wrap with Flexible
- Wrap with SingleChildScrollView
- Wrap with Horizontal Padding: `Padding(padding: EdgeInsets.symmetric(horizontal: 16.rps))`
- Wrap with Vertical Padding: `Padding(padding: EdgeInsets.symmetric(vertical: 16.rps))`
- Wrap with InkWell
- Wrap with GestureDetector

### 4.2. Convert to Widget
- Convert from `BasePage` to `StatefulHookConsumerWidget` & `BaseStatefulPageState`
- Convert from `StatefulHookConsumerWidget` to `BasePage`
