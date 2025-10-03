import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../index.dart';

final loadMoreExampleViewModelProvider =
    StateNotifierProvider.autoDispose<LoadMoreExampleViewModel, CommonState<LoadMoreExampleState>>(
  (ref) => LoadMoreExampleViewModel(ref),
);

class LoadMoreExampleViewModel extends BaseViewModel<LoadMoreExampleState> {
  LoadMoreExampleViewModel(
    this._ref,
  ) : super(CommonState(data: LoadMoreExampleState()));

  final Ref _ref;

  Future<void> fetchUsers({
    required bool isInitialLoad,
  }) {
    return _getUsers(isInitialLoad: isInitialLoad);
  }

  Future<void> _getUsers({
    required bool isInitialLoad,
  }) async {
    return runCatching(
      action: () async {
        data = data.copyWith(isShimmerLoading: isInitialLoad, loadUsersException: null);
        final output = await _ref.loadMoreUsersExecutor.execute(
          isInitialLoad: isInitialLoad,
        );
        data = data.copyWith(users: output);
      },
      doOnError: (e) async {
        data = data.copyWith(loadUsersException: e);
      },
      doOnSuccessOrError: () async {
        data = data.copyWith(isShimmerLoading: false);
      },
      handleLoading: false,
      handleErrorWhen: (_) => false,
    );
  }
}
