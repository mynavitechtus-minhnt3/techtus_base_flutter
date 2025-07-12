import '../../../../../index.dart';

abstract class LoadMoreParams {}

abstract class LoadMoreExecutor<T, P extends LoadMoreParams> {
  LoadMoreExecutor({
    this.initPage = Constant.initialPage,
    this.initOffset = 0,
    this.limit = Constant.itemsPerPage,
  })  : _output = LoadMoreOutput<T>(data: <T>[], page: initPage, offset: initOffset),
        _oldOutput = LoadMoreOutput<T>(data: <T>[], page: initPage, offset: initOffset);

  final int initPage;
  final int initOffset;
  final int limit;

  LoadMoreOutput<T> _output;
  LoadMoreOutput<T> _oldOutput;

  int get page => _output.page;
  int get offset => _output.offset;

  Future<PagedList<T>> action({
    required int page,
    required int limit,
    required P? params,
  });

  Future<LoadMoreOutput<T>> execute({
    required bool isInitialLoad,
    P? params,
  }) async {
    try {
      if (isInitialLoad) {
        _output = LoadMoreOutput<T>(data: <T>[], page: initPage, offset: initOffset);
      }
      final pagedList = await action(page: page, limit: limit, params: params);

      final newOutput = _oldOutput.copyWith(
        data: pagedList.data,
        otherData: pagedList.otherData,
        page: isInitialLoad
            ? initPage + (pagedList.data.isNotEmpty ? 1 : 0)
            : _oldOutput.page + (pagedList.data.isNotEmpty ? 1 : 0),
        offset: isInitialLoad
            ? (initOffset + pagedList.data.length)
            : _oldOutput.offset + pagedList.data.length,
        isLastPage: pagedList.isLastPage,
        isRefreshSuccess: isInitialLoad,
        total: pagedList.total ?? 0,
      );

      _output = newOutput;
      _oldOutput = newOutput;

      return newOutput;
      // ignore: missing_log_in_catch_block
    } catch (e) {
      Log.e('LoadMoreError: $e');
      _output = _oldOutput;

      throw e is AppException ? e : AppUncaughtException(rootException: e);
    }
  }
}
