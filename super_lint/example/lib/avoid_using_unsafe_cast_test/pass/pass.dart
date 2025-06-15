// ignore_for_file: avoid_dynamic, avoid_hard_coded_strings
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~

void main() {
  print('3'.safeCast<int>());
  dynamic a = '3';
  if (safeCast<bool>(a) == true) {}
}

