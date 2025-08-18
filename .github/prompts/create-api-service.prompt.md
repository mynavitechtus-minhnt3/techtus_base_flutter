---
mode: 'agent'  
model: 'Claude Sonnet 4'
description: 'Tạo API service mới cho Flutter project'
---

# Tạo API Service mới

Tạo một API service hoàn chỉnh theo pattern hiện tại của dự án.

## Yêu cầu đầu vào:
- Tên service
- Các endpoints cần implement
- Data models cần thiết

## Cấu trúc sẽ tạo:

### 1. API Service Class
```dart
@LazySingleton()
class ${ServiceName}ApiService {
  ${ServiceName}ApiService(this._apiClient);
  final ApiClient _apiClient;
  
  // Methods cho từng endpoint
}
```

### 2. Provider
```dart
final ${serviceName}ApiServiceProvider = Provider<${ServiceName}ApiService>(
  (ref) => getIt.get<${ServiceName}ApiService>(),
);
```

### 3. Model Classes (nếu cần)
- Sử dụng Freezed pattern
- JsonAnnotation cho API mapping
- Proper validation

### 4. Exception Handling
- Custom exceptions khi cần
- Error mapping phù hợp
- User-friendly error messages

### 5. Tests
- Unit tests cho từng method
- Mock API responses
- Test error scenarios

## Best Practices:
- Tuân thủ RESTful conventions
- Implement proper HTTP status code handling
- Use typed responses với generics
- Implement retry logic cho network errors
- Add proper logging cho debugging

Hãy cung cấp thông tin về service cần tạo để tôi implement.
