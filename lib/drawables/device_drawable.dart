import 'package:flutter/material.dart';

/// Draws an icon representing a mobile phone.
class DeviceLogoDrawable extends StatelessWidget {
  /// Width of the device icon. Defaults to `28`.
  final double width;

  /// Height of the device icon. Defaults to `50`.
  final double height;

  /// Stroke color of the device icon. Defaults to [Colors.white].
  final Color color;

  const DeviceLogoDrawable({
    Key? key,
    this.width = 28,
    this.height = 50,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RPSCustomPainter(color),
    );
  }
}

/// This custom painter was generated with https://fluttershapemaker.com/
class _RPSCustomPainter extends CustomPainter {
  /// Stroke color to be used when drawing.
  final Color color;

  _RPSCustomPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.2848974, size.height * 0.08969378);
    path_0.lineTo(size.width * 0.7122479, size.height * 0.08969378);
    path_0.moveTo(size.width * 0.01780342, size.height * 0.08963636);
    path_0.lineTo(size.width * 0.01780342, size.height * 0.9270144);
    path_0.cubicTo(
      size.width * 0.01780342,
      size.height * 0.9600909,
      size.width * 0.06566667,
      size.height * 0.9868230,
      size.width * 0.1246410,
      size.height * 0.9868230,
    );
    path_0.lineTo(size.width * 0.8725043, size.height * 0.9868230);
    path_0.cubicTo(
      size.width * 0.9315897,
      size.height * 0.9868230,
      size.width * 0.9793419,
      size.height * 0.9600909,
      size.width * 0.9793419,
      size.height * 0.9270144,
    );
    path_0.lineTo(size.width * 0.9793419, size.height * 0.08969378);
    path_0.cubicTo(
      size.width * 0.9793419,
      size.height * 0.05667943,
      size.width * 0.9315897,
      size.height * 0.02988517,
      size.width * 0.8725043,
      size.height * 0.02988517,
    );
    path_0.lineTo(size.width * 0.1246410, size.height * 0.02982775);
    path_0.cubicTo(
      size.width * 0.06566667,
      size.height * 0.02982775,
      size.width * 0.01780342,
      size.height * 0.05662201,
      size.width * 0.01780342,
      size.height * 0.08963636,
    );
    path_0.close();

    Paint paintStroke = Paint()
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    paintStroke.color = color;
    canvas.drawPath(path_0, paintStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
