import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../index.dart';

class CommonScrollbar extends HookConsumerWidget {
  const CommonScrollbar({
    required this.child,
    this.controller,
    this.thumbVisibility = false,
    this.padding,
    super.key,
  });

  final Widget child;
  final ScrollController? controller;
  final bool thumbVisibility; // shows a scroll bar indicator to provide a visual indication in test
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RawScrollbar(
      controller: controller,
      padding: padding,
      thumbVisibility: thumbVisibility,
      thickness: 4.rps,
      radius: const Radius.circular(3),
      interactive: true,
      // ignore: avoid_hard_coded_colors
      thumbColor: const Color(0xFF9B9B9B),
      child: child,
    );
  }
}
