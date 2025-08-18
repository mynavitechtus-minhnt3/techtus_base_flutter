---
mode: 'agent'
model: 'Claude Sonnet 4'
description: 'Tạo test files theo quy tắc của dự án'
---

# Tạo Test Files cho Flutter Project

Tạo test files tuân thủ quy tắc testing của dự án.

## Loại tests:

### 1. Test cho Utils/Extension/Helper
- **Cấu trúc**: Sử dụng `group` và `test`
- **Location**: `test/unit_test/common/`
- **Pattern**: Test từng method riêng biệt

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../../common/index.dart';

void main() {
  group('${ClassName} Tests', () {
    test('should return expected result when valid input', () {
      // Arrange
      // Act  
      // Assert
    });
    
    test('should throw exception when invalid input', () {
      // Test error cases
    });
  });
}
```

### 2. Test cho StateNotifier
- **Cấu trúc**: Sử dụng `group` và `stateNotifierTest`
- **Location**: `test/unit_test/ui/`
- **Mock**: Dependencies và API calls

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../../common/index.dart';

void main() {
  group('${NotifierName} Tests', () {
    stateNotifierTest<${NotifierName}, ${StateClass}>(
      'should emit loading then success state',
      build: () => ${NotifierName}(mockService),
      act: (notifier) => notifier.loadData(),
      expect: () => [
        ${StateClass}.loading(),
        ${StateClass}.success(data: mockData),
      ],
    );
  });
}
```

### 3. Test cho Page/Screen  
- **Cấu trúc**: Luôn có golden test với `testGoldens`
- **Location**: `test/widget_test/ui/`
- **Setup**: Mock providers và dependencies

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../../common/index.dart';

void main() {
  group('${PageName} Tests', () {
    testGoldens('should render correctly', (tester) async {
      await tester.pumpPageWithMockProviders(
        ${PageName}(),
        overrides: [
          // Mock providers
        ],
      );
      
      await expectLater(
        find.byType(${PageName}),
        matchesGoldenFile('goldens/${pageFileName}.png'),
      );
    });
    
    testWidgets('should handle user interactions', (tester) async {
      // Test interactions
    });
  });
}
```

## Quy tắc chung:
- Import `../../../common/index.dart` cho test utilities
- Sử dụng descriptive test names bằng tiếng Anh
- Group related tests together
- Mock external dependencies
- Test both success và error scenarios
- Sử dụng `setUp` và `tearDown` khi cần

Hãy cung cấp thông tin về file cần test để tôi tạo test phù hợp.
