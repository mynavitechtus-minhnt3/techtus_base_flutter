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

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
// expect_lint: util_functions_must_be_static
void test() {}

// expect_lint: util_functions_must_be_static
void get(String url) {}

// expect_lint: util_functions_must_be_static
void post() {}

// expect_lint: util_functions_must_be_static
void request(String url) {}
