# Copilot Instructions cho TechTus Flutter Project

## Quy tắc chung

### Ngôn ngữ
- Luôn sử dụng **tiếng Việt** trong comments và documentation
- Tên biến, function, class sử dụng tiếng Anh theo convention

### Cấu trúc dự án
- Tuân thủ Clean Architecture pattern
- Sử dụng Riverpod cho state management
- Injectable cho dependency injection
- Freezed cho data classes

## Code Generation Guidelines

### 1. API Service Classes
- Sử dụng `@LazySingleton()` annotation
- Inject các API clients thông qua constructor
- Tạo provider tương ứng sử dụng `getIt.get<T>()`
- Xử lý error thông qua exception mapper

Ví dụ:
```dart
@LazySingleton()
class MyApiService {
  MyApiService(this._apiClient);
  final ApiClient _apiClient;

  Future<DataType> getData() async {
    return _apiClient.request(
      method: RestMethod.get,
      path: 'endpoint',
      decoder: (json) => DataType.fromJson(json),
    );
  }
}

final myApiServiceProvider = Provider<MyApiService>(
  (ref) => getIt.get<MyApiService>(),
);
```

### 2. Model Classes
- Sử dụng Freezed cho data classes
- Implement `fromJson` và `toJson`
- Sử dụng JsonAnnotation cho mapping fields
- Thêm `copyWith` method

### 3. StateNotifier Classes
- Extend `StateNotifier<State>`
- Sử dụng `@riverpod` annotation
- Implement proper error handling
- Emit loading states

### 4. UI Components
- Sử dụng Hook widgets khi có state logic
- Tuân thủ Material Design principles
- Implement proper responsive design
- Sử dụng theme colors và text styles

### 5. Navigation
- Sử dụng GoRouter cho navigation
- Định nghĩa routes trong `app_router.dart`
- Implement route guards cho authentication

## Testing Guidelines

### Utils/Extension/Helper Tests
- Sử dụng `group` và `test`
- Test các edge cases
- Mock dependencies khi cần

### StateNotifier Tests  
- Sử dụng `group` và `stateNotifierTest`
- Test initial state
- Test state transitions
- Mock external dependencies

### Page/Screen Tests
- Luôn có golden tests với `testGoldens`
- Test UI interactions
- Test navigation flows
- Mock providers và dependencies

## Error Handling
- Sử dụng Result pattern cho API responses
- Implement custom exceptions
- Log errors với proper context
- Show user-friendly error messages

## Performance
- Sử dụng const constructors
- Implement proper widget disposal
- Optimize list rendering với pagination
- Cache network responses khi phù hợp

## Security
- Validate user inputs
- Sanitize data trước khi gửi API
- Implement proper authentication flows
- Protect sensitive data
