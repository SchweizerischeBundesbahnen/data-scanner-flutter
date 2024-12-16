import 'package:flutter/material.dart';

/// Creates a cutout hole.
class HolePainter extends CustomPainter {
  /// Position and size of the cutout hole.
  final Rect rect;

  /// Border radius of the hole. Defaults to `12`.
  final double radius;

  /// Color of the overlay background. Defaults to [Colors.black].
  final Color overlayColor;

  /// Opacity of the overlay background. Defaults to `0.75`.
  final double overlayColorOpacity;

  /// Color of the cutout hole border. Defaults to [Colors.white].
  final Color borderColor;

  /// Opacity of the cutout hole border. Defaults to `0.75`.
  final double borderColorOpacity;

  /// Width of the cutout hole border. Defaults to `1`.
  final double borderWidth;

  HolePainter({
    required this.rect,
    this.radius = 12,
    this.overlayColor = Colors.black,
    this.overlayColorOpacity = 0.75,
    this.borderColor = Colors.white,
    this.borderColorOpacity = 0.75,
    this.borderWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackgroundWithHole(canvas, size);
    _paintBorder(canvas);
  }

  /// Draws the background with size [size] and cuts out a hole.
  void _paintBackgroundWithHole(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = overlayColor.withOpacity(overlayColorOpacity);
    final background = Path()..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    if (rect.height == 0 && rect.width == 0) {
      canvas.drawPath(background, paint);
    } else {
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          background,
          Path()
            ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
            ..close(),
        ),
        paint,
      );
    }
  }

  /// Draws the border of the hole.
  void _paintBorder(Canvas canvas) {
    final whitePainter = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(
        Path()
          ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
          ..close(),
        whitePainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
