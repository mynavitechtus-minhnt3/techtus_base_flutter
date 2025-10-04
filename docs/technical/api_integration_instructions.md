# API Integration Instructions

## Overview

This document provides comprehensive guidelines for API integration in the project, focusing on creating API service functions and model classes using the established patterns.

## Rules

If the model already exists in the project, do not create a new one.

## Core Components

### 1. RestApiClient
The base client for all HTTP requests with built-in error handling and response decoding.

### 2. AppApiService
Service layer containing all API endpoint methods

### 3. Model Classes
Data transfer objects using Freezed for immutability and JSON serialization.

### 4. Converters
Custom JSON converters for complex data types like DateTime, enums, etc.

## API Service Implementation

### Basic Request Pattern

```dart
Future<ReturnType?> methodName({
  required String param1,
  int? optionalParam,
}) async {
  final response = await _authAppServerApiClient.request<ModelType, ResponseWrapper<ModelType>>(
    method: RestMethod.post,
    path: 'api/v1/endpoint',
    body: {
      'param1': param1,
      'optional_param': optionalParam,
    },
    decoder: (json) => ModelType.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),
  );
  
  return response?.data ?? const ModelType();
}
```

## SuccessResponseDecoderType Usage

### 1. `dataJsonObject` (Default)
**Use Case**: Single object wrapped in `{data: {...}}`

**API Response**:
```json
{
  "data": {
    "id": 1,
    "name": "User Name"
  }
}
```

**Implementation**:
```dart
Future<ApiUserInfoData> getUserDetail({required int id}) async {
  final response = await _authAppServerApiClient.request<ApiUserInfoData, DataResponse<ApiUserInfoData>>(
    method: RestMethod.get,
    path: 'api/v1/users/$id',
    successResponseDecoderType: SuccessResponseDecoderType.dataJsonObject, // Can be omitted (default)
    decoder: (json) => ApiUserInfoData.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),
  );
  return response?.data ?? const ApiUserInfoData();
}
```

### 2. `dataJsonArray`
**Use Case**: Array wrapped in `{data: [...]}`

**API Response**:
```json
{
  "data": [
    {"id": 1, "name": "User Type 1"},
    {"id": 2, "name": "User Type 2"}
  ]
}
```

**Implementation**:
```dart
Future<DataListResponse<ApiUserTypeData>?> getUserTypes() {
  return _authAppServerApiClient.request(
    method: RestMethod.get,
    path: 'api/v1/user-types',
    successResponseDecoderType: SuccessResponseDecoderType.dataJsonArray,
    decoder: (json) => ApiUserTypeData.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),
  );
}
```

### 3. `jsonObject`
**Use Case**: Direct object response without wrapper

**API Response**:
```json
{
  "id": 1,
  "name": "Direct Object"
}
```

**Implementation**:
```dart
Future<ApiAddressData?> lookupAddress(String postalCode) async {
  return _rawApiClient.request(
    method: RestMethod.get,
    path: 'address/$postalCode.json',
    successResponseDecoderType: SuccessResponseDecoderType.jsonObject,
    decoder: (json) => ApiAddressData.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),
  );
}
```

### 4. `jsonArray`
**Use Case**: Direct array response

**API Response**:
```json
[
  {"id": 1, "name": "Item 1"},
  {"id": 2, "name": "Item 2"}
]
```

### 5. `paging`
**Use Case**: Paginated responses with metadata

**API Response**:
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "total_pages": 5,
    "total_count": 100
  }
}
```

### 6. `plain`
**Use Case**: Non-JSON responses or when no decoding needed

**Implementation**:
```dart
Future<void> confirmChangeEmail({required String confirmToken}) async {
  await _authAppServerApiClient.request(
    method: RestMethod.post,
    path: 'api/v1/user/email/edit/confirm',
    body: {'confirmation_token': confirmToken},
    successResponseDecoderType: SuccessResponseDecoderType.plain,
  );
}
```

## ErrorResponseDecoderType Usage

### 1. `jsonObject` (Default)
**Use Case**: Standard error response format

**Error Response**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": [...]
  }
}
```

### 2. `jsonArray`
**Use Case**: Multiple error objects

**Error Response**:
```json
[
  {"field": "email", "message": "Invalid email"},
  {"field": "password", "message": "Too short"}
]
```

## customSuccessResponseDecoder Usage

**Use Case**: When you need custom response processing (headers, complex transformation)

