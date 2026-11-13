import 'package:camera/camera.dart';

/// A series of camera related helper functions.
abstract class CameraService {
  /// Returns the [CameraDescription] of the camera that faces [direction].
  /// If the preferred camera is unavailable, falls back to the first available camera.
  static Future<CameraDescription> getCameraWithPreferredDirection(CameraLensDirection direction) async {
    final List<CameraDescription> cameras = await availableCameras();

    try {
      return cameras.firstWhere((CameraDescription camera) => camera.lensDirection == direction);
    } on StateError {
      if (cameras.isNotEmpty) {
        return cameras.first;
      }

      throw CameraException('cameraNotFound', 'No camera is available for direction $direction on this device.');
    }
  }
}
