---
mode: 'agent'
model: 'Claude Sonnet 4' 
description: 'Tạo model class với Freezed pattern'
---

# Tạo Model Class với Freezed

Tạo model class tuân thủ pattern của dự án sử dụng Freezed.

## Input cần thiết:
- Tên model class
- Các fields và types
- JSON structure (nếu từ API)

## Template sẽ tạo:

### 1. Model Class
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '${fileName}.freezed.dart';
part '${fileName}.g.dart';

@freezed
class ${ModelName} with _$${ModelName} {
  const factory ${ModelName}({
    // Fields với proper types
    required String id,
    String? name,
    @Default(false) bool isActive,
  }) = _${ModelName};

  factory ${ModelName}.fromJson(Map<String, dynamic> json) =>
      _$${ModelName}FromJson(json);
}
```

### 2. Converter Classes (nếu cần)
- DateTime converters
- Custom type converters
- Enum converters

### 3. Mapper Classes (nếu cần)
- API to Domain mapping
- Database to Domain mapping
- UI to Domain mapping

## Best Practices:
- Sử dụng required cho mandatory fields
- Default values cho optional fields
- Proper nullable types
- JsonKey annotation cho field mapping
- Validation trong factory constructors

## Types phổ biến:
- `String`, `int`, `double`, `bool`
- `DateTime` với converter
- `List<T>`, `Map<String, dynamic>`
- Custom enums
- Nested objects

Hãy cung cấp thông tin về model cần tạo.
