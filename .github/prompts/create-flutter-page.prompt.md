---
mode: 'agent'
model: 'Claude Sonnet 4'
description: 'Tạo Flutter page mới với StateNotifier và UI components'
---

# Tạo Flutter Page mới

Tạo một Flutter page hoàn chỉnh với:

## Yêu cầu:
1. **StateNotifier** để quản lý state
2. **UI Page** với responsive design
3. **Navigation route** trong app_router.dart
4. **Provider** để inject dependencies
5. **Test files** cho cả logic và UI

## Cấu trúc cần tạo:
```
lib/ui/page/${pageName}/
├── ${pageName}_page.dart          # UI page
├── notifier/
│   ├── ${pageName}_notifier.dart  # StateNotifier
│   └── ${pageName}_state.dart     # State class với Freezed
```

## Template StateNotifier:
- Sử dụng `@riverpod` annotation
- Implement loading, success, error states
- Inject các service cần thiết
- Proper error handling

## Template UI Page:
- Extend `BasePage` hoặc `ConsumerWidget`
- Sử dụng `ref.watch()` để lắng nghe state
- Implement loading indicators
- Handle error states với user-friendly messages
- Responsive design cho mobile

## Test Requirements:
- StateNotifier test với `stateNotifierTest`
- Golden test cho UI với `testGoldens`
- Integration test nếu cần

Hãy cung cấp tên page và mô tả chức năng để tôi tạo code phù hợp.
