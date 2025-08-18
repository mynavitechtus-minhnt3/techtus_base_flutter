# Test Generation Instructions

## Quy tắc sinh test cho TechTus Flutter Project

### 1. Test cho Utils/Extension/Helper
- **Cấu trúc**: Sử dụng `group` và `test`
- **Location**: `test/unit_test/common/`
- **Import**: `import '../../../common/index.dart';`

**Template:**
```dart
void main() {
  group('${ClassName} Tests', () {
    test('should return expected result when valid input', () {
      // Arrange
      final input = 'valid_input';
      const expected = 'expected_output';
      
      // Act
      final result = ClassName.method(input);
      
      // Assert
      expect(result, equals(expected));
    });
  });
}
```

### 2. Test cho StateNotifier
- **Cấu trúc**: Sử dụng `group` và `stateNotifierTest`
- **Location**: `test/unit_test/ui/`
- **Mock**: Tất cả external dependencies

**Template:**
```dart
void main() {
  late MockApiService mockApiService;
  
  setUp(() {
    mockApiService = MockApiService();
  });
  
  group('${NotifierName} Tests', () {
    stateNotifierTest<${NotifierName}, ${StateClass}>(
      'should emit loading then success state when data loads successfully',
      build: () => ${NotifierName}(mockApiService),
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

**Template:**
```dart
void main() {
  group('${PageName} Tests', () {
    testGoldens('should render correctly in initial state', (tester) async {
      await tester.pumpPageWithMockProviders(
        ${PageName}(),
        overrides: [
          ${notifierProvider}.overrideWith(
            (ref) => Mock${NotifierName}(),
          ),
        ],
      );
      
      await expectLater(
        find.byType(${PageName}),
        matchesGoldenFile('goldens/${pageFileName}_initial.png'),
      );
    });
  });
}
```

## Mock Guidelines:
- Sử dụng `mockito` cho mocking
- Mock tất cả external dependencies
- Setup realistic test data
- Test cả success và error scenarios

## File Naming:
- Utils: `${className}_test.dart`
- StateNotifier: `${notifierName}_test.dart`  
- Page: `${pageName}_test.dart`

## Test Data:
- Tạo mock data trong `test/common/mock_data.dart`
- Sử dụng factory methods cho test objects
- Keep test data realistic và consistent
