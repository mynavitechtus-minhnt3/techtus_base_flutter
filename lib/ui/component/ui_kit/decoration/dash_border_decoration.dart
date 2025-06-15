import 'dart:ui';

import 'package:flutter/widgets.dart';

import '../../../../index.dart';

class DashBorderDecoration extends Decoration {
  const DashBorderDecoration({
    required this.dashBorder,
    this.shape = CommonShape.rectangle,
    this.color,
  });

  final DashBorder dashBorder;
  final CommonShape shape;
  final Color? color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DashBorderDecotatorPainter(
      dashBorder: dashBorder,
      shape: shape,
      color: color,
    );
  }
}

class _DashBorderDecotatorPainter extends BoxPainter {
  _DashBorderDecotatorPainter({
    required this.dashBorder,
    required this.shape,
    this.color,
  });

  final DashBorder dashBorder;
  final CommonShape shape;
  final Color? color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Path outPath = Path();
    switch (shape) {
      case CommonShape.rectangle:
        final RRect rect = RRect.fromLTRBAndCorners(
          offset.dx,
          offset.dy,
          offset.dx + (configuration.size?.width ?? 0),
          offset.dy + (configuration.size?.height ?? 0),
          bottomLeft: dashBorder.borderRadius?.bottomLeft ?? Radius.zero,
          bottomRight: dashBorder.borderRadius?.bottomRight ?? Radius.zero,
          topLeft: dashBorder.borderRadius?.topLeft ?? Radius.zero,
          topRight: dashBorder.borderRadius?.topRight ?? Radius.zero,
        );
        outPath.addRRect(rect);
        break;
      case CommonShape.circle:
        outPath.addOval(Rect.fromLTWH(
          offset.dx,
          offset.dy,
          configuration.size!.width,
          configuration.size!.height,
        ));
        break;
    }

    if (color != null) {
      canvas.drawPath(
        outPath,
        Paint()
          ..color = color!
          ..style = PaintingStyle.fill,
      );
    }

    final PathMetrics metrics = outPath.computeMetrics(forceClosed: false);
    final Path drawPath = Path();

    for (PathMetric me in metrics) {
      final double totalLength = me.length;
      int index = -1;

      for (double start = 0; start < totalLength;) {
        double to = start + dashBorder.dash[(++index) % dashBorder.dash.length];
        to = to > totalLength ? totalLength : to;
        final bool isEven = index % 2 == 0;
        if (isEven) {
          drawPath.addPath(me.extractPath(start, to, startWithMoveTo: true), Offset.zero);
        }
        start = to;
      }
    }

    canvas.drawPath(
      drawPath,
      Paint()
        ..color = dashBorder.borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = dashBorder.borderWidth!,
    );
  }
}
