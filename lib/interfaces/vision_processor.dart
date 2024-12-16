import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';

/// Processes and provides information about visuals.
abstract class VisionProcessor {
  /// Extracts the locations and sizes of bounding boxes within an image.
  /// Returns a [Map<Rect, String?>] combining the bounding boxes and their
  /// text content.
  Future<Map<Rect, String?>> getBoundingBoxes({
    required CameraImage image,
    required int imageRotation,
  });
}
