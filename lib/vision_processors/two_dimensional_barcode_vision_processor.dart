import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:sbb_data_scanner/extensions/_extensions.dart';
import 'package:sbb_data_scanner/interfaces/vision_processor.dart';

/// Implementation of [VisionProcessor] specifically for scanning 2-D barcodes.
class TwoDimensionalBarcodeVisionProcessor implements VisionProcessor {
  final _scanner = BarcodeScanner();

  @override
  Future<Map<Rect, String?>> getBoundingBoxes({required CameraImage image, required int imageRotation}) async {
    final input = image.toInputImage(rotation: imageRotation);

    // TimelineTask (not Timeline.timeSync) because this spans an `await`,
    // crossing back into native MLKit/Vision code.
    final task = developer.TimelineTask()..start('DataScanner.mlkitProcessImage.2dBarcode');
    final List<Barcode> value;
    try {
      value = await _scanner.processImage(input);
    } finally {
      task.finish();
    }

    return Map.fromIterable(value, key: (barcode) => barcode.boundingBox, value: (barcode) => _getText(barcode));
  }

  /// Extract text from [barcode]. Returns `null` if [barcode] is not 2-D.
  String? _getText(Barcode barcode) {
    return barcode.isTwoDimensional ? barcode.rawValue : null;
  }
}
