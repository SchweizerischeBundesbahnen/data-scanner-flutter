import 'dart:developer' as developer;

import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:sbb_data_scanner/extensions/_extensions.dart';
import 'package:sbb_data_scanner/interfaces/vision_processor.dart';

/// Implementation of [VisionProcessor] specifically for text recognition.
class TextRecognitionVisionProcessor implements VisionProcessor {
  final _scanner = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<Map<Rect, String?>> getBoundingBoxes({required CameraImage image, required int imageRotation}) async {
    final input = image.toInputImage(rotation: imageRotation);

    // TimelineTask (not Timeline.timeSync) because this spans an `await`,
    // crossing back into native MLKit/Vision code.
    final task = developer.TimelineTask()..start('DataScanner.mlkitProcessImage.textRecognition');
    final RecognizedText value;
    try {
      value = await _scanner.processImage(input);
    } finally {
      task.finish();
    }

    return Map.fromIterable(
      value.blocks.expand((block) => block.lines),
      key: (line) => line.boundingBox,
      value: (line) => line.text,
    );
  }
}
