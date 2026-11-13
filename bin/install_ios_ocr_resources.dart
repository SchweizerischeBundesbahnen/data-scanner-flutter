import 'dart:convert';
import 'dart:io';

const mlKitVersion = '9.0.2';
const bundleChecksum = 'c790283599f67708c06fd93de61d96823ce2ad984ad00bfda5922afda0861758';
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

void validateVersion(String contents) {
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
  if (state is! Map || state['version'] != mlKitVersion) {
    throw const FormatException(
      'OCR resources require google-mlkit-swiftpm $mlKitVersion. '
      'Use a compatible sbb_data_scanner version or configure the bundle manually.',
    );
  }
}

Future<ProcessResult> run(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    throw ProcessException(executable, arguments, '${result.stdout}\n${result.stderr}', result.exitCode);
  }
  return result;
}

Future<void> verifyArchive(File archive) async {
  final result = await run('/usr/bin/shasum', ['-a', '256', archive.path]);
  if (!result.stdout.toString().startsWith('$bundleChecksum ')) {
    throw FormatException('Checksum mismatch for ${archive.path}. Delete this cached archive and retry.');
  }
}

Future<void> install(Map<String, String> environment) async {
  final sourceRoot = requiredSetting(environment, 'SRCROOT');
  final projectName = requiredSetting(environment, 'PROJECT_NAME');
  final buildDirectory = requiredSetting(environment, 'TARGET_BUILD_DIR');
  final resourcesPath = requiredSetting(environment, 'UNLOCALIZED_RESOURCES_FOLDER_PATH');
  final home = requiredSetting(environment, 'HOME');
  final lockfile = File('$sourceRoot/$projectName.xcworkspace/xcshareddata/swiftpm/Package.resolved');
  validateVersion(await lockfile.readAsString());

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
