import 'package:flutter/material.dart';

/// Draws the company logo of SBB.
class SBBLogoDrawable extends StatelessWidget {
  /// Stroke color of the logo. Defaults to [Colors.white].
  final Color color;

  const SBBLogoDrawable({Key? key, this.color = Colors.white}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 21.0, horizontal: 16),
      child: CustomPaint(size: Size(28, 14), painter: _RPSCustomPainter(color)),
    );
  }
}

/// This custom painter was generated with https://fluttershapemaker.com/
class _RPSCustomPainter extends CustomPainter {
  /// Stroke color to be used when drawing.
  final Color color;

  const _RPSCustomPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.6047389, 0);
    path_0.lineTo(size.width * 0.8008207, size.height * 0.3858432);
    path_0.lineTo(size.width * 0.5575088, size.height * 0.3858432);
    path_0.lineTo(size.width * 0.5575088, 0);
    path_0.lineTo(size.width * 0.4425309, 0);
    path_0.lineTo(size.width * 0.4425309, size.height * 0.3858432);
    path_0.lineTo(size.width * 0.1992322, size.height * 0.3858432);
    path_0.lineTo(size.width * 0.3952611, 0);
    path_0.lineTo(size.width * 0.2495996, 0);
    path_0.lineTo(0, size.height * 0.5008074);
    path_0.lineTo(size.width * 0.2495996, size.height);
    path_0.lineTo(size.width * 0.3952611, size.height);
    path_0.lineTo(size.width * 0.1992322, size.height * 0.6157715);
    path_0.lineTo(size.width * 0.4425309, size.height * 0.6157715);
    path_0.lineTo(size.width * 0.4425309, size.height);
    path_0.lineTo(size.width * 0.5575088, size.height);
    path_0.lineTo(size.width * 0.5575088, size.height * 0.6157715);
    path_0.lineTo(size.width * 0.8008207, size.height * 0.6157715);
    path_0.lineTo(size.width * 0.6047389, size.height);
    path_0.lineTo(size.width * 0.7504269, size.height);
    path_0.lineTo(size.width, size.height * 0.5008074);
    path_0.lineTo(size.width * 0.7504269, 0);
    path_0.close();

    Paint paint0Fill = Paint()..style = PaintingStyle.fill;
    paint0Fill.color = color;
    canvas.drawPath(path_0, paint0Fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
