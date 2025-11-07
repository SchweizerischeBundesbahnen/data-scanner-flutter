import 'package:flutter/material.dart';

enum DetectionLabelPosition { topLeft, topRight, bottomLeft, bottomRight, topCenter, bottomCenter }

extension DetectionLabelPositionX on DetectionLabelPosition {
  /// Returns matching [TextAlign].
  TextAlign get alignment {
    switch (this) {
      case DetectionLabelPosition.topLeft:
      case DetectionLabelPosition.bottomLeft:
        return TextAlign.left;
      case DetectionLabelPosition.topRight:
      case DetectionLabelPosition.bottomRight:
        return TextAlign.right;
      case DetectionLabelPosition.topCenter:
      case DetectionLabelPosition.bottomCenter:
        return TextAlign.center;
    }
  }

  /// Calculates display offset from [rect] including [margin].
  Offset offsetFromRect(Rect rect, double fontSize, double margin) {
    switch (this) {
      case DetectionLabelPosition.topLeft:
      case DetectionLabelPosition.topRight:
      case DetectionLabelPosition.topCenter:
        return Offset(rect.left, rect.top - fontSize - margin);
      case DetectionLabelPosition.bottomLeft:
      case DetectionLabelPosition.bottomRight:
      case DetectionLabelPosition.bottomCenter:
        return Offset(rect.left, rect.bottom + margin);
    }
  }
}

/// Configuration for detection outlines.
class DetectionOutlineConfig {
  /// Inner spacing between the actual detection and the displayed outline.
  /// Defaults to `10`.
  final double padding;

  /// Outer spacing between the displayed outline and the label.
  /// Defaults to `5`.
  final double margin;

  /// Width of the displayed outline. Defaults to `2`.
  final double outlineWidth;

  /// Corner radius of the displayed outlines. Defaults to `5`.
  final double cornerRadius;

  /// Outline color when the detection is inside the scanner cutout.
  /// Defaults to [Colors.green].
  final Color activeOutlineColor;

  /// Outline color when the detection is outside the scanner cutout.
  /// Defaults to a mostly transparent white.
  final Color inactiveOutlineColor;

  /// Whether to display labels containing the scanned value.
  /// Defaults to `true`.
  final bool enableLabel;

  /// Location of the value label. Defaults to [DetectionLabelPosition.bottomLeft].
  final DetectionLabelPosition labelPosition;

  /// Color of the displayed label. Defaults to [Colors.white].
  final Color labelColor;

  /// Font size of the displayed label. Defaults to `12`.
  final double labelSize;

  DetectionOutlineConfig({
    this.padding = 10,
    this.margin = 5,
    this.outlineWidth = 2,
    this.cornerRadius = 5,
    this.activeOutlineColor = Colors.green,
    this.inactiveOutlineColor = const Color.fromRGBO(255, 255, 255, 0.2),
    this.enableLabel = true,
    this.labelPosition = DetectionLabelPosition.bottomLeft,
    this.labelColor = Colors.white,
    this.labelSize = 12,
  });
}

/// Configures rendering of detection boxes.
class DetectionOutline extends StatelessWidget {
  /// Locations and sizes of the detection boxes, paired with their value.
  final Map<Rect, String> boundingBoxes;

  /// Location and size of the scanner cutout.
  final Rect detectionAreaBoundingBox;

  /// Configuration values for rendering detection outlines.
  final DetectionOutlineConfig outlineConfig;

  DetectionOutline({required this.boundingBoxes, required this.detectionAreaBoundingBox, required this.outlineConfig});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DetectionOutlinePainter(
      boundingBoxes: boundingBoxes,
      detectionAreaBoundingBox: detectionAreaBoundingBox,
      outlineConfig: outlineConfig,
    ),
  );
}

/// Paints detection boxes on screen.
class _DetectionOutlinePainter extends CustomPainter {
  /// Configuration values for rendering detection outlines.
  final DetectionOutlineConfig outlineConfig;

  /// Location and size of the scanner cutout.
  final Rect detectionAreaBoundingBox;

  /// Locations and sizes of the detection boxes, paired with their value.
  final Map<Rect, String> boundingBoxes;

  /// Base configuration for debugging border styling.
  final Paint _paint = Paint();

  _DetectionOutlinePainter({
    required this.boundingBoxes,
    required this.detectionAreaBoundingBox,
    required this.outlineConfig,
  }) {
    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = outlineConfig.outlineWidth;
  }

  /// Checks whether [boundingBox] is within the [detectionAreaBoundingBox].
  bool _isInDetectionArea(Rect boundingBox) =>
      detectionAreaBoundingBox.contains(boundingBox.topLeft) &&
      detectionAreaBoundingBox.contains(boundingBox.bottomRight);

  /// Displays [text] at [labelPosition] of [rect].
  void _paintOutlineLabel(Canvas canvas, Rect rect, String text, DetectionLabelPosition labelPosition) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(color: outlineConfig.labelColor, fontSize: outlineConfig.labelSize),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: labelPosition.alignment,
    );

    textPainter.layout(minWidth: rect.right - rect.left);
    textPainter.paint(canvas, labelPosition.offsetFromRect(rect, outlineConfig.labelSize, outlineConfig.margin));
  }

  @override
  void paint(Canvas canvas, Size size) {
    boundingBoxes.forEach((rect, value) {
      final paddedRect = rect.inflate(outlineConfig.padding);

      _paint.color = _isInDetectionArea(paddedRect)
          ? outlineConfig.activeOutlineColor
          : outlineConfig.inactiveOutlineColor;

      final roundedRect = RRect.fromRectAndRadius(paddedRect, Radius.circular(outlineConfig.cornerRadius));

      canvas.drawRRect(roundedRect, _paint);

      if (outlineConfig.enableLabel) {
        _paintOutlineLabel(canvas, paddedRect, value, outlineConfig.labelPosition);
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
