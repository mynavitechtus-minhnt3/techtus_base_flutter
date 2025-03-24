import 'dart:async';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../index.dart';

class CommonPagingController<T> {
  CommonPagingController({
    required this.fetchPage,
    this.initialPageState,
  }) {
    _init();
  }

  final PagingState<int, T>? initialPageState;
  final FutureOr<List<T>> Function(int, bool) fetchPage;

  late PagingController<int, T> _pagingController;

  PagingController<int, T> get pagingController => _pagingController;

  // call when error
  set error(AppException? appException) {
    _pagingController.value = _pagingController.value.copyWith(
      error: appException,
    );
  }

  void _init() {
    _pagingController = PagingController<int, T>(
      value: initialPageState,
      getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
      fetchPage: (pageKey) {
        final isInitialLoad = pageKey == Constant.initialPage;
        return fetchPage(
          pageKey,
          isInitialLoad,
        );
      },
    );
  }

  void refresh() {
    _pagingController.refresh();
  }

  void insertItemAt({
    required int index,
    required T item,
  }) {
    _pagingController.items?.insert(index, item);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void insertAllItemsAt({
    required int index,
    required Iterable<T> items,
  }) {
    pagingController.items?.insertAll(index, items);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void updateItemAt({
    required int index,
    required T newItem,
  }) {
    pagingController.items?[index] = newItem;
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void removeItemAt(int index) {
    pagingController.items?.removeAt(index);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void removeRange({
    required int start,
    required int end,
  }) {
    pagingController.items?.removeRange(start, end);
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void clear({
    required int start,
    required int end,
  }) {
    pagingController.items?.clear();
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    pagingController.notifyListeners();
  }

  void dispose() {
    pagingController.dispose();
  }
}
