# Custom Lint Implementation Guide

## Overview

This document provides comprehensive guidelines for creating custom lint rules in this project using the `super_lint` package.

## File Structure Requirements

When creating a new custom lint rule, the following files must be created or modified:

### 1. Core Lint Implementation
- **Create lint rule file**: `super_lint/lib/src/rules/{lint_name}.dart`
- **Export the new rule**: Add to `super_lint/lib/src/index.dart`
- **Register the rule**: Add to `super_lint/lib/super_lint.dart`

### 2. Test Implementation
- **Create test file**: `super_lint/example/lib/{lint_name}_test.dart`
- **Alternative for complex tests**: Create folder `super_lint/example/lib/{lint_name}_test/` if a single file cannot test all scenarios

### 3. Configuration
- **Main config**: Declare the rule in `analysis_options.yaml`
- **Example config**: Declare with full options/parameters in `super_lint/example/analysis_options.yaml`

## Implementation Guidelines

### 1. Research Existing Patterns
- Search for similar existing lint rules in the project
- Study their setup and implementation patterns
- Follow the established code structure and naming conventions

### 2. Extensibility Requirements
- Design the lint rule to be easily extensible
- Add configurable options/parameters to make the rule flexible
- Use the `OptionsLintRule` base class for parameterized rules

### 3. Code Quality Standards
- **No compilation errors**: Code must compile successfully
- **No linter errors**: Must pass `make sl` without warnings
- **No deprecated code**: Avoid using deprecated APIs or patterns
- **Follow project conventions**: Use established patterns and naming

### 4. Test Coverage Requirements

Test files must include two distinct sections:

#### Section 1: Valid Cases (Should NOT be warned)
```dart
// THE FOLLOWING CASES SHOULD NOT BE WARNED
// Include examples of code that should NOT trigger the lint rule
```

#### Section 2: Invalid Cases (Should be warned)
```dart
// THE FOLLOWING CASES SHOULD BE WARNED
// Include examples of code that SHOULD trigger the lint rule
```

## Implementation Steps

### Step 1: Create the Lint Rule
```dart
// super_lint/lib/src/rules/{lint_name}.dart
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class YourLintRule extends DartLintRule {
  const YourLintRule() : super(code: _code);

  static const _code = LintCode(
    name: 'your_lint_rule',
    problemMessage: 'Your problem message here',
    correctionMessage: 'Your correction message here',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Implementation here
  }
}
```

### Step 2: Export the Rule
```dart
// super_lint/lib/src/index.dart
export 'rules/your_lint_rule.dart';
```

### Step 3: Register the Rule
```dart
// super_lint/lib/super_lint.dart
import 'src/rules/your_lint_rule.dart';

PluginBase createPlugin() => _SuperLintPlugin();

class _SuperLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    // ... existing rules
    const YourLintRule(),
  ];
}
```

### Step 4: Create Test File
```dart
// super_lint/example/lib/{lint_name}_test.dart

// THE FOLLOWING CASES SHOULD NOT BE WARNED
void validCase1() {
  // Valid code example
}

// THE FOLLOWING CASES SHOULD BE WARNED
void invalidCase1() {
  // Invalid code that should trigger the lint
}
```

### Step 5: Configure Analysis Options
```yaml
# analysis_options.yaml
custom_lint:
  rules:
    - your_lint_rule

# super_lint/example/analysis_options.yaml
custom_lint:
  rules:
    - your_lint_rule:
        option1: value1
        option2: value2
```

## Best Practices

### 1. Naming Conventions
- Use snake_case for lint rule names
- Use descriptive names that clearly indicate the rule's purpose
- Follow the pattern: `avoid_*`, `prefer_*`, `require_*`, etc.

### 2. Error Messages
- Write clear, actionable error messages
- Provide specific correction guidance
- Include examples in the correction message when helpful

### 3. Performance Considerations
- Avoid expensive operations in the lint rule
- Use appropriate visitor patterns for AST traversal
- Cache expensive computations when possible

### 4. Documentation
- Document the rule's purpose and behavior
- Provide examples of both valid and invalid code
- Explain configuration options and their effects

## Validation Checklist

Before submitting a custom lint rule, ensure:

- [ ] All required files are created/modified
- [ ] Code compiles without errors
- [ ] `make sl` passes without warnings
- [ ] Test file includes both valid and invalid cases
- [ ] Configuration is properly set up in both analysis_options.yaml files
- [ ] Rule is properly exported and registered
- [ ] Error messages are clear and actionable
- [ ] No deprecated APIs are used
- [ ] Code follows project conventions