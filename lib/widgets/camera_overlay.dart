import 'package:flutter/material.dart';

import 'hole_painter.dart';

/// Screen overlay when scanner is active.
class CameraOverlay extends StatelessWidget {
  const CameraOverlay({
    Key? key,
    required this.previewSize,
    required this.detectionAreaBoundingBox,
    this.upperHelper,
    this.lowerHelper,
  }) : super(key: key);

  /// Size of the widget over which the overlay should be displayed.
  final Size previewSize;

  /// Position and size of the cutout in the overlay. This is where the content
  /// must be scanned at.
  final Rect detectionAreaBoundingBox;

  /// Helper text to show above the scanner hole.
  final Widget? upperHelper;

  /// Helper text to show below the scanner hole.
  final Widget? lowerHelper;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: HolePainter(rect: detectionAreaBoundingBox),
          child: Container(),
        ),
        if (upperHelper != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: previewSize.height - detectionAreaBoundingBox.top,
            child: upperHelper!,
          ),
        if (lowerHelper != null)
          Positioned(
            top: detectionAreaBoundingBox.bottom,
            left: 0,
            right: 0,
            child: lowerHelper!,
          ),
      ],
    );
  }
}
