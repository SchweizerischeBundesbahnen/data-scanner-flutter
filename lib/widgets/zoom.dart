import 'package:flutter/material.dart';

class Zoom extends StatelessWidget {
  const Zoom({super.key, required this.zoom});

  final double zoom;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1)),
      child: Text(
        '${zoom.toStringAsFixed(1)}x',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
