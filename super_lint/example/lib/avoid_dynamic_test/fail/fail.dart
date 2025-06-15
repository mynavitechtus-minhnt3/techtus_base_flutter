
// expect_lint: avoid_dynamic
dynamic thing = 'text';

// expect_lint: avoid_dynamic
void log(dynamic something) {
  // expect_lint: avoid_dynamic
  Future<dynamic>.delayed(const Duration(seconds: 1), () {
    print(something);
  });
}

// expect_lint: avoid_dynamic
dynamic getThing() {
  return 'text';
}

// expect_lint: avoid_dynamic
typedef MyFunction = void Function(dynamic a, dynamic b);

// expect_lint: avoid_dynamic
List<dynamic> list = [1, 2, 3];

// expect_lint: avoid_dynamic
Set<dynamic> set = {'a', 'b', 'c'};

// expect_lint: avoid_dynamic
final listLiteral = <dynamic>[1, 2, 3];
// expect_lint: avoid_dynamic
final setLiteral = <dynamic>{'a', 'b', 'c'};