**Example - Authentication with Headers**:
```dart
Future<ApiTokenData?> signIn({
  required String email,
  required String password,
}) async {
  return _noneAuthAppServerApiClient.request(
    method: RestMethod.post,
    path: 'api/v1/auth/sign_in',
    body: {
      'email': email,
      'password': password,
    },
    customSuccessResponseDecoder: (response) {
      final headerMap = response.headers.map;
      final bodyMap = response.data;
      final userId = bodyMap['data']?['id'];
      
      return ApiTokenData(
        accessToken: headerMap[Constant.accessTokenKey]?.firstOrNull ?? '',
        client: headerMap[Constant.clientKey]?.firstOrNull ?? '',
        uid: headerMap[Constant.uidKey]?.firstOrNull ?? '',
        userId: userId != null ? int.tryParse(userId.toString()) ?? 0 : 0,
      );
    }
  );
}
```

**Example - Extract Specific Field**:
```dart
Future<String?> registerAccount({
  required String email,
  required String password,
}) async {
  return _noneAuthAppServerApiClient.request(
    method: RestMethod.post,
    path: 'api/v1/auth/sign_up',
    body: {
      'email': email,
      'password': password,
    },
    customSuccessResponseDecoder: (response) {
      final json = safeCast<Map<String, dynamic>>(response.data);
      return safeCast<String>(json?['data']?['email']);
    },
  );
}
```

## Options Parameter Usage

**Use Case**: Custom headers, timeouts, content types

**Example - Custom Headers**:
```dart
Future<void> resetPassword({
  required String uid,
  required String client,
  required String accessToken,
  required String password,
}) async {
  await _noneAuthAppServerApiClient.request(
    method: RestMethod.put,
    path: 'api/v1/auth/password',
    options: Options(
      headers: {
        Constant.uidKey: uid,
        Constant.clientKey: client,
        Constant.accessTokenKey: accessToken,
      },
    ),
    body: {
      'password': password,
      'password_confirmation': password,
    },
  );
}
```

**Example - Custom Timeout**:
```dart
Future<ApiUserListResponse?> getUserList() async {
  return _authAppServerApiClient.request(
    method: RestMethod.get,
    path: 'api/v1/users',
    options: Options(
      receiveTimeout: Duration(seconds: 30), // Custom timeout
      responseType: ResponseType.json,
    ),
    decoder: (json) => ApiUserListResponse.fromJson(json),
  );
}
```

## Model Class Implementation

### Basic Model Structure

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../index.dart';

part 'api_user_info_data.freezed.dart';
part 'api_user_info_data.g.dart';

@freezed
class ApiUserInfoData with _$ApiUserInfoData {
  const ApiUserInfoData._(); // Enable custom methods

  const factory ApiUserInfoData({
    @Default(0) int id,
    @Default('') String name,
    @Default(ApiUserData()) @JsonKey(name: 'user_data') ApiUserData userData,
    @ApiDateTimeConverter() @JsonKey(name: 'created_at') DateTime? createdAt,
    @Default(UserStatus.active) @JsonKey(name: 'status') UserStatus status,
  }) = _ApiUserInfoData;

  factory ApiUserInfoData.fromJson(Map<String, dynamic> json) => 
      _$ApiUserInfoDataFromJson(json);
  
  // Custom methods
  String get displayName => name.isEmpty ? 'Unnamed User' : name;
  bool get isActive => status == UserStatus.active;
}
```

### Model Best Practices

#### 1. **Naming Convention**
- API models: `Api[EntityName]Data`
- Enums: `[EntityName][PropertyName]` (e.g., `UserStatus`, `AccountStatus`)
- Converters: `[Type]Converter` (e.g., `ApiDateTimeConverter`)

#### 2. **Default Values**
```dart
const factory ApiUserInfoData({
  @Default(0) int id,                    // Primitive defaults
  @Default('') String name,              // Empty string for strings
  @Default([]) List<String> tags,        // Empty list for collections
  @Default(ApiUserData()) ApiUserData user, // Default constructor for objects
  DateTime? createdAt,                   // Nullable for optional fields
}) = _ApiUserInfoData;
```

#### 3. **JSON Key Mapping**
```dart
const factory ApiUserData({
  @JsonKey(name: 'user_id') int id,
  @JsonKey(name: 'first_name') String firstName,
  @JsonKey(name: 'last_name') String lastName,
  @JsonKey(name: 'created_at') @ApiDateTimeConverter() DateTime? createdAt,
}) = _ApiUserData;
```

#### 4. **Custom Methods**
```dart
@freezed
class ApiUserInfoData with _$ApiUserInfoData {
  const ApiUserInfoData._(); // Required for custom methods

  const factory ApiUserInfoData({...}) = _ApiUserInfoData;

  factory ApiUserInfoData.fromJson(Map<String, dynamic> json) => 
      _$ApiUserInfoDataFromJson(json);

  // Custom getters
  String get fullName => '$firstName $lastName';
  bool get isAdult => age >= 18;
  
