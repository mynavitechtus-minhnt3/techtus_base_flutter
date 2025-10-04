# UI and State Management Instructions

## Overview

This document provides comprehensive guidelines for implementing UI components and state management in the project using the MVVM architecture with Riverpod.

## Basic Implementation Flow

### 1. Creating a New Page

Follow this step-by-step process when creating a new page:

#### Step 1: Define the State
```dart
// lib/ui/page/feature/view_model/feature_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/index.dart';

part 'feature_state.freezed.dart';

@freezed
class FeatureState extends BaseState with _$FeatureState {
  const factory FeatureState({
    @Default([]) List<DataModel> items,
    @Default('') String searchQuery,
    DataModel? selectedItem,
  }) = _FeatureState;
}
```

#### Step 2: Create the ViewModel
```dart
// lib/ui/page/feature/view_model/feature_view_model.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/index.dart';

import '../../../../index.dart';

final featureViewModelProvider = 
    StateNotifierProvider.autoDispose<FeatureViewModel, CommonState<FeatureState>>(
  (ref) => FeatureViewModel(ref),
);

class FeatureViewModel extends BaseViewModel<FeatureState> {
  FeatureViewModel(this._ref) : super(CommonState(data: FeatureState()));

  final Ref _ref;

  Future<void> loadData() async {
    await runCatching(
      action: () async {
        final apiService = _ref.read(appApiServiceProvider);
        final result = await apiService.getFeatureData();
        data = data.copyWith(items: result);
      },
    );
  }

  void updateSearchQuery(String query) {
    data = data.copyWith(searchQuery: query);
  }

  Future<void> selectItem(DataModel item) async {
    await runCatching(
      action: () async {
        data = data.copyWith(selectedItem: item);
        // Additional logic
      },
    );
  }
}
```

#### Step 3: Create the Page
```dart
// lib/ui/page/feature/feature_page.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/index.dart';

import '../../../index.dart';

class FeaturePage extends BasePage<FeatureState, 
    StateNotifierProvider<FeatureViewModel, CommonState<FeatureState>>> {
  const FeaturePage({super.key});

  @override
  StateNotifierProvider<FeatureViewModel, CommonState<FeatureState>> 
      get provider => featureViewModelProvider;

  @override
  ScreenViewEvent get screenViewEvent => ScreenViewEvent(
    screenName: AppScreenName.feature, // Define in your app's screen_name.dart
  );

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);

    return CommonScaffold(
      appBar: CommonAppBar.back(text: l10n.featureTitle),
      body: state.data.items.isEmpty
          ? const EmptyStateWidget()
          : ListView.builder(
              itemCount: state.data.items.length,
              itemBuilder: (context, index) {
                final item = state.data.items[index];
                return FeatureItemCard(
                  item: item,
                  onTap: () => ref.read(provider.notifier).selectItem(item),
                );
              },
            ),
    );
  }
}
```

### 2. Creating a New Popup (Dialog/BottomSheet)

#### Dialog Example
```dart
// lib/ui/popup/confirmation_dialog.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/index.dart';

import '../../index.dart';

class ConfirmationDialog extends HookConsumerWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
  });

  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonDialog(
      title: title,
      content: CommonText(message),
      actions: [
        CommonButton.text(
          text: cancelText ?? l10n.cancel,
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
        ),
        CommonButton.primary(
          text: confirmText ?? l10n.confirm,
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}
```

#### BottomSheet Example
```dart
// lib/ui/popup/feature_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/index.dart';

import '../../index.dart';

class FeatureBottomSheet extends HookConsumerWidget {
  const FeatureBottomSheet({
    super.key,
    required this.options,
    this.onOptionSelected,
  });

  final List<OptionModel> options;
  final Function(OptionModel)? onOptionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonBottomSheet(
      title: l10n.selectOption,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) => 
          CommonListTile(
            title: option.title,
            onTap: () {
              onOptionSelected?.call(option);
              Navigator.of(context).pop(option);
            },
          ),
        ).toList(),
      ),
    );
  }

  static Future<OptionModel?> show(
    BuildContext context, {
    required List<OptionModel> options,
    Function(OptionModel)? onOptionSelected,
  }) {
    return showModalBottomSheet<OptionModel>(
      context: context,
      builder: (context) => FeatureBottomSheet(
        options: options,
        onOptionSelected: onOptionSelected,
      ),
    );
  }
}
```

