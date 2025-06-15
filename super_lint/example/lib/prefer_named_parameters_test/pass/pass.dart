// ignore_for_file: prefer_single_widget_per_file
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

class A {
  final String a;
  final String b;

  A({
    required this.a,
    required this.b,
  });

  A.a({
    required this.a,
    this.b = '',
  });

  A.b({
    required this.a,
    String? b,
  }) : b = b ?? '';

  void test2({
    required String a,
    String b = '',
  }) {}
}

void test2({
  String a = '',
  String? b,
}) {}

void test3(String a) {}

