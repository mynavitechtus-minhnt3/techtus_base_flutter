// ignore_for_file: avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

Future<void> test() async {
  final future = Future(() {
    print('future');
  });

  await future;
}

