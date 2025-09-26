import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

extension CameraImageX on CameraImage {
  InputImage toInputImage({int rotation = 0}) {
    final WriteBuffer allBytes = WriteBuffer();

    for (final Plane plane in this.planes) {
      allBytes.putUint8List(plane.bytes);
    }

    final bytes = Platform.isAndroid ? this.getNv21Uint8List() : allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(this.width.toDouble(), this.height.toDouble());

    final InputImageRotation imageRotation = InputImageRotationValue.fromRawValue(rotation)!;

    final InputImageFormat inputImageFormat = InputImageFormatValue.fromRawValue(this.format.raw)!;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: Platform.isAndroid ? InputImageFormat.nv21 : inputImageFormat,
      bytesPerRow: planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  Uint8List getNv21Uint8List() {
    var width = this.width;
    var height = this.height;

    var yPlane = planes[0];
    var uPlane = planes[1];
    var vPlane = planes[2];

    var yBuffer = yPlane.bytes;
    var uBuffer = uPlane.bytes;
    var vBuffer = vPlane.bytes;

    var numPixels = (width * height * 1.5).toInt();
    var nv21 = List<int>.filled(numPixels, 0);

    // Full size Y channel and quarter size U+V channels.
    int idY = 0;
    int idUV = width * height;
    var uvWidth = width ~/ 2;
    var uvHeight = height ~/ 2;
    // Copy Y & UV channel.
    // NV21 format is expected to have YYYYVU packaging.
    // The U/V planes are guaranteed to have the same row stride and pixel stride.
    // getRowStride analogue??
    var uvRowStride = uPlane.bytesPerRow;
    // getPixelStride analogue
    var uvPixelStride = uPlane.bytesPerPixel ?? 0;
    var yRowStride = yPlane.bytesPerRow;
    var yPixelStride = yPlane.bytesPerPixel ?? 0;

    for (int y = 0; y < height; ++y) {
      var uvOffset = y * uvRowStride;
      var yOffset = y * yRowStride;

      for (int x = 0; x < width; ++x) {
        nv21[idY++] = yBuffer[yOffset + x * yPixelStride];

        if (y < uvHeight && x < uvWidth) {
          var bufferIndex = uvOffset + (x * uvPixelStride);
          //V channel
          nv21[idUV++] = vBuffer[bufferIndex];
          //V channel
          nv21[idUV++] = uBuffer[bufferIndex];
        }
      }
    }
    return Uint8List.fromList(nv21);
  }
}