  // Custom methods
  String formatBirthDate() => birthDate?.formatDateString() ?? '';
  bool hasTag(String tag) => tags.contains(tag);
}
```

## Enum Implementation

### Basic Enum with JSON Conversion

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

enum UserStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive') 
  inactive,
  @JsonValue('deleted')
  deleted;

  String get code => switch (this) {
    UserStatus.active => 'active',
    UserStatus.inactive => 'inactive', 
    UserStatus.deleted => 'deleted',
  };

  static UserStatus fromCode(String code) => switch (code) {
    'active' => UserStatus.active,
    'inactive' => UserStatus.inactive,
    'deleted' => UserStatus.deleted,
    _ => UserStatus.active, // Default fallback
  };

  String get displayName => switch (this) {
    UserStatus.active => 'Active',
    UserStatus.inactive => 'Inactive',
    UserStatus.deleted => 'Deleted',
  };
}
```

### Using @JsonEnum for complex Enum with Additional Properties

```dart
@JsonEnum(valueField: 'code')
enum StatusCodeEnhanced {
  success(200, 'Success'),
  movedPermanently(301, 'Moved Permanently'),
  found(302, 'Found'),
  internalServerError(500, 'Internal Server Error');

  const StatusCodeEnhanced(this.code, this.displayName);
  final int code;
  final String displayName;
}
```

## Converter Implementation

### DateTime Converter

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../../index.dart';

class ApiDateTimeConverter implements JsonConverter<DateTime?, String?> {
  const ApiDateTimeConverter();

  @override
  DateTime? fromJson(String? dateString) => DateTimeUtil.tryParse(dateString)?.toLocal();

  @override
  String? toJson(DateTime? object) => object?.formatApiString();
}

// Usage in model
@freezed
class ApiEventData with _$ApiEventData {
  const factory ApiEventData({
    @ApiDateTimeConverter() @JsonKey(name: 'start_time') DateTime? startTime,
    @ApiDateTimeConverter() @JsonKey(name: 'end_time') DateTime? endTime,
  }) = _ApiEventData;
  
  factory ApiEventData.fromJson(Map<String, dynamic> json) => _$ApiEventDataFromJson(json);
}
```

### Custom String Converter

```dart
class ApiReservationStringConverter implements JsonConverter<String, dynamic> {
  const ApiReservationStringConverter();

  @override
  String fromJson(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  @override
  String toJson(String object) => object;
}
```

### Enum Converter

```dart
class UserStatusConverter implements JsonConverter<UserStatus, String> {
  const UserStatusConverter();

  @override
  UserStatus fromJson(String json) => UserStatus.fromCode(json);

  @override
  String toJson(UserStatus object) => object.code;
}

// Usage
@freezed
class ApiUserData with _$ApiUserData {
  const factory ApiUserData({
    @UserStatusConverter() @JsonKey(name: 'status') @Default(UserStatus.active) UserStatus status,
  }) = _ApiUserData;
}
```

## Real-World Example: User Registration API

### 1. API Service Method

```dart
Future<ApiUserInfoData> registerUserInfo({
  required ApiUserInfoData userData,
}) async {
  final response = await _authAppServerApiClient.request<ApiUserInfoData, DataResponse<ApiUserInfoData>>(
    method: RestMethod.post,
    path: 'api/v1/users',
    body: {
      'name': userData.user.name,
      'email': userData.user.email,
      'user_type': userData.user.userType.code,
      'role_ids': userData.user.roleIds,
      'gender': userData.user.gender.code,
      'birth_date': userData.user.birthDateFormatApi,
      'phone': userData.user.phone,
      'registration_date': userData.user.registrationDateFormatApi,
      'address': userData.user.address,
      'is_verified': userData.user.isVerified,
      'is_active': userData.user.isActive,
      'profile_description': userData.user.profileDescription,
    },
    successResponseDecoderType: SuccessResponseDecoderType.dataJsonObject,
    decoder: (json) => ApiUserInfoData.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),
  );

  return response?.data ?? const ApiUserInfoData();
}
```

### 2. Model Classes

```dart
// api_user_info_data.dart
@freezed
class ApiUserInfoData with _$ApiUserInfoData {
  const ApiUserInfoData._();

  const factory ApiUserInfoData({
    @Default(ApiUserData()) @JsonKey(name: 'user') ApiUserData user,
  }) = _ApiUserInfoData;

  factory ApiUserInfoData.fromJson(Map<String, dynamic> json) => _$ApiUserInfoDataFromJson(json);
}

// api_user_data.dart
@freezed
class ApiUserData with _$ApiUserData {
  const ApiUserData._();

