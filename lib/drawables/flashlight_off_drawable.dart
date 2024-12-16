import 'package:flutter/material.dart';

/// Draws a disabled flashlight
class FlashlightOffDrawable extends StatelessWidget {
  /// Stroke color of the flashlight. Defaults to [Colors.white].
  final Color color;

  const FlashlightOffDrawable({
    Key? key,
    this.color = Colors.white,
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
    path_0.moveTo(15.5, 9.0);
    path_0.lineTo(14.5, 11.5);
    path_0.lineTo(8.5, 11.5);
    path_0.lineTo(7.5, 9.0);
    path_0.lineTo(7.5, 6.5);
    path_0.lineTo(15.5, 6.5);
    path_0.lineTo(15.5, 9.0);
    path_0.close();
    path_0.moveTo(10.5, 19.5);
    path_0.lineTo(12.5, 19.5);
    path_0.lineTo(12.5, 13.5);
    path_0.lineTo(10.5, 13.5);
    path_0.lineTo(10.5, 19.5);
    path_0.close();
    path_0.moveTo(11.5, 17.0);
    path_0.lineTo(11.5, 18.0);
    path_0.moveTo(7.5, 9.0);
    path_0.lineTo(15.5, 9.0);

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
