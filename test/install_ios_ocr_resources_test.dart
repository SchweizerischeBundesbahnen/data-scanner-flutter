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
  test('reads the ML Kit release version without a hardcoded pin', () {
    for (final version in ['9.0.2', '9.0.3', '10.1.0', '10.1.0-beta.1']) {
      expect(installer.resolvedVersion(resolved(version)), version);
    }
  });

  test('rejects missing and malformed pins', () {
    for (final contents in ['{}', '{"pins":[]}', '{"pins":[null]}', 'invalid']) {
      expect(() => installer.resolvedVersion(contents), throwsFormatException);
    }
  });

  test('rejects revision pins and unsafe versions', () {
    for (final version in ['', 'main', '../9.0.2', '9.0.2/other', '9.0.2\n']) {
      expect(() => installer.resolvedVersion(resolved(version)), throwsFormatException);
    }
    expect(
      () => installer.resolvedVersion('{"pins":[{"identity":"google-mlkit-swiftpm","state":{"revision":"abc"}}]}'),
      throwsFormatException,
    );
  });

  test('reports missing Xcode settings', () async {
    await expectLater(installer.install({}), throwsFormatException);
  });

  test('copies the resolved version from its cache and replaces older contents', () async {
    final temporary = await Directory.systemTemp.createTemp('ocr-install-test-');
    try {
      final workspace = Directory('${temporary.path}/ios/Runner.xcworkspace/xcshareddata/swiftpm');
      await workspace.create(recursive: true);
      final fixture = Directory('${temporary.path}/fixture/${installer.bundleName}');
      await fixture.create(recursive: true);
      final destination = Directory('${temporary.path}/build/Runner.app/${installer.bundleName}');
      for (final version in ['9.0.2', '10.1.0']) {
        await File('${workspace.path}/Package.resolved').writeAsString(resolved(version));
        await File('${fixture.path}/model').writeAsString(version);
        final cache = Directory('${temporary.path}/Library/Caches/sbb_data_scanner/ocr/$version');
        await cache.create(recursive: true);
        final zip = await Process.run('/usr/bin/zip', [
          '-qr',
          '${cache.path}/${installer.bundleName}.zip',
          installer.bundleName,
        ], workingDirectory: fixture.parent.path);
        expect(zip.exitCode, 0, reason: '${zip.stderr}');
        await installer.install({
          'SRCROOT': '${temporary.path}/ios',
          'PROJECT_NAME': 'Runner',
          'TARGET_BUILD_DIR': '${temporary.path}/build',
          'UNLOCALIZED_RESOURCES_FOLDER_PATH': 'Runner.app',
          'HOME': temporary.path,
        });
        expect(await File('${destination.path}/model').readAsString(), version);
        expect(await File('${destination.path}/stale').exists(), isFalse);
        await File('${destination.path}/stale').writeAsString('old resource');
      }
    } finally {
      await temporary.delete(recursive: true);
    }
  }, skip: !Platform.isMacOS);

  test('rejects archives with content outside the OCR bundle', () async {
    final temporary = await Directory.systemTemp.createTemp('ocr-archive-test-');
    try {
      await File('${temporary.path}/unexpected').writeAsString('not a bundle');
      final archive = File('${temporary.path}/invalid.zip');
      final zip = await Process.run('/usr/bin/zip', [
        '-q',
        archive.path,
        'unexpected',
      ], workingDirectory: temporary.path);
      expect(zip.exitCode, 0, reason: '${zip.stderr}');
      await expectLater(installer.verifyArchive(archive), throwsFormatException);
    } finally {
      await temporary.delete(recursive: true);
    }
  }, skip: !Platform.isMacOS);

  test('rejects corrupt cached downloads before copying into the app', () async {
    final temporary = await Directory.systemTemp.createTemp('ocr-install-test-');
    try {
      final workspace = Directory('${temporary.path}/ios/Runner.xcworkspace/xcshareddata/swiftpm');
      await workspace.create(recursive: true);
      await File('${workspace.path}/Package.resolved').writeAsString(resolved('9.0.3'));
      final cache = Directory('${temporary.path}/Library/Caches/sbb_data_scanner/ocr/9.0.3');
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
        throwsA(isA<ProcessException>()),
      );
      expect(await Directory('${temporary.path}/build').exists(), isFalse);
    } finally {
      await temporary.delete(recursive: true);
    }
  }, skip: !Platform.isMacOS);
}
