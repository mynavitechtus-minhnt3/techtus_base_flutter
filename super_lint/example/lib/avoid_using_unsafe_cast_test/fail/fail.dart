
Future<void> test() async {
  // expect_lint: avoid_using_unsafe_cast
  print('3' as int?);
  // expect_lint: avoid_using_unsafe_cast
  if ('e' as num == 3) {}
  final a = '';
  if (a is int) {
    // expect_lint: avoid_using_unsafe_cast
    print(a as int);
  }
  dynamic b = '3';
  // expect_lint: avoid_using_unsafe_cast
  print(b as int);

  // expect_lint: avoid_using_unsafe_cast
  await number as int;

  // expect_lint: avoid_using_unsafe_cast
  (await number) as int;

  // expect_lint: avoid_using_unsafe_cast
  await unit as int;

  // expect_lint: avoid_using_unsafe_cast
  (await unit) as int;
}

Future<dynamic> get unit => Future.value(3);
Future<num> get number => Future.value(3);

extension ObjectUtils<T> on T? {
  R? safeCast<R>() {
    final that = this;
    if (that is R) {
      return that;
    }

    return null;
  }
}

T? safeCast<T>(dynamic value) {
  if (value is T) {
    return value;
  }

  return null;
}
