import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

extension BarcodeX on Barcode {
  bool get isOneDimensional {
    final oneDimensionalFormats = [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
      BarcodeFormat.upca,
      BarcodeFormat.upce,
    ];

    return oneDimensionalFormats.contains(this.format);
  }

  bool get isTwoDimensional {
    final twoDimensionalFormats = [
      BarcodeFormat.dataMatrix,
      BarcodeFormat.qrCode,
      BarcodeFormat.pdf417,
      BarcodeFormat.aztec,
    ];

    return twoDimensionalFormats.contains(this.format);
  }
}
