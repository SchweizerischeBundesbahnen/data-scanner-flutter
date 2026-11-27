import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

extension CameraImageX on CameraImage {
  InputImage toInputImage({int rotation = 0}) {
    final bytes = Platform.isAndroid ? getNv21Uint8List() : _concatenatePlanes();

    final Size imageSize = Size(width.toDouble(), height.toDouble());

    final InputImageRotation imageRotation = InputImageRotationValue.fromRawValue(rotation)!;

    final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(format.raw)!;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: Platform.isAndroid ? InputImageFormat.nv21 : inputImageFormat,
      bytesPerRow: planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List getNv21Uint8List() {
    final width = this.width;
    final height = this.height;

    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    final yBuffer = yPlane.bytes;
    final uBuffer = uPlane.bytes;
    final vBuffer = vPlane.bytes;

    final numPixels = (width * height * 1.5).toInt();
    final nv21 = Uint8List(numPixels);

    // Full size Y channel and quarter size U+V channels.
    int idY = 0;
    int idUV = width * height;
    final uvWidth = width ~/ 2;
    final uvHeight = height ~/ 2;
    // Copy Y & UV channel.
    // NV21 format is expected to have YYYYVU packaging.
    // The U/V planes are guaranteed to have the same row stride and pixel stride.
    // getRowStride analogue??
    final uvRowStride = uPlane.bytesPerRow;
    // getPixelStride analogue
    final uvPixelStride = uPlane.bytesPerPixel ?? 0;
    final yRowStride = yPlane.bytesPerRow;
    final yPixelStride = yPlane.bytesPerPixel ?? 0;

    for (int y = 0; y < height; ++y) {
      final uvOffset = y * uvRowStride;
      final yOffset = y * yRowStride;

      for (int x = 0; x < width; ++x) {
        nv21[idY++] = yBuffer[yOffset + x * yPixelStride];

        if (y < uvHeight && x < uvWidth) {
          final bufferIndex = uvOffset + (x * uvPixelStride);
          //V channel
          nv21[idUV++] = vBuffer[bufferIndex];
          //V channel
          nv21[idUV++] = uBuffer[bufferIndex];
        }
      }
    }
    return nv21;
  }

  Uint8List _concatenatePlanes() {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }

    return allBytes.done().buffer.asUint8List();
  }
}
