import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Sized and scaled [CameraPreview] wrapper.
class SizedCameraPreview<T> extends StatefulWidget {
  const SizedCameraPreview({super.key, required this.size, required this.cameraController});

  /// Size of the clipped preview.
  final Size size;

  /// Controls the device cameras.
  final CameraController cameraController;

  @override
  State<SizedCameraPreview<T>> createState() => _SizedCameraPreviewState<T>();
}

class _SizedCameraPreviewState<T> extends State<SizedCameraPreview<T>> {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);

    /// Size of preview in pixels, always in landscape. We need to flip it for
    /// the correct size in portrait mode.
    final previewSize = screen.orientation == Orientation.landscape
        ? widget.cameraController.value.previewSize!
        : widget.cameraController.value.previewSize!.flipped;

    return SizedBox(
      height: widget.size.height,
      width: widget.size.width,
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          height: previewSize.height,
          width: previewSize.width,
          child: CameraPreview(widget.cameraController),
        ),
      ),
    );
  }
}
