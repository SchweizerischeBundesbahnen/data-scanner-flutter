import 'package:camera/camera.dart';

/// A series of camera related helper functions.
abstract class CameraService {
  /// Returns the [CameraDescription] of the camera that faces [direction].
  static Future<CameraDescription> getCamera(CameraLensDirection direction) async {
    final List<CameraDescription> cameras = await availableCameras();

    if (cameras.isEmpty) {
      throw CameraException(
        'cameraNotFound',
        'No camera is available for direction $direction on this device.',
      );
    }

    final CameraDescription? matchingCamera = cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == direction,
    );

    if (matchingCamera != null) {
      return matchingCamera;
    }

    if (cameras.isNotEmpty) {
      return cameras.first;
    }

    throw CameraException(
      'cameraNotFound',
      'No camera is available for direction $direction on this device.',
    );
  }
}
