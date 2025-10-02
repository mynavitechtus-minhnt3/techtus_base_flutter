// ignore_for_file: missing_golden_test
import 'dart:async';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../index.dart';

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
    if (pagingController.value.pages == null) return;
    final newPages = pagingController.value.pages!.map((page) => List<T>.from(page)).toList();
    newPages[0].insert(index, item);
    pagingController.value = pagingController.value.copyWith(pages: newPages);
  }

  void insertAllItemsAt({
    required int index,
    required List<T> items,
  }) {
    if (pagingController.value.pages == null) return;
    final newPages = pagingController.value.pages!.map((page) => List<T>.from(page)).toList();
    newPages[0].insertAll(index, items);
    pagingController.value = pagingController.value.copyWith(pages: newPages);
  }

  void updateItemAt({
    required int index,
    required T item,
  }) {
    if (pagingController.value.pages == null) return;
    final newPages = pagingController.value.pages!.map((page) => List<T>.from(page)).toList();
    newPages[0][index] = item;
    pagingController.value = pagingController.value.copyWith(pages: newPages);
  }

  void removeItemAt({
    required int index,
  }) {
    if (pagingController.value.pages == null) return;
    final newPages = pagingController.value.pages!.map((page) => List<T>.from(page)).toList();
    newPages[0].removeAt(index);
    pagingController.value = pagingController.value.copyWith(pages: newPages);
  }

  void removeRange({
    required int start,
    required int end,
  }) {
    if (pagingController.value.pages == null) return;
    final newPages = pagingController.value.pages!.map((page) => List<T>.from(page)).toList();
    newPages[0].removeRange(start, end);
    pagingController.value = pagingController.value.copyWith(pages: newPages);
  }

  void clear() {
    if (pagingController.value.pages == null) return;
    final newPages = pagingController.value.pages!.map((page) => List<T>.from(page)).toList();
    newPages[0].clear();
    pagingController.value = pagingController.value.copyWith(pages: newPages);
  }

  void dispose() {
    pagingController.dispose();
  }
}
