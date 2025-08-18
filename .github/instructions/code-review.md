# Code Review Instructions cho Flutter/Dart

## Quy tắc review code cho TechTus Flutter Project

### 1. Architecture & Design Patterns
- ✅ Tuân thủ Clean Architecture (Data → Domain → Presentation)
- ✅ Sử dụng đúng Riverpod patterns cho state management
- ✅ Injectable được sử dụng đúng cho DI
- ✅ Separation of concerns được đảm bảo

### 2. Code Quality
- ✅ Tên biến, function, class rõ ràng và meaningful
- ✅ Functions không quá dài (< 20 lines)
- ✅ Classes có single responsibility
- ✅ Proper error handling với Result pattern
- ✅ Null safety được implement đúng

### 3. Flutter/Dart Best Practices
- ✅ Sử dụng `const` constructors khi có thể
- ✅ Widget composition thay vì inheritance
- ✅ Proper disposal của resources (controllers, streams)
- ✅ Avoid setState() trong StatelessWidget
- ✅ Use `late` keyword cẩn thận

### 4. State Management (Riverpod)
- ✅ StateNotifier được implement đúng pattern
- ✅ Providers được define ở đúng scope
- ✅ State classes sử dụng Freezed
- ✅ Proper loading/error/success states
- ✅ Avoid unnecessary state rebuilds

### 5. API Integration
- ✅ Proper HTTP status code handling
- ✅ Request/Response models được define đúng
- ✅ Error mapping được implement
- ✅ Retry logic cho network failures
- ✅ Proper timeout configurations

### 6. UI/UX
- ✅ Responsive design cho different screen sizes
- ✅ Accessibility features (semantics)
- ✅ Loading states và error handling
- ✅ Consistent design system usage
- ✅ Proper navigation flows

### 7. Performance
- ✅ Avoid unnecessary widget rebuilds
- ✅ Proper list optimization (ListView.builder)
- ✅ Image optimization và caching
- ✅ Memory leak prevention
- ✅ Efficient data structures

### 8. Testing
- ✅ Unit tests cho business logic
- ✅ Widget tests cho UI components  
- ✅ Golden tests cho visual regression
- ✅ Integration tests cho critical flows
- ✅ Proper mocking của dependencies

### 9. Security
- ✅ Input validation và sanitization
- ✅ Secure storage cho sensitive data
- ✅ Proper authentication implementation
- ✅ API security best practices
- ✅ No hardcoded secrets

### 10. Documentation
- ✅ Public APIs có documentation comments
- ✅ Complex logic được explain
- ✅ README files được update
- ✅ Changelog được maintain

## Red Flags cần reject:
- ❌ Hardcoded strings thay vì localization
- ❌ Direct widget state mutation
- ❌ Unhandled exceptions
- ❌ Memory leaks (không dispose resources)
- ❌ Blocking UI thread với heavy operations
- ❌ Missing null checks
- ❌ Overly complex nested widgets
- ❌ Missing tests cho critical features

## Review Checklist:
1. Code compiles without warnings
2. Tests pass và coverage adequate
3. Performance không bị regression
4. Security vulnerabilities được address
5. UI/UX consistent với design system
6. Documentation được update
7. Breaking changes được document
