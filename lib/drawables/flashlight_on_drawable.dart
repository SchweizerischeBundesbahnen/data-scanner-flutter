import 'package:flutter/material.dart';

/// Draws an enabled flashlight
class FlashlightOnDrawable extends StatelessWidget {
  /// Stroke color of the flashlight. Defaults to [Colors.transparent].
  final Color color;

  const FlashlightOnDrawable({
    Key? key,
    this.color = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: CustomPaint(
        size: Size(24, 24),
        painter: _RPSCustomPainter(color),
      ),
    );
  }
}

/// This custom painter was generated with https://fluttershapemaker.com/ based on the SBB icon flashlight off
class _RPSCustomPainter extends CustomPainter {
  /// Stroke color to be used when drawing.
  final Color color;

  const _RPSCustomPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(8.5, 21.5);
    path_0.lineTo(14.5, 21.5);
    path_0.lineTo(14.5, 11.5);
    path_0.lineTo(8.5, 11.5);
    path_0.lineTo(8.5, 21.5);
    path_0.close();
    path_0.moveTo(15.5, 9);
    path_0.lineTo(14.5, 11.5);
    path_0.lineTo(8.5, 11.5);
    path_0.lineTo(7.5, 9);
    path_0.lineTo(7.5, 6.5);
    path_0.lineTo(15.5, 6.5);
    path_0.lineTo(15.5, 9);
    path_0.close();
    path_0.moveTo(10.5, 19.5);
    path_0.lineTo(12.5, 19.5);
    path_0.lineTo(12.5, 13.5);
    path_0.lineTo(10.5, 13.5);
    path_0.lineTo(10.5, 19.5);
    path_0.close();
    path_0.moveTo(11.5, 15);
    path_0.lineTo(11.5, 16);
    path_0.moveTo(7.5, 9);
    path_0.lineTo(15.5, 9);
    path_0.moveTo(11.5, 2);
    path_0.lineTo(11.5, 5);
    path_0.moveTo(14, 5);
    path_0.lineTo(16, 2);
    path_0.moveTo(9, 5);
    path_0.lineTo(7, 2);

    Paint paint0Stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04166667;
    paint0Stroke.color = color.withOpacity(1.0);
    canvas.drawPath(path_0, paint0Stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
