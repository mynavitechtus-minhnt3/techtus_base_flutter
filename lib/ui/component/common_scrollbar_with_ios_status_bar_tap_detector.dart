// ignore_for_file: missing_golden_test
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../index.dart';

// ignore: must_be_immutable
class CommonScrollbarWithIosStatusBarTapDetector extends HookConsumerWidget {
  CommonScrollbarWithIosStatusBarTapDetector({
    required this.child,
    required this.routeName,
    required this.controller,
    this.onStatusBarTap,
    this.thumbVisibility = false,
    this.padding,
    super.key,
  });

  final Widget child;
  final String routeName;
  final ScrollController controller;
  final VoidCallback? onStatusBarTap;
  final bool thumbVisibility;
  final EdgeInsets? padding;

  void _onStatusBarTap(String currentRouteName) {
    if (currentRouteName == routeName) {
      controller.scrollToTop();
    }
  }

  VoidCallback? _detachCallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      if (!Platform.isIOS) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = ref.nav.isUseRootNavigator ? context : Navigator.of(context).context;

        final primaryScrollController = PrimaryScrollController.of(ctx);
        final scrollPositionWithSingleContext = _FakeScrollPositionWithSingleContext(
          context: context,
          onStatusBarTap: onStatusBarTap == null
              ? () => _onStatusBarTap(ref.nav.getCurrentRouteName())
              : () => onStatusBarTap?.call(),
        );
        primaryScrollController.attach(scrollPositionWithSingleContext);

        _detachCallback = () {
          primaryScrollController.detach(scrollPositionWithSingleContext);
        };
      });

      return () {
        _detachCallback?.call();
      };
    });

    return CommonScrollbar(
      child: child,
      controller: controller,
      thumbVisibility: thumbVisibility,
      padding: padding,
    );
  }
}

class _FakeScrollPositionWithSingleContext extends ScrollPositionWithSingleContext {
  _FakeScrollPositionWithSingleContext({
    required BuildContext context,
    this.onStatusBarTap,
  }) : super(
          physics: const NeverScrollableScrollPhysics(),
          context: _FakeScrollContext(context),
        );
  final VoidCallback? onStatusBarTap;

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) async =>
      onStatusBarTap?.call();
}

class _FakeScrollContext extends ScrollContext {
  _FakeScrollContext(this._context);

  final BuildContext _context;

  @override
  AxisDirection get axisDirection => AxisDirection.down;

  @override
  BuildContext get notificationContext => _context;

  @override
  void saveOffset(double offset) {}

  @override
  void setCanDrag(bool value) {}

  @override
  void setIgnorePointer(bool value) {}

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {}

  @override
  BuildContext get storageContext => _context;

  @override
  TickerProvider get vsync => _FakeTickerProvider();

  @override
  double get devicePixelRatio => MediaQuery.devicePixelRatioOf(_context);
}

class _FakeTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
