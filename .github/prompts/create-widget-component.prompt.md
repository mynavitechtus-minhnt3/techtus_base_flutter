---
mode: 'agent'
model: 'Claude Sonnet 4'
description: 'Tạo reusable widget component cho Flutter'
---

# Tạo Widget Component

Tạo reusable widget component tuân thủ design system của dự án.

## Yêu cầu đầu vào:
- Tên widget component
- Mô tả chức năng
- Props/parameters cần thiết
- Design specifications

## Cấu trúc sẽ tạo:

### 1. Widget Component
```dart
class ${WidgetName} extends StatelessWidget {
  const ${WidgetName}({
    super.key,
    required this.title,
    this.onTap,
    this.isEnabled = true,
  });
  
  final String title;
  final VoidCallback? onTap;
  final bool isEnabled;
  
  @override
  Widget build(BuildContext context) {
    return // Implementation
  }
}
```

### 2. Theming Support
- Sử dụng `Theme.of(context)`
- Support dark/light modes
- Consistent với design system
- Customizable properties

### 3. Accessibility
- Proper semantics labels
- Support screen readers
- Keyboard navigation
- Focus management

### 4. Responsive Design
- Handle different screen sizes
- Proper constraints
- Flexible layouts
- Platform-specific adaptations

### 5. Widget Tests
```dart
testWidgets('should render correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ${WidgetName}(title: 'Test'),
    ),
  );
  
  expect(find.text('Test'), findsOneWidget);
});
```

### 6. Golden Tests
```dart
testGoldens('should match golden file', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ${WidgetName}(title: 'Test'),
    ),
  );
  
  await expectLater(
    find.byType(${WidgetName}),
    matchesGoldenFile('goldens/${widgetName}.png'),
  );
});
```

## Best Practices:
- Immutable properties
- Const constructors
- Proper key handling
- Null safety
- Performance optimization
- Consistent API design

## Location:
- Simple components: `lib/ui/component/`
- Complex components: `lib/ui/component/ui_kit/`
- Page-specific: trong folder của page đó

Hãy cung cấp thông tin về widget cần tạo.
