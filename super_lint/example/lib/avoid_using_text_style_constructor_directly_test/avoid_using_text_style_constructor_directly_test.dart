// ignore_for_file: prefer_common_widgets, avoid_hard_coded_strings, avoid_hard_coded_colors
// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD NOT BE WARNED ~.~.~.~.~.~.~.~
import 'package:flutter/material.dart';

void main() {
  style(color: Colors.black);
  Text('Hello, World!', style: style(color: Colors.black));
}

TextStyle style({
  required Color color,
}) {
  // expect_lint: avoid_using_text_style_constructor_directly
  return TextStyle(color: color);
}

// ~.~.~.~.~.~.~.~ THE FOLLOWING CASES SHOULD BE WARNED ~.~.~.~.~.~.~.~
void test() {
  // expect_lint: avoid_using_text_style_constructor_directly
  Text('Hello, World!', style: TextStyle(color: Colors.black));
  // expect_lint: avoid_using_text_style_constructor_directly
  TextStyle(color: Colors.black);
}
