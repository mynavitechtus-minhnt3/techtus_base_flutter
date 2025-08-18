---
mode: 'agent'
model: 'Claude Sonnet 4'
description: 'Refactor code theo best practices của Flutter/Dart'
---

# Refactor Flutter/Dart Code

Refactor code để improve quality, performance và maintainability.

## Loại refactoring:

### 1. Extract Method/Class
- Break down large functions
- Separate concerns
- Improve readability
- Reduce duplication

### 2. State Management Refactoring
- Convert StatefulWidget to StateNotifier
- Optimize provider usage
- Reduce unnecessary rebuilds
- Improve state structure

### 3. UI Refactoring
- Extract reusable widgets
- Implement proper widget composition
- Optimize widget tree
- Improve responsive design

### 4. API/Data Layer Refactoring
- Implement Result pattern
- Add proper error handling
- Optimize network calls
- Improve data models

## Refactoring Checklist:

### Performance
- ✅ Remove unnecessary rebuilds
- ✅ Optimize list rendering
- ✅ Cache expensive computations
- ✅ Proper async/await usage

### Code Quality
- ✅ Remove code duplication
- ✅ Improve naming conventions
- ✅ Add missing documentation
- ✅ Fix linting warnings

### Architecture
- ✅ Enforce layer boundaries
- ✅ Improve dependency injection
- ✅ Enhance error handling
- ✅ Optimize state management

### Testing
- ✅ Add missing tests
- ✅ Improve test coverage
- ✅ Fix flaky tests
- ✅ Add golden tests

## Before Refactoring:
1. Ensure all tests pass
2. Create backup branch
3. Document current behavior
4. Plan refactoring steps

## After Refactoring:
1. Run all tests
2. Check performance metrics
3. Verify UI behavior
4. Update documentation

Hãy cung cấp code cần refactor và mục tiêu refactoring để tôi đưa ra plan cụ thể.
