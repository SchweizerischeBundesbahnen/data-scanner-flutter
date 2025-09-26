import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sbb_data_scanner/extensions/_extensions.dart';

class MockPlane extends Mock implements Plane {}

class MockCameraImage extends Mock implements CameraImage {}

class FakeImageFormat extends Fake implements ImageFormat {
  @override
  int get raw => 35;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CameraImageX Extension', () {
    late MockCameraImage mockImage;
    late MockPlane yPlane;
    late MockPlane uPlane;
    late MockPlane vPlane;

    setUp(() {
      mockImage = MockCameraImage();
      yPlane = MockPlane();
      uPlane = MockPlane();
      vPlane = MockPlane();

      when(() => mockImage.width).thenReturn(4);
      when(() => mockImage.height).thenReturn(4);
      when(() => mockImage.planes).thenReturn([yPlane, uPlane, vPlane]);

      when(() => yPlane.bytesPerPixel).thenReturn(1);
      when(() => uPlane.bytesPerPixel).thenReturn(1);
      when(() => vPlane.bytesPerPixel).thenReturn(1);

      when(() => yPlane.bytesPerRow).thenReturn(4);
      when(() => uPlane.bytesPerRow).thenReturn(2);
      when(() => vPlane.bytesPerRow).thenReturn(2);

      when(() => yPlane.bytes).thenReturn(Uint8List.fromList(List.filled(16, 100)));
      when(() => uPlane.bytes).thenReturn(Uint8List.fromList(List.filled(4, 150)));
      when(() => vPlane.bytes).thenReturn(Uint8List.fromList(List.filled(4, 200)));

      when(() => mockImage.format).thenReturn(FakeImageFormat());
    });

    test('getNv21Uint8List returns expected length and format', () {
      final nv21 = mockImage.getNv21Uint8List();
      expect(nv21.length, 24);
      expect(nv21.sublist(0, 16).every((e) => e == 100), true); // Y plane
    });

    test('toInputImage returns InputImage with correct metadata', () {
      final image = mockImage.toInputImage(rotation: 0);
      expect(image.metadata?.size, const Size(4, 4));
      expect(image.metadata?.rotation, InputImageRotation.rotation0deg);
    });

    test('Handles null bytesPerPixel gracefully', () {
      when(() => yPlane.bytesPerPixel).thenReturn(null);
      when(() => uPlane.bytesPerPixel).thenReturn(null);
      when(() => vPlane.bytesPerPixel).thenReturn(null);

      final result = mockImage.getNv21Uint8List();
      expect(result.length, 24);
    });

    test('Handles invalid rotation value gracefully', () {
      expect(() => InputImageRotationValue.fromRawValue(999), returnsNormally);
      expect(InputImageRotationValue.fromRawValue(999), isNull);
    });
  });
}
