// ignore_for_file: prefer_single_widget_per_file
// ignore_for_file: avoid_dynamic, avoid_hard_coded_strings
// ignore_for_file: missing_log_in_catch_block
import 'dart:async';

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
Future<String> get token => Future.value('token');

Future<void> login() async {
  await Future<dynamic>.delayed(const Duration(milliseconds: 2000));
  print('login');
}

FutureOr<String> throwError() async {
  return Future.error('error');
}

FutureOr<String> getName() async {
  return Future(() => 'name');
}

FutureOr<int?> getAge() async {
  try {
    print('do something');

    return Future.value(3);
  } catch (e) {
    return null;
  }
}

class AsyncNotifier {
  Future<String> get token => Future.value('token');

  Future<void> login() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 2000));
    print('login');
  }

  FutureOr<String> getName() async {
    return Future(() => 'name');
  }

  FutureOr<int?> getAge() async {
    try {
      print('do something');

      return Future.value(3);
    } catch (e) {
      return null;
    }
  }

  FutureOr<int?> getError() async {
    try {
      print('do something');

      return Future.error('error');
    } catch (e) {
      return null;
    }
  }
}

