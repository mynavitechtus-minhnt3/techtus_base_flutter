
class HomeViewModel extends BaseViewModel {
  void test() {
    final ref = Ref();
    // expect_lint: missing_run_catching
    ref.test();
  }
}

class BaseViewModel {
  Future<void> runCatching({
    required Future<void> Function() action,
    FutureOr<void> Function(Object? error)? onError,
    FutureOr<void> Function()? onInit,
    bool handleLoading = false,
    bool handleError = false,
  }) async {
    await action();
  }
}

class Ref {
  void test() {}
}

class DioApiClient {
  void test() {}
}
