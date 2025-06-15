// ignore_for_file: prefer_named_parameters, avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

void main() {
  test('lowercase text', () {});
  test('1lowercase text', () {});
  test('_lowercase text', () {});
  test('*lowercase text', () {});

  blocTest('lowercase text', () {});
  blocTest('1lowercase text', () {});
  blocTest('_lowercase text', () {});
  blocTest('*lowercase text', () {});

  stateNotifierTest('Uppercase text', () {});
}

