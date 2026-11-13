import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../bin/install_ios_ocr_resources.dart' as installer;

String resolved(String version) => jsonEncode({
  'pins': [
    {
      'identity': 'google-mlkit-swiftpm',
      'state': {'version': version},
    },
  ],
});

void main() {
  test('accepts the supported ML Kit pin', () {
    installer.validateVersion(resolved(installer.mlKitVersion));
  });

  test('rejects a different ML Kit version', () {
    expect(() => installer.validateVersion(resolved('9.0.3')), throwsFormatException);
  });

  test('rejects missing and malformed pins', () {
    for (final contents in ['{}', '{"pins":[]}', '{"pins":[null]}', 'invalid']) {
      expect(() => installer.validateVersion(contents), throwsFormatException);
    }
  });

  test('reports missing Xcode settings', () async {
    await expectLater(installer.install({}), throwsFormatException);
  });

  test('rejects corrupt cached downloads before copying into the app', () async {
    final temporary = await Directory.systemTemp.createTemp('ocr-install-test-');
    try {
      final workspace = Directory('${temporary.path}/ios/Runner.xcworkspace/xcshareddata/swiftpm');
      await workspace.create(recursive: true);
      await File('${workspace.path}/Package.resolved').writeAsString(resolved(installer.mlKitVersion));
      final cache = Directory('${temporary.path}/Library/Caches/sbb_data_scanner/ocr/${installer.mlKitVersion}');
      await cache.create(recursive: true);
      await File('${cache.path}/${installer.bundleName}.zip').writeAsString('corrupt');
      await expectLater(
        installer.install({
          'SRCROOT': '${temporary.path}/ios',
          'PROJECT_NAME': 'Runner',
          'TARGET_BUILD_DIR': '${temporary.path}/build',
          'UNLOCALIZED_RESOURCES_FOLDER_PATH': 'Runner.app',
          'HOME': temporary.path,
        }),
        throwsA(isA<FormatException>().having((error) => error.message, 'message', contains('Checksum mismatch'))),
      );
      expect(await Directory('${temporary.path}/build').exists(), isFalse);
    } finally {
      await temporary.delete(recursive: true);
    }
  }, skip: !Platform.isMacOS);
}
