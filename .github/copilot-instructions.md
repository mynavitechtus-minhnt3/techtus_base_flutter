## Essential Commands
```bash
# Get packages for all modules
make pg

# Run build_runner for code generation
make fb

# Run golden tests
flutter test [test_path] --tags=golden

# Update golden test files
flutter test [test_path] --update-goldens --tags=golden

# Format code
make fm

## Check lint
make sl

## Generate assets (images, fonts, etc.)
make ga

## Generate localization files
make ln
```

---

## Code Review Guidelines

When performing a code review, respond in English.

## Riverpod State Management Rules

When performing a code review, follow best practices in [Riverpod documentation](https://riverpod.dev/docs/root/do_dont).

When performing a code review, verify that `WidgetRef.listen` is safely used inside the build method of a widget, as this is the intended usage. For listening to providers outside of build (such as `State.initState`), ensure `WidgetRef.listenManual` is used instead.

When performing a code review, ensure `Ref.read` is not used as a means to "optimize" code by avoiding `Ref.watch`. This makes code brittle, as changes in provider behavior could cause UI to be out of sync with the provider's state. Either use `Ref.watch` (as the performance difference is negligible) or use `select`.

When performing a code review, verify that providers are exclusively top-level final variables.

When performing a code review, ensure all ViewModel providers use `autoDispose`.

When performing a code review, verify that detail screens use family providers.

When performing a code review, check if `ref.watch` is only used where rebuild is needed. Flag if used in callbacks.

When performing a code review, check if `ref.read` is used correctly. Flag if used inside build method where watch is needed.

When performing a code review, check if `ref.listen` is only used for side effects. Flag if used for rendering UI.

## Documentation Rules

When performing a code review, verify that when code changes, file renames, or restructuring occurs, the `copilot-instructions.md` file and files in the `docs` folder are considered for corresponding updates.

When performing a code review, ensure that when CI/CD versions change, the `README.md` file is updated accordingly and vice versa.

## Pull Request Rules

When performing a code review, ensure the following sections are filled in the PR: `## Issue`, `## What was done?`, `## Edit common function, common class, arb value used in many places? (Yes&What?/No)`, and `## Checklist`.

When performing a code review, ensure UI implementation tasks include `## Screenshots (compare actual vs expected)`.

When performing a code review, verify that the `Assignees` section of the PR is filled.

When performing a code review, ensure branch names match the `## Issue` section. For example, issue #123 should have branch name `xxx/123`.

When performing a code review, verify the accuracy of the `## What was done?` section based on the PR's code changes.

When performing a code review, verify the accuracy of the `## Edit common function, common class, arb value used in many places? (Yes&What?/No)` section based on the PR's code changes.

## Testing Rules

When performing a code review, ensure the following functions have Unit Tests:
- Data validation functions (e.g., AppUtil)
- Common functions used across multiple screens (e.g., SharedViewModel, SharedProvider)  
- Functions with complex logic: nested if-else, loops, multiple operators (e.g., long private functions in ViewModels)

When performing a code review, ensure Unit Tests and Golden Tests cover all edge cases and hidden cases.

## Golden Image Rules

When performing a code review, ensure that all golden images in the goldens/ folder which share the same names as images in the design/ folder are identical and contain no UI defects. For example: `goldens/i1_S-6-4-10.png` must match `design/i1_S-6-4-10.png`. Compare the following aspects:
- Font size of text
- Text color
- Component width and height
- Component padding and margin
- Component alignment
- Component background color
- Component border radius
- Spacing between components
- Component color
- Text content

When performing a code review, ensure all golden images especially the images in text_scaling follow these rules:
- No overflow errors
- No text cut-offs
- The title should fit on one line (or follow the design specifications) and should not wrap or drop down

## Coding Rules

When performing a code review, follow our internal security checklist in [docs/security_checklist.md](../docs/technical/security_checklist.md).

When performing a code review, follow our naming convention in [docs/naming_convention.md](../docs/technical/naming_convention.md).

When performing a code review, ensure test file organization follows the structure defined in [docs/architecture.md](../docs/technical/architecture.md).

When performing a code review, ensure functions with complex logic have explanatory comments.

When performing a code review, ensure `// ignore:` comments have additional explanatory comments above them.

When performing a code review, ensure dummy data or empty actions are marked as TODO.

When performing a code review, verify that dimensions use the `.rps` function.

When performing a code review, verify that secrets like `API_KEY` are hidden and not committed to the repository.

When performing a code review, ensure edit/create screens show a confirmation popup when navigating back.

When performing a code review, ensure UI classes like `BuildContext`, `Color`, `TextEditingController`, `TabController` are not used in ViewModel classes, as this makes unit testing difficult.

When performing a code review, ensure `BuildContext` is not used in model classes.

When performing a code review, verify that similar UI or logic is shared to avoid duplicate code.

When performing a code review, ensure calls to `ref.appPreferences`, `ref.appApiService`, `ref.appDatabase` in ViewModel classes are wrapped in `runCatching`.

When performing a code review, ensure UI widgets are kept in a single file when breaking down components, rather than splitting across multiple files.

When performing a code review, verify that common widgets are placed in the `lib/ui/component` folder.

When performing a code review, ensure each feature in the `lib/ui/page` folder contains only 3 files: view_model, state, and page. No other files should be included.

When performing a code review, verify that no business logic is implemented in UI files. UI files should not use `appPreferences`, `appApiService`, or `appDatabase`.

When performing a code review, focus on readability, testability and maintainability.

When performing a code review, avoid code smells, nested conditionals, duplicate code, magic numbers, hardcoded values, and unused code.