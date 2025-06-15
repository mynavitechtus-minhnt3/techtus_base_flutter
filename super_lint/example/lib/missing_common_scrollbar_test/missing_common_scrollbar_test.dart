// ignore_for_file: prefer_single_widget_per_file
// ignore_for_file: incorrect_parent_class, prefer_common_widgets
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // expect_lint:missing_common_scrollbar
      body: ListView(), // ❌ Not have CommonScrollbar
    );
  }
}

class WrappedWithoutControllerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonScrollbar(
        // expect_lint:missing_common_scrollbar
        child: ListView(), // ❌ Missing controller
      ),
    );
  }
}

class WrappedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonScrollbar(
        child: ListView(
          controller: ScrollController(),
        ), // ✅ OK
      ),
    );
  }
}

class CommonScrollbar extends StatelessWidget {
  final Widget child;

  const CommonScrollbar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
