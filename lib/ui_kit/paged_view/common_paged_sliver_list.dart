import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../index.dart';

class CommonPagedSliverList<T> extends StatelessWidget {
  const CommonPagedSliverList({
    required this.pagingController,
    required this.itemBuilder,
    this.animateTransitions = true,
    this.transitionDuration = Constant.listGridTransitionDuration,
    this.firstPageErrorIndicator,
    this.newPageErrorIndicator,
    this.firstPageProgressIndicator,
    this.newPageProgressIndicator,
    this.noItemsFoundIndicator,
    this.noMoreItemsIndicator,
    super.key,
    this.itemExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticIndexCallback,
    this.shrinkWrapFirstPageIndicators = false,
    this.separatorBuilder,
  });

  final CommonPagingController<T> pagingController;
  final Widget Function(
    BuildContext context,
    T item,
    int index,
  ) itemBuilder;
  final bool animateTransitions;
  final Duration transitionDuration;
  final Widget? firstPageErrorIndicator;
  final Widget? newPageErrorIndicator;
  final Widget? firstPageProgressIndicator;
  final Widget? newPageProgressIndicator;
  final Widget? noItemsFoundIndicator;
  final Widget? noMoreItemsIndicator;

  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final SemanticIndexCallback? semanticIndexCallback;
  final bool shrinkWrapFirstPageIndicators;
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  Widget build(BuildContext context) {
    final builderDelegate = PagedChildBuilderDelegate<T>(
      itemBuilder: itemBuilder,
      animateTransitions: animateTransitions,
      transitionDuration: transitionDuration,
      firstPageErrorIndicatorBuilder: (_) =>
          firstPageErrorIndicator ?? const CommonFirstPageErrorIndicator(),
      newPageErrorIndicatorBuilder: (_) =>
          newPageErrorIndicator ?? const CommonNewPageErrorIndicator(),
      firstPageProgressIndicatorBuilder: (_) =>
          firstPageProgressIndicator ?? const CommonFirstPageProgressIndicator(),
      newPageProgressIndicatorBuilder: (_) =>
          newPageProgressIndicator ?? const CommonNewPageProgressIndicator(),
      noItemsFoundIndicatorBuilder: (_) =>
          noItemsFoundIndicator ?? const CommonNoItemsFoundIndicator(),
      noMoreItemsIndicatorBuilder: (_) =>
          noMoreItemsIndicator ?? const CommonNoMoreItemsIndicator(),
    );

    PagedSliverList<int, T> pagedView({
      required PagingState<int, T> state,
      required void Function() fetchNextPage,
    }) =>
        separatorBuilder != null
            ? PagedSliverList.separated(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: builderDelegate,
                separatorBuilder: separatorBuilder!,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                addRepaintBoundaries: addRepaintBoundaries,
                addSemanticIndexes: addSemanticIndexes,
                itemExtent: itemExtent,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                semanticIndexCallback: semanticIndexCallback,
              )
            : PagedSliverList<int, T>(
                state: state,
                fetchNextPage: fetchNextPage,
                builderDelegate: builderDelegate,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                addRepaintBoundaries: addRepaintBoundaries,
                addSemanticIndexes: addSemanticIndexes,
                itemExtent: itemExtent,
                shrinkWrapFirstPageIndicators: shrinkWrapFirstPageIndicators,
                semanticIndexCallback: semanticIndexCallback,
              );

    return PagingListener(
      controller: pagingController.pagingController,
      builder: (context, state, fetchNextPage) {
        return pagedView(
          state: state,
          fetchNextPage: fetchNextPage,
        );
      },
    );
  }
}
