# Flutter Development Instructions

## Code Generation Guidelines cho TechTus Flutter Project

### 1. Project Architecture
- Tuân thủ **Clean Architecture** pattern
- **Data Layer**: API clients, databases, preferences
- **Domain Layer**: Models, repositories, use cases  
- **Presentation Layer**: UI, StateNotifiers, providers

### 2. State Management với Riverpod
- Sử dụng `@riverpod` annotation cho providers
- StateNotifier cho complex state logic
- Provider cho simple dependencies
- Proper state disposal và cleanup

### 3. Dependency Injection
- Sử dụng `injectable` package
- `@LazySingleton()` cho services
- `@Injectable()` cho regular dependencies
- Register trong `di.dart`

### 4. Model Classes
- Sử dụng `Freezed` cho data classes
- Implement `fromJson`/`toJson`
- JsonAnnotation cho API mapping
- Proper nullable types

### 5. API Integration
- Inherit từ base API clients
- Proper error handling với Result pattern
- Type-safe request/response
- Implement retry logic

### 6. UI Development
- Extend `BasePage` cho pages
- Sử dụng design system components
- Implement responsive design
- Proper loading và error states

### 7. Navigation
- Sử dụng GoRouter
- Define routes trong `app_router.dart`
- Implement route guards
- Type-safe navigation

### 8. Testing Requirements
- Unit tests cho business logic
- StateNotifier tests với `stateNotifierTest`
- Golden tests cho UI components
- Integration tests cho critical flows

### 9. Code Style
- Follow Dart conventions
- Use meaningful variable names
- Proper documentation comments
- Consistent formatting

### 10. Performance
- Use `const` constructors
- Optimize widget rebuilds
- Proper list rendering
- Image optimization