  const factory ApiUserData({
    @Default(0) int id,
    @Default('') String name,
    @Default('') @JsonKey(name: 'email') String email,
    @Default(UserType.regular) @JsonKey(name: 'user_type') UserType userType,
    @Default([]) @JsonKey(name: 'role_ids') List<int> roleIds,
    @Default(UserGender.male) @JsonKey(name: 'gender') UserGender gender,
    @ApiDateTimeConverter() @JsonKey(name: 'birth_date') DateTime? birthDate,
    @Default('') @JsonKey(name: 'phone') String phone,
    @ApiDateTimeConverter() @JsonKey(name: 'registration_date') DateTime? registrationDate,
    @Default('') @JsonKey(name: 'address') String address,
    @Default(false) @JsonKey(name: 'is_verified') bool isVerified,
    @Default(false) @JsonKey(name: 'is_active') bool isActive,
    @Default('') @JsonKey(name: 'profile_description') String profileDescription,
  }) = _ApiUserData;

  factory ApiUserData.fromJson(Map<String, dynamic> json) => _$ApiUserDataFromJson(json);

  // Custom methods
  String? get birthDateFormatApi => birthDate?.formatApiString();
  String? get registrationDateFormatApi => registrationDate?.formatApiString();
  String get displayName => name.isEmpty ? 'Unnamed User' : name;
}
```

### 3. Enums

```dart
// user_gender.dart
enum UserGender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other;

  String get code => switch (this) {
    UserGender.male => 'male',
    UserGender.female => 'female',
    UserGender.other => 'other',
  };

  static UserGender fromCode(String? code) => switch (code) {
    'male' => UserGender.male,
    'female' => UserGender.female,
    'other' => UserGender.other,
    _ => UserGender.other,
  };

  String get displayName => switch (this) {
    UserGender.male => 'Male',
    UserGender.female => 'Female', 
    UserGender.other => 'Other',
  };
}

// user_type.dart
enum UserType {
  @JsonValue('regular')
  regular,
  @JsonValue('premium')
  premium,
  @JsonValue('admin')
  admin;

  String get code => switch (this) {
    UserType.regular => 'regular',
    UserType.premium => 'premium',
    UserType.admin => 'admin',
  };

  static UserType fromCode(String? code) => switch (code) {
    'regular' => UserType.regular,
    'premium' => UserType.premium,
    'admin' => UserType.admin,
    _ => UserType.regular,
  };

  String get displayName => switch (this) {
    UserType.regular => 'Regular User',
    UserType.premium => 'Premium User',
    UserType.admin => 'Administrator',
  };
}
```

## Code Generation Commands

After creating/modifying models, run:

```bash
# Generate freezed and json_serializable code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Or use make command
make fb
```

## Common Patterns & Best Practices

### 1. Error Handling
Always provide fallback values and handle null responses:

```dart
return response?.data ?? const ApiUserInfoData();
```

### 2. Safe Casting
Use `safeCast` for type safety:

```dart
decoder: (json) => ApiUserInfoData.fromJson(json.safeCast<Map<String, dynamic>>() ?? {}),
```

### 3. Conditional Body Parameters
Handle optional parameters in request body:

```dart
body: {
  'required_param': requiredValue,
  if (optionalParam != null) 'optional_param': optionalParam,
  if (condition) ...{
    'conditional_field1': value1,
    'conditional_field2': value2,
  },
},
```

### 4. Complex Transformations
For complex data transformations, use custom methods in models:

```dart
List<Map<String, dynamic>> get apiFormat => items.map((item) => {
  'id': item.id,
  'name': item.name,
  'metadata': item.toMetadataJson(),
}).toList();
```

### 5. Validation in Models
Add validation methods to ensure data integrity:

```dart
@freezed
class ApiUserData with _$ApiUserData {
  const ApiUserData._();
  
  const factory ApiUserData({...}) = _ApiUserData;
  
  factory ApiUserData.fromJson(Map<String, dynamic> json) => _$ApiUserDataFromJson(json);
  
  // Validation methods
  bool get isValidAge => birthDate != null && DateTime.now().difference(birthDate!).inDays > 0;
  bool get hasValidName => name.isNotEmpty && name.length <= 50;
  bool get hasValidEmail => email.contains('@') && email.isNotEmpty;
  
  List<String> get validationErrors {
    final errors = <String>[];
    if (!hasValidName) errors.add('Invalid user name');
    if (!hasValidEmail) errors.add('Invalid email address');
    if (!isValidAge) errors.add('Invalid birth date');
    return errors;
  }
  
  bool get isValid => validationErrors.isEmpty;
}
```

This comprehensive guide covers all aspects of API integration following the established patterns in the this codebase.
