import 'dart:convert';
import 'dart:io';

const bundleName = 'LatinOCRResources.bundle';

Future<void> main() async {
  try {
    await install(Platform.environment);
  } on FileSystemException catch (error) {
    stderr.writeln('error: OCR resources: $error');
    exitCode = 1;
  } on ProcessException catch (error) {
    stderr.writeln('error: OCR resources: $error');
    exitCode = 1;
  } on FormatException catch (error) {
    stderr.writeln('error: OCR resources: ${error.message}');
    exitCode = 1;
  }
}

String requiredSetting(Map<String, String> environment, String name) {
  final value = environment[name];
  if (value == null || value.isEmpty) {
    throw FormatException('Missing $name. Run this command in an Xcode app build phase.');
  }
  return value;
}

String resolvedVersion(String contents) {
  final resolved = jsonDecode(contents);
  if (resolved is! Map || resolved['pins'] is! List) {
    throw const FormatException('Invalid workspace Package.resolved: missing pins.');
  }
  final pins = resolved['pins'] as List;
  final matches = pins.where((pin) => pin is Map && pin['identity'] == 'google-mlkit-swiftpm');
  if (matches.length != 1) {
    throw const FormatException('Expected one google-mlkit-swiftpm pin in Package.resolved.');
  }
  final state = (matches.single as Map)['state'];
  final version = state is Map ? state['version'] : null;
  if (version is! String ||
      !RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+(?:-[0-9A-Za-z.-]+)?(?:\+[0-9A-Za-z.-]+)?$').hasMatch(version)) {
    throw const FormatException(
      'Expected a release version for google-mlkit-swiftpm in Package.resolved. '
      'Branch and revision pins require manual OCR resource configuration.',
    );
  }
  return version;
}

Future<ProcessResult> run(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw ProcessException(executable, arguments, '${result.stdout}\n${result.stderr}', result.exitCode);
  }
  return result;
}

Future<void> verifyArchive(File archive) async {
  final result = await run('/usr/bin/unzip', ['-Z', '-1', archive.path]);
  final entries = const LineSplitter().convert(result.stdout.toString());
  if (entries.isEmpty ||
      !entries.any((entry) => entry.startsWith('$bundleName/') && !entry.endsWith('/')) ||
      entries.any(
        (entry) => !entry.startsWith('$bundleName/') || entry.split('/').contains('..') || entry.contains(r'\'),
      )) {
    throw FormatException('Invalid $bundleName archive: ${archive.path}. Delete the cached archive and retry.');
  }
  await run('/usr/bin/unzip', ['-tq', archive.path]);
}

Future<void> install(Map<String, String> environment) async {
  final sourceRoot = requiredSetting(environment, 'SRCROOT');
  final projectName = requiredSetting(environment, 'PROJECT_NAME');
  final buildDirectory = requiredSetting(environment, 'TARGET_BUILD_DIR');
  final resourcesPath = requiredSetting(environment, 'UNLOCALIZED_RESOURCES_FOLDER_PATH');
  final home = requiredSetting(environment, 'HOME');
  final lockfile = File('$sourceRoot/$projectName.xcworkspace/xcshareddata/swiftpm/Package.resolved');
  final mlKitVersion = resolvedVersion(await lockfile.readAsString());

  final cache = Directory('$home/Library/Caches/sbb_data_scanner/ocr/$mlKitVersion');
  await cache.create(recursive: true);
  final archive = File('${cache.path}/$bundleName.zip');
  if (!await archive.exists()) {
    final download = await cache.createTemp('download-');
    try {
      final temporaryArchive = File('${download.path}/$bundleName.zip');
      stdout.writeln('Downloading OCR resources for ML Kit $mlKitVersion...');
      await run('/usr/bin/curl', [
        '--fail',
        '--location',
        '--silent',
        '--show-error',
        '--retry',
        '3',
        '--connect-timeout',
        '30',
        '--max-time',
        '300',
        '--output',
        temporaryArchive.path,
        'https://github.com/d-date/google-mlkit-swiftpm/releases/download/'
            '$mlKitVersion/$bundleName.zip',
      ]);
      await verifyArchive(temporaryArchive);
      await temporaryArchive.rename(archive.path);
    } finally {
      await download.delete(recursive: true);
    }
  }
  await verifyArchive(archive);

  final extracted = await cache.createTemp('extract-');
  try {
    await run('/usr/bin/unzip', ['-q', archive.path, '-d', extracted.path]);
    final bundle = Directory('${extracted.path}/$bundleName');
    if (!await bundle.exists()) {
      throw const FormatException('Downloaded archive does not contain $bundleName.');
    }
    final destination = Directory('$buildDirectory/$resourcesPath/$bundleName');
    await destination.create(recursive: true);
    await run('/usr/bin/rsync', ['-a', '--delete', '${bundle.path}/', '${destination.path}/']);
    stdout.writeln('Copied $bundleName to ${destination.path}');
  } finally {
    await extracted.delete(recursive: true);
  }
}
