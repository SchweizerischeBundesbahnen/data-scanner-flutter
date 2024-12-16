import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sbb_data_scanner/services/camera_service.dart';

/// Creates a [CameraController] and passes it into [builder].
class CameraBuilder extends StatefulWidget {
  const CameraBuilder({
    Key? key,
    required this.builder,
    this.onImageReceived,
    this.onPermissionDenied,
    this.onError,
    this.onZoomChanged,
    this.enableZoom = false,
  }) : super(key: key);

  /// Widget to receive the [CameraController].
  final Widget Function(BuildContext, CameraController) builder;

  /// Executed when [CameraController.startImageStream] emits a new image.
  final Function(CameraImage, CameraDescription)? onImageReceived;

  /// Executed when the camera cannot be started due to lack of permissions.
  final Function()? onPermissionDenied;

  /// Executed when any other [CameraException] is thrown. Good luck, because they
  /// are [apparently not documented](https://github.com/flutter/flutter/issues/69298).
  final Function(String)? onError;

  final Function(double)? onZoomChanged;
  final bool enableZoom;

  @override
  State<CameraBuilder> createState() => _CameraBuilderState();
}

class _CameraBuilderState extends State<CameraBuilder>
    with WidgetsBindingObserver {
  /// Controls the device's cameras.
  CameraController? _cameraController;
  late Completer<void> _cameraControllerCompleter;
  static List<CameraController> disposableControllers = [];
  static int activeCameras = 0;

  final _minScaleFactorDiff = 0.01;
  // this has to be set because older iPhones have a max zoom of 118.1
  final _absoluteMaxZoom = 10;
  double _minZoom = 1;
  double _maxZoom = 1;
  double _zoom = 1.0;
  double _scaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    activeCameras++;
    _cameraControllerCompleter = Completer<void>();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    activeCameras--;
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera(updateState: true);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Creates a new [CameraController] and attaches [widget.onImageReceived] to it.
  Future<void> _initializeCamera() async {
    if (_cameraControllerCompleter.isCompleted) return;
    final CameraController? oldController = _cameraController;

    // dispose and reset old camera instance
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      _cameraController = null;
      await oldController.dispose();
    }

    // create and setup new camera instance
    final CameraDescription description =
        await CameraService.getCamera(CameraLensDirection.back);

    final cameraController = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );

    // initialize cameraController
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          if (widget.onPermissionDenied != null) widget.onPermissionDenied!();
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          if (widget.onPermissionDenied != null) widget.onPermissionDenied!();
          break;
        case 'CameraAccessRestricted':
          // iOS only
          if (widget.onPermissionDenied != null) widget.onPermissionDenied!();
          break;
        case 'cameraPermission':
          // Android & web only
          if (widget.onPermissionDenied != null) widget.onPermissionDenied!();
          break;
        default:
          if (widget.onError != null)
            widget.onError!('${e.code}: ${e.description}');
          break;
      }
    }

    // start image stream only if the controller is initialized
    if (cameraController.value.isInitialized) {
      // get zoom level only if the controller is initialized
      if (widget.enableZoom) {
        _maxZoom = await cameraController.getMaxZoomLevel();
        _minZoom = await cameraController.getMinZoomLevel();
      }

      try {
        await cameraController.startImageStream(
          (image) {
            widget.onImageReceived?.call(image, description);
          },
        );
      } on CameraException catch (e) {
        if (widget.onError != null)
          widget.onError!('${e.code}: ${e.description}');
      }
    }

    _cameraController = cameraController;

    if (mounted) {
      setState(() {});
    }
    if (!_cameraControllerCompleter.isCompleted)
      _cameraControllerCompleter.complete();

    return _cameraControllerCompleter.future;
  }

  /// Disposes of the [CameraController].
  Future<void> _stopCamera({bool updateState = true}) async {
    _cameraControllerCompleter.future.then((value) async {
      CameraController? currentCameraController = _cameraController;
      if (currentCameraController != null) {
        _cameraController = null;
        if (currentCameraController.value.isInitialized &&
            currentCameraController.value.isStreamingImages) {
          await currentCameraController.stopImageStream();
        }

        // Only dispose the controller if we have no active Cameras, as it also disposes the native Camera
        if (activeCameras <= 0) {
          currentCameraController.dispose();
          while (disposableControllers.isNotEmpty) {
            var controller = disposableControllers.removeAt(0);
            controller.dispose();
          }
        } else {
          disposableControllers.add(currentCameraController);
        }
      }
      if (mounted && updateState) {
        setState(() {});
      }
    }).whenComplete(() => _cameraControllerCompleter = Completer<void>());
  }

  bool _isScaleFactorValid(double scaleFactor) =>
      scaleFactor >= _minZoom && scaleFactor <= _maxZoom && scaleFactor <= _absoluteMaxZoom;

  bool _isScaleFactorDiffLargeEnough(double newScaleFactor) =>
      _scaleFactor - newScaleFactor > _minScaleFactorDiff ||
      _scaleFactor - newScaleFactor < -_minScaleFactorDiff;

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return SizedBox.shrink();
    }

    if (widget.enableZoom) {
      return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: (details) {
            _zoom = _scaleFactor;
          },
          onScaleUpdate: (details) {
            final newScaleFactor = _zoom * details.scale;
            if (_isScaleFactorDiffLargeEnough(newScaleFactor) &&
                _isScaleFactorValid(newScaleFactor)) {
              _scaleFactor = newScaleFactor;
              _cameraController!.setZoomLevel(_scaleFactor);
              if (widget.onZoomChanged != null) {
                widget.onZoomChanged!(_scaleFactor);
              }
            }
          },
          child: widget.builder(context, _cameraController!));
    } else {
      return widget.builder(context, _cameraController!);
    }
  }
}
