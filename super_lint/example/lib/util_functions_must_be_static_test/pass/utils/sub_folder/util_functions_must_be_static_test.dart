// ignore_for_file: prefer_single_widget_per_file
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
import 'package:flutter/material.dart';

class Utils {
  static void test() {}

  static void get(String url) {}

  static void post() {}

  static void request(String url) {
    _test();
  }
}

void _test() {}

@visibleForTesting
void genCode(String url) {}

