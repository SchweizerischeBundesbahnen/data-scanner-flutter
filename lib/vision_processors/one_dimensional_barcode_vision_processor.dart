import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:sbb_data_scanner/extensions/_extensions.dart';
import 'package:sbb_data_scanner/interfaces/vision_processor.dart';

/// Implementation of [VisionProcessor] specifically for scanning 1-D barcodes.
class OneDimensionalBarcodeVisionProcessor implements VisionProcessor {
  final _scanner = BarcodeScanner();

  @override
  Future<Map<Rect, String?>> getBoundingBoxes({
    required CameraImage image,
    required int imageRotation,
  }) async {
    final input = image.toInputImage(rotation: imageRotation);
    final value = await _scanner.processImage(input);

    return Map.fromIterable(
      value,
      key: (barcode) => barcode.boundingBox,
      value: (barcode) => _getText(barcode),
    );
  }

  /// Extract text from [barcode]. Returns `null` if [barcode] is not 1-D.
  String? _getText(Barcode barcode) {
    return barcode.isOneDimensional ? barcode.rawValue : null;
  }
}
