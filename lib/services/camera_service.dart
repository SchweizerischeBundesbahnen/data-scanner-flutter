import 'package:camera/camera.dart';

/// A series of camera related helper functions.
abstract class CameraService {
  /// Returns the [CameraDescription] of the camera that faces [direction].
  static Future<CameraDescription> getCamera(
          CameraLensDirection direction) async =>
      await availableCameras().then(
        (List<CameraDescription> cameras) => cameras.firstWhere(
          (CameraDescription camera) => camera.lensDirection == direction,
        ),
      );
}
