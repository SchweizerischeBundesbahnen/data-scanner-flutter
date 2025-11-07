import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:sbb_data_scanner/extensions/_extensions.dart';
import 'package:sbb_data_scanner/sbb_data_scanner.dart';
import 'package:sbb_data_scanner/widgets/camera_builder.dart';
import 'package:sbb_data_scanner/widgets/camera_overlay.dart';
import 'package:sbb_data_scanner/widgets/sized_camera_preview.dart';
import 'package:sbb_data_scanner/widgets/torch_toggle.dart';
import 'package:sbb_data_scanner/widgets/zoom.dart';

/// Defines how the element-rects should relay with the detection area defined by [DataScannerConfiguration.detectionAreaHeight] and [DataScannerConfiguration.detectionAreaWidth]
/// - [containsRect] : the element-rect must be completely inside the detection area
/// - [containsHorizontally] : the element-rect must be horizontally inside the detection area.
/// - [containsVertically] : the element-rect must be vertically inside the detection area.
/// - [intersects] : the element-rect must intersect with the detection area.
enum DetectionAreaMode { containsRect, containsHorizontally, containsVertically, intersects }

/// Holds the configuration for a [DataScanner].
class DataScannerConfiguration<T> {
  /// [VisionProcessor]s to be used.
  final List<VisionProcessor> processors;

  /// [Extractor]s to be used.
  final List<Extractor<T>> extractors;

  /// Required to properly suspend the scanner when navigating.
  final RouteObserver<ModalRoute> _routeObserver;

  /// Callback to be called when text was extracted from an image.
  final OnExtracted<T>? onExtracted;

  /// Executed when the camera cannot be started due to lack of permissions.
  final Function()? onPermissionDenied;

  /// Executed when any other [CameraException] is thrown. Good luck, because they
  /// have apparently been left completely
  /// [undocumented](https://github.com/flutter/flutter/issues/69298) :)
  final Function(String)? onError;

  /// Executed when the zoom is changed.
  final Function(double)? onZoomChanged;

  /// Enable zoom trough pinch.
  final bool enableZoom;

  /// Height of the detection area in which elements should be detected.
  /// Defaults to `64`.
  final double detectionAreaHeight;

  /// Width of the detection area in which elements should be detected.
  /// Defaults to the maximum availale width of the widget minus a margin of
  /// `32` left and right.
  final double? detectionAreaWidth;

  /// Defines
  final DetectionAreaMode detectionAreaMode;

  /// If [showOverlay] is enabled, this widget will be displayed directly above
  /// the detection area.
  final Widget? upperHelper;

  /// If [showOverlay] is enabled, this widget will be displayed directly below
  /// the detection area.
  final Widget? lowerHelper;

  /// Whether to show the scanner overlay. Defaults to `true`.
  final bool showOverlay;

  /// Whether to show the torch toggle. Defaults to `false`.
  final bool showTorchToggle;

  /// Where to position the torch toggle. Defaults to [Alignment.bottomCenter]
  final Alignment torchToggleAlignment;

  /// Outside spacing of the torch toggle.
  final EdgeInsets torchToggleMargin;

  /// Configuration for displaying outlines around detected visuals. If nothing
  /// is set, no outlines will be displayed.
  final DetectionOutlineConfig? detectionOutline;

  DataScannerConfiguration({
    required this.processors,
    required this.extractors,
    this.onExtracted,
    this.onPermissionDenied,
    this.onError,
    this.onZoomChanged,
    this.enableZoom = false,
    this.detectionAreaHeight = 64,
    this.detectionAreaWidth,
    this.detectionAreaMode = DetectionAreaMode.containsRect,
    this.upperHelper,
    this.lowerHelper,
    this.showOverlay = true,
    this.showTorchToggle = false,
    this.torchToggleAlignment = Alignment.bottomCenter,
    this.torchToggleMargin = const EdgeInsets.all(32),
    this.detectionOutline,
    RouteObserver<ModalRoute>? routeObserver,
  }) : _routeObserver = routeObserver ?? RouteObserver();
}

/// Displays a [CameraPreview] and detects content as configured in [scannerConfiguration].
class DataScanner<T> extends StatefulWidget {
  /// Configuration which the [DataScanner] should use.
  final DataScannerConfiguration<T> scannerConfiguration;

  const DataScanner({Key? key, required this.scannerConfiguration}) : super(key: key);

  @override
  _DataScannerState createState() => _DataScannerState<T>(scannerConfiguration: scannerConfiguration);
}

class _DataScannerState<T> extends State<DataScanner> with RouteAware {
  /// Whether detection is still in progress and should be skipped in the next
  /// frame.
  bool _isDetecting = false;

  /// Whether the scanner is paused.
  bool _paused = false;

