// ignore_for_file: prefer_single_widget_per_file
import 'dart:async';
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

class SearchViewModel extends BaseViewModel {
  void test() {
    DioApiClient().test();
  }

  void test2() {
    runCatching(
      action: () async {
        final ref = Ref();
        ref.test();
      },
    );
  }

  void test3() {
    final ref = Ref();
    ref.test();
  }

  void test4() {
    runCatching(
      action: () async {
        test3();
      },
    );
  }
}

class SearchPage {
  void test() {
    final ref = Ref();
    ref.test();
  }
}