### 3. Creating a Shared Component

```dart
// lib/ui/component/feature_card.dart
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared/index.dart';

import '../../index.dart';

class FeatureCard extends HookConsumerWidget {
  const FeatureCard({
    super.key,
    required this.data,
    this.onTap,
    this.showBadge = false,
  });

  final FeatureModel data;
  final VoidCallback? onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CommonContainer(
      margin: EdgeInsets.symmetric(horizontal: 16.rps, vertical: 8.rps),
      padding: EdgeInsets.all(16.rps),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(12.rps),
        border: Border.all(color: color.outline),
      ),
      child: CommonInkWell(
        onTap: onTap,
        child: Row(
          children: [
            if (data.imageUrl.isNotNullAndNotEmpty)
              CommonImage.network(
                data.imageUrl!,
                width: 48.rps,
                height: 48.rps,
                borderRadius: BorderRadius.circular(8.rps),
              ),
            SizedBox(width: 12.rps),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    data.title,
                    style: style().titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (data.description.isNotNullAndNotEmpty) ...[
                    SizedBox(height: 4.rps),
                    CommonText(
                      data.description!,
                      style: style().bodySmall.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (showBadge)
              CommonContainer(
                padding: EdgeInsets.symmetric(horizontal: 8.rps, vertical: 4.rps),
                decoration: BoxDecoration(
                  color: color.primary,
                  borderRadius: BorderRadius.circular(12.rps),
                ),
                child: CommonText(
                  'NEW',
                  style: style().labelSmall.copyWith(
                    color: color.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Rules

### 1. Always Use Common Components
```dart
// ✅ GOOD
CommonScaffold(
  appBar: CommonAppBar.back(),
  body: CommonContainer(
    child: CommonText('Hello'),
  ),
)

// ❌ BAD
Scaffold(
  appBar: AppBar(),
  body: Container(
    child: Text('Hello'),
  ),
)
```

### 2. Component Inheritance Hierarchy
- Page must extend BasePage
- Component must extend StatelessWidget/HookConsumerWidget

### 3. Folder Structure
- Page must be placed in the `lib/ui/page` folder
- Component must be placed in the `lib/ui/component` folder
- Popup must be placed in the `lib/ui/popup` folder

### 4. Naming Conventions

#### Classes
```dart
// Pages
{Feature}Page extends BasePage
{Feature}State extends BaseState  
{Feature}ViewModel extends BaseViewModel

// Components  
Common{ComponentName} extends StatelessWidget/ConsumerWidget
{Feature}{ComponentName} extends HookConsumerWidget

// Popups
{Feature}Dialog extends HookConsumerWidget
{Feature}BottomSheet extends HookConsumerWidget
```

#### Variables and Functions
```dart
// Variables - camelCase
final String userName;
final List<DataModel> dataList;
final bool isLoading;

// Functions - camelCase with descriptive names
void updateUserProfile() {}
Future<void> loadDataFromApi() {}
bool validateEmailFormat(String email) {}

// Private members - underscore prefix
String _privateVariable;
void _privateMethod() {}

// Constants - SCREAMING_SNAKE_CASE
static const int MAX_RETRY_COUNT = 3;
static const String DEFAULT_ERROR_MESSAGE = 'Something went wrong';
```

#### Log Events
```dart
ScreenViewEvent(screenName: ScreenName.userProfilePage)

// Normal events - descriptive action names
NormalEvent(
  eventName: 'button_tap',
  screenName: ScreenName.userProfilePage,
  parameter: ButtonTapParameter({'button_name': 'save_profile'}),
)
```

### 5. Design System Rules

#### 1. Dimensions - Always use .rps extension
```dart
// ✅ GOOD - Responsive sizing
Container(
  width: 100.rps,
  height: 50.rps,
  margin: EdgeInsets.all(16.rps),
  padding: EdgeInsets.symmetric(horizontal: 12.rps, vertical: 8.rps),
)

