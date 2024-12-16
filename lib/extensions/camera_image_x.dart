import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

extension CameraImageX on CameraImage {
  InputImage toInputImage({int rotation = 0}) {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in this.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(this.width.toDouble(), this.height.toDouble());

    final InputImageRotation imageRotation = InputImageRotationValue.fromRawValue(rotation)!;

    final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(this.format.raw)!;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }
}
