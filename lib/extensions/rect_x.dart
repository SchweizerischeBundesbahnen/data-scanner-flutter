import 'package:flutter/material.dart';

extension RectX on Rect {
  /// Proportionally scales the [Rect] by the [factor].
  Rect scale(double factor) => Rect.fromLTWH(
        left * factor,
        top * factor,
        width * factor,
        height * factor,
      );

  /// Returns whether the [child] is completely encapsulated by the [Rect].
  bool containsRect(Rect child) =>
      contains(child.topLeft) && contains(child.bottomRight);
}