// ❌ BAD - Fixed sizing
Container(
  width: 100,
  height: 50,
  margin: EdgeInsets.all(16),
)
```

#### 2. Colors - Use color.*
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Container(
    color: color.surface,
    child: CommonText(
      'Hello',
      style: TextStyle(color: color.onSurface),
    ),
  );
}
```

#### 3. Text Styles - Use style() helper
```dart
CommonText(
  'Title',
  style: style(
    fontSize: 24.rps,
    fontWeight: FontWeight.w600,
    color: color.primary,
  ),
)

CommonText(
  'Body text',
  style: style(
    fontSize: 16.rps,
    fontWeight: FontWeight.w400,
    color: color.primary,
  ),
)
```

#### 4. Strings - Use l10n for localization
```dart
// ✅ GOOD - Localized strings
CommonText(l10n.welcomeMessage)
CommonAppBar.back(text: l10n.profileTitle)

// ❌ BAD - Hardcoded strings
CommonText('Welcome!')
CommonAppBar.back(text: 'Profile')
```

#### 5. Dummy Data - Use realistic values
```dart
// ✅ GOOD - Realistic dummy data
const mockUser = UserModel(
  id: 12345,
  name: '田中太郎',
  email: 'tanaka@example.com',
  phoneNumber: '090-1234-5678',
  birthDate: '1990-05-15',
  address: '東京都渋谷区神南1-1-1',
);

// ❌ BAD - Unrealistic dummy data
const mockUser = UserModel(
  id: 1,
  name: 'Test User',
  email: 'test@test.com',
);
```

### 6. Other Rules
- Calls to `ref.appPreferences`, `ref.appApiService`, `ref.appDatabase` in ViewModel classes are wrapped in `runCatching`.
- UI widgets are kept in a single file as private classes when breaking down components, rather than splitting across multiple files.
- Each feature in the `lib/ui/page` folder contains only 3 files: view_model, state, and page. No other files should be included.
- No business logic is implemented in UI files. UI files should not use `appPreferences`, `appApiService`, or `appDatabase`.

## Analytics and Logging

### 1. Screen View Events
Screen view events are automatically logged when using BasePage:

```dart
class FeaturePage extends BasePage<FeatureState, ...> {
  @override
  ScreenViewEvent get screenViewEvent => ScreenViewEvent(
    screenName: AppScreenName.feature, // Define in your app's screen_name.dart
  );
}
```

## runCatching Parameters Guide

The `runCatching` method in BaseViewModel provides comprehensive error handling with multiple parameters for different use cases:

### Method Signature
```dart
Future<void> runCatching({
  required Future<void> Function() action,
  Future<void> Function()? doOnRetry,
  Future<void> Function(AppException)? doOnError,
  Future<void> Function()? doOnSuccessOrError,
  Future<void> Function()? doOnCompleted,
  bool handleLoading = true,
  FutureOr<bool> Function(AppException)? handleRetryWhen,
  FutureOr<bool> Function(AppException)? handleErrorWhen,
  int? maxRetries = 2,
  String? actionName,
})
```

### Core Parameters

#### `action` (required)
**Use Case**: The main operation to execute
```dart
await runCatching(
  action: () async {
    final data = await _ref.read(appApiServiceProvider).getUserData();
    this.data = this.data.copyWith(user: data);
  },
);
```

#### `handleLoading` (default: true)
**Use Case**: Control whether to show global loading indicator
```dart
// Show loading indicator (default behavior)
await runCatching(
  action: () async { /* API call */ },
  handleLoading: true, // Shows loading spinner
);

// Background operation without loading
await runCatching(
  action: () async { /* background sync */ },
  handleLoading: false, // No loading indicator
);
```

#### `actionName`
**Use Case**: Track specific action loading states for UI
```dart
// Delete specific item with loading state
await runCatching(
  action: () async {
    await apiService.deleteItem(itemId);
  },
  actionName: 'delete_$itemId',
);

// UI can check specific loading state
bool isDeleting(String itemId) => state.isDoingAction('delete_$itemId');

// Example in UI
CommonButton.primary(
  text: 'Delete',
  isLoading: state.isDoingAction('delete_${item.id}'),
  onPressed: () => viewModel.deleteItem(item.id),
)
```

