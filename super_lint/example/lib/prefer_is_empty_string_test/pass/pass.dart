// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

void test1(String a) {
  if (a.isEmpty) {}

  if (a.isNotEmpty) {}
}

void test2({String a = '', String b = ''}) {
  if (a.isEmpty || b.isNotEmpty) {}

  if (a.isNotEmpty && a.isEmpty) {}
}

