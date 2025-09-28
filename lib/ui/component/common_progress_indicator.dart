// ignore_for_file: missing_golden_test
import 'package:flutter/material.dart';

class CommonProgressIndicator extends StatelessWidget {
  const CommonProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