### Callback Parameters

#### `doOnError`
**Use Case**: Custom error handling per operation
```dart
await runCatching(
  action: () async {
    await apiService.uploadImage(imageFile);
  },
  doOnError: (exception) async {
    if (exception is NetworkException) {
      _showToast('Network error. Please check your connection.');
    } else if (exception is FileSizeException) {
      _showToast('File too large. Please select a smaller image.');
    }
  },
);
```

#### `doOnRetry`
**Use Case**: Prepare for retry operation
```dart
await runCatching(
  action: () async {
    await apiService.syncData();
  },
  doOnRetry: () async {
    await _clearCache(); // Clear cached data before retry
    _showToast('Retrying...');
  },
);
```

#### `maxRetries` (default: 2)
**Use Case**: Control automatic retry attempts
```dart
// Critical operation with more retries
await runCatching(
  action: () async {
    await apiService.saveUserProfile(profile);
  },
  maxRetries: 5, // Retry up to 5 times
);

// One-time operation with no retries
await runCatching(
  action: () async {
    await apiService.deleteAccount();
  },
  maxRetries: 0, // No automatic retries
);
```

## CommonState Properties Guide

The `CommonState` class wraps your specific state with common functionality:

### Structure
```dart
class CommonState<T extends BaseState> {
  const CommonState({
    required T data,                    // Your specific state data
    AppException? appException,         // Current exception (if any)
    bool isLoading = false,            // Global loading state
    bool isFirstLoading = false,       // First time loading state
    Map<String, bool> doingAction = {}, // Specific action loading states
  });
  
  bool isDoingAction(String actionName); // Check if specific action is running
}
```

### Properties Explained

#### `data` (required)
**Use Case**: Your specific feature state
```dart
// In ViewModel
class UserProfileState extends BaseState {
  const UserProfileState({
    this.user,
    this.isEditing = false,
    this.validationErrors = const {},
  });
  
  final UserModel? user;
  final bool isEditing;
  final Map<String, String> validationErrors;
}

// Access in UI
final userState = ref.watch(userProfileProvider);
final user = userState.data.user; // Access your specific data
final isEditing = userState.data.isEditing;
```

#### `isLoading`
**Use Case**: Global loading state for the entire page
```dart
// UI shows different content based on loading state
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(provider);
  
  if (state.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  
  return YourContent();
}
```

#### `isFirstLoading`
**Use Case**: Different UI for initial load vs refresh
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(provider);
  
  if (state.isFirstLoading) {
    return const SkeletonLoader(); // Full-screen loader for first time
  }
  
  return RefreshIndicator(
    onRefresh: () => viewModel.refreshData(),
    child: ListView(
      children: [
        if (state.isLoading) const LinearProgressIndicator(), // Progress bar for refresh
        ...buildContentList(state.data),
      ],
    ),
  );
}
```

#### `doingAction` Map & `isDoingAction(String actionName)`
**Use Case**: Track multiple simultaneous action states
```dart
// ViewModel - Multiple actions
Future<void> likePost(String postId) async {
  await runCatching(
    action: () async {
      await apiService.likePost(postId);
    },
    actionName: 'like_$postId',
  );
}

// UI - Different loading states for each action, avoid multiple actions at the same time
Widget buildPostActions(PostModel post, WidgetRef ref) {
  final state = ref.watch(postsProvider);
  
  return Row(
    children: [
      CommonButton.icon(
        icon: Icons.favorite,
        isLoading: state.isDoingAction('like_${post.id}'),
        onPressed: () => ref.read(postsProvider.notifier).likePost(post.id),
      ),
      CommonButton.icon(
        icon: Icons.delete,
        isLoading: state.isDoingAction('delete_${post.id}'),
        onPressed: () => ref.read(postsProvider.notifier).deletePost(post.id),
      ),
    ],
  );
}
```
