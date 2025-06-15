// expect_lint: avoid_unnecessary_async_function
Future<void> log() async {
  Future<dynamic>.delayed(const Duration(milliseconds: 2000));
  print('log');
}

// expect_lint: avoid_unnecessary_async_function
Future<void> get user async => login();

// expect_lint: avoid_unnecessary_async_function
FutureOr<String> get user2 async => Future.value('');

// expect_lint: avoid_unnecessary_async_function
Future<String> get user3 async => Future.value('');

// expect_lint: avoid_unnecessary_async_function
FutureOr<String> get name async => 'name';

// expect_lint: avoid_unnecessary_async_function
Future<String> get name2 async => 'name';

// expect_lint: avoid_unnecessary_async_function
FutureOr<String> get age async {
  return 'name';
}

// expect_lint: avoid_unnecessary_async_function
Future<void> logout() async {
  print('logout');
}

// expect_lint: avoid_unnecessary_async_function
FutureOr<String> getFullName() async {
  return 'name';
}

// expect_lint: avoid_unnecessary_async_function
FutureOr<String> get lastname async {
  return 'name';
}

// expect_lint: avoid_unnecessary_async_function
FutureOr<int?> getUserAge() async {
  try {
    print('do something');

    return 3;
  } catch (e) {
    return null;
  }
}

class Notifier {
  // expect_lint: avoid_unnecessary_async_function
  FutureOr<String> getName() async {
    unawaited(Future<dynamic>.delayed(const Duration(milliseconds: 2000)));

    return 'name';
  }

  // expect_lint: avoid_unnecessary_async_function
  Future<void> hello() async {
    Future(() => print('hello'));

    print('login');
  }

  // expect_lint: avoid_unnecessary_async_function
  Future<String> get surname async => 'name';

  // expect_lint: avoid_unnecessary_async_function
  FutureOr<String> get fullname async {
    return 'name';
  }

  // expect_lint: avoid_unnecessary_async_function
  Future<void> get user async => login();

  // expect_lint: avoid_unnecessary_async_function
  FutureOr<String> get user2 async => Future.value('');

  // expect_lint: avoid_unnecessary_async_function
  Future<String> get user3 async => Future.value('');

  // expect_lint: avoid_unnecessary_async_function
  FutureOr<String> get name async => 'name';

  // expect_lint: avoid_unnecessary_async_function
  Future<String> get name2 async => 'name';
}
