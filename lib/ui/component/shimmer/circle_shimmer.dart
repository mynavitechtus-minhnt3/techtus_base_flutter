// ignore_for_file: missing_golden_test
// ignore_for_file: avoid_hard_coded_colors
import 'package:flutter/material.dart';

import '../../../index.dart';

class CircleShimmer extends StatelessWidget {
  const CircleShimmer({
    this.diameter,
    super.key,
  });

  final double? diameter;

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_common_widgets
    return Container(
      width: diameter ?? 32.rps,
      height: diameter ?? 32.rps,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}