  /// Scaled, positioned elements and their stringified content.
  Map<Rect, String>? _detectedElements;

  /// The previous scanning result.
  String? _previousResult;

  /// Runtime size of the [DataScanner]. If no constraints are set, it defaults to
  /// a 16:9 ration, capping the width (in portrait mode) or the height (in
  /// landspace mode) of the screen.
  Size? _calculatedSize;

  /// Saves the previous device orientation, in case the device is rotated.
  Orientation? _previousOrientation;

  /// Configuration for the [DataScanner].
  final DataScannerConfiguration<T> scannerConfiguration;

  /// Default margin for the detection area if no width is set.
  final _defaultDetectionAreaMargin = 32;

  // ValueNotifier for the zoom level.
  final ValueNotifier<double> _zoomNotifier = ValueNotifier<double>(1.0);

  _DataScannerState({required this.scannerConfiguration});

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scannerConfiguration._routeObserver.subscribe(this, ModalRoute.of(context)!);
    });
    super.initState();
  }

  @override
  void deactivate() {
    _pause();
    super.deactivate();
  }

  @override
  void didPopNext() {
    _unpause();
    super.didPopNext();
  }

  @override
  void didPushNext() {
    _pause();
    super.didPushNext();
  }

  void _pause() {
    _paused = true;
    _detectedElements = {};
  }

  void _unpause() {
    _paused = false;
    _detectedElements = {};
  }

  /// Analyzes bounding boxes and extracts the text from the ones which are
  /// within the area of [HoleBox]. Skips [scannerConfiguration.onExtracted]
  /// when the same element is scanned at least twice in a row.
  Future<void> _onImageReceived(BuildContext context, CameraImage image, CameraDescription description) async {
    if (_paused || _isDetecting || !mounted) return;

    _isDetecting = true;

    // CameraDescription.sensorOrientation doesn't always report the orientation
    // correctly, so we need to figure it out manually.
    final nativeOrientation = await NativeDeviceOrientationCommunicator().orientation();

    // MediaQuery.orientation doesn't differentiate between up/down left/right,
    // but it has an impact on the camera.
    final orientationDegrees = {
      NativeDeviceOrientation.portraitUp: 90,
      NativeDeviceOrientation.landscapeRight: 180,
      NativeDeviceOrientation.portraitDown: 270,
      NativeDeviceOrientation.landscapeLeft: 0,
      NativeDeviceOrientation.unknown: 90, // assume portraitUp by default
    };

    final rotation = orientationDegrees[nativeOrientation]!;

    Map<Rect, String?> boundingBoxes = {};

    for (final processor in scannerConfiguration.processors) {
      boundingBoxes.addAll(await processor.getBoundingBoxes(image: image, imageRotation: rotation));
    }

    Map<Rect, T?> detectedElements = {};

    for (final extractor in scannerConfiguration.extractors) {
      detectedElements.addAll(boundingBoxes.map((key, value) => MapEntry(key, extractor.extract(value))));
    }

    detectedElements.removeWhere((key, value) => value == null);

    Map<Rect, T> extractedElements = detectedElements.map((key, value) => MapEntry(key, value!));

    // Make absolutely sure the scanner is still active before accessing context
    if (_paused) return;

    Size orientedImageSize;

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      orientedImageSize = image.height > image.width
          ? Size(image.width.toDouble(), image.height.toDouble())
          : Size(image.height.toDouble(), image.width.toDouble());
    } else {
      orientedImageSize = image.height > image.width
          ? Size(image.height.toDouble(), image.width.toDouble())
          : Size(image.width.toDouble(), image.height.toDouble());
    }

    // Whether the widget size is horizontally more narrow than the image
    final isNarrow = _calculatedSize!.aspectRatio < orientedImageSize.width / orientedImageSize.height;

    // If the widget is narrow, use the height to scale
    final scaleFactor =
        1 /
        (isNarrow
            ? orientedImageSize.height / _calculatedSize!.height
            : orientedImageSize.width / _calculatedSize!.width);

    final scaledElements = extractedElements.map((key, value) => MapEntry(key.scale(scaleFactor), value));

    final scaledImageBounds = Rect.fromPoints(
      Offset.zero,
      Offset(orientedImageSize.width * scaleFactor, orientedImageSize.height * scaleFactor),
    );

    final previewBounds = Rect.fromPoints(
      Offset.zero,
      Offset(_calculatedSize!.width, _calculatedSize!.height),
    ).deflate(scannerConfiguration.detectionOutline?.padding ?? 0);

    final detectionAreaBounds = Rect.fromCenter(
      center: previewBounds.center,
      width: scannerConfiguration.detectionAreaWidth ?? _calculatedSize!.width - (2 * _defaultDetectionAreaMargin),
      height: scannerConfiguration.detectionAreaHeight,
    ).deflate(scannerConfiguration.detectionOutline?.padding ?? 0);

    final deltaY = (scaledImageBounds.height - _calculatedSize!.height) / -2;
    final deltaX = (scaledImageBounds.width - _calculatedSize!.width) / -2;

    final translatedElements = scaledElements.map((key, value) => MapEntry(key.translate(deltaX, deltaY), value));

    translatedElements.removeWhere((key, value) => !_isWithinArea(previewBounds, key));

    if (mounted) {
      setState(() => _detectedElements = translatedElements.map((key, value) => MapEntry(key, value.toString())));
    }

    translatedElements.removeWhere((key, value) => !_isWithinArea(detectionAreaBounds, key));

    if (translatedElements.isNotEmpty) {
      final result = translatedElements[translatedElements.keys.first]!;
      if (result.toString() != _previousResult.toString()) {
        scannerConfiguration.onExtracted?.call(result);
        _previousResult = result.toString();
      }
    }

    _isDetecting = false;
  }

  bool _isWithinArea(Rect area, Rect element) {
    switch (scannerConfiguration.detectionAreaMode) {
      case DetectionAreaMode.containsRect:
        return area.containsRect(element);
      case DetectionAreaMode.containsHorizontally:
        return area.left <= element.left && area.right >= element.right;
      case DetectionAreaMode.containsVertically:
        return area.top <= element.top && area.bottom >= element.bottom;
      case DetectionAreaMode.intersects:
        return !area.intersect(element).isEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);

    if (_calculatedSize == null || _previousOrientation != screen.orientation) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double cappedWidth;
          double cappedHeight;

          if (screen.orientation == Orientation.portrait) {
            cappedWidth = constraints.maxWidth != double.infinity ? constraints.maxWidth : screen.size.width;

            cappedHeight = constraints.maxHeight != double.infinity ? constraints.maxHeight : (cappedWidth / 9) * 16;
          } else {
            cappedWidth = constraints.maxWidth != double.infinity ? constraints.maxWidth : screen.size.height;

            cappedHeight = constraints.maxHeight != double.infinity ? constraints.maxHeight : (cappedWidth / 16) * 9;
          }

          Size cappedSize = Size(cappedWidth, cappedHeight);

          SchedulerBinding.instance.addPostFrameCallback(
            (_) => setState(() {
              _calculatedSize = cappedSize;
              _previousOrientation = screen.orientation;
            }),
          );

          return SizedBox.shrink();
        },
      );
    }

    if (_paused) {
      return SizedBox.shrink();
    }

    final detectionAreaRect = Rect.fromCenter(
      center: _calculatedSize!.center(Offset.zero),
      width: scannerConfiguration.detectionAreaWidth ?? _calculatedSize!.width - (2 * _defaultDetectionAreaMargin),
      height: scannerConfiguration.detectionAreaHeight,
    );

    return CameraBuilder(
      onImageReceived: (image, description) => _onImageReceived(context, image, description),
      onPermissionDenied: scannerConfiguration.onPermissionDenied,
      onError: scannerConfiguration.onError,
      onZoomChanged: (zoom) {
        _zoomNotifier.value = zoom;
        scannerConfiguration.onZoomChanged?.call(zoom);
      },
      enableZoom: scannerConfiguration.enableZoom,
      builder: (context, cameraController) {
        return SizedBox(
          width: _calculatedSize!.width,
          height: _calculatedSize!.height,
          child: Stack(
            children: [
              SizedCameraPreview(size: _calculatedSize!, cameraController: cameraController),
              if (scannerConfiguration.showOverlay)
                CameraOverlay(
                  previewSize: _calculatedSize!,
                  detectionAreaBoundingBox: detectionAreaRect,
                  upperHelper: scannerConfiguration.upperHelper,
                  lowerHelper: scannerConfiguration.lowerHelper,
                ),
              if (scannerConfiguration.detectionOutline != null && _detectedElements?.isNotEmpty == true)
                DetectionOutline(
                  boundingBoxes: _detectedElements!,
                  detectionAreaBoundingBox: detectionAreaRect,
                  outlineConfig: scannerConfiguration.detectionOutline!,
                ),
              if (scannerConfiguration.showTorchToggle)
                TorchToggle(
                  cameraController: cameraController,
                  alignment: scannerConfiguration.torchToggleAlignment,
                  margin: scannerConfiguration.torchToggleMargin,
                ),
              if (scannerConfiguration.enableZoom)
                ValueListenableBuilder<double>(
                  valueListenable: _zoomNotifier,
                  builder: (context, zoom, child) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 32.0, left: 32.0),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Zoom(zoom: zoom),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
