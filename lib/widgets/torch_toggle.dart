import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sbb_data_scanner/drawables/flashlight_off_drawable.dart';
import 'package:sbb_data_scanner/drawables/flashlight_on_drawable.dart';

/// Shows a toggle button to toggle the camera flash in torch mode.
class TorchToggle extends StatefulWidget {
  const TorchToggle({
    Key? key,
    required this.cameraController,
    this.alignment = Alignment.bottomCenter,
    this.margin = const EdgeInsets.all(32),
  }) : super(key: key);

  /// The camera controller 'owns' the camera and is used to set the `FlashMode`
  final CameraController cameraController;

  /// Alignment of the toggle
  final Alignment alignment;

  /// Margin of the toggle
  final EdgeInsetsGeometry margin;

  @override
  State<TorchToggle> createState() => _TorchToggleState();
}

class _TorchToggleState extends State<TorchToggle> {
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _toggleFlashMode();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: Padding(
        padding: widget.margin,
        child: FloatingActionButton(
          onPressed: () => _updateTorch(),
          foregroundColor: Colors.transparent,
          backgroundColor: _torchOn ? Colors.white : Color.fromRGBO(0, 0, 0, 0.2),
          shape: CircleBorder(side: BorderSide(color: Colors.white)),
          elevation: 0,
          child: _torchOn ? FlashlightOnDrawable() : FlashlightOffDrawable(),
        ),
      ),
    );
  }

  void _updateTorch() {
    _torchOn = !_torchOn;
    if (mounted) setState(() {});
    _toggleFlashMode();
  }

  /// Enable flash, handle CameraException which happens on certain devices.
  /// In case of exception, set button back to disabled.
  Future<void> _toggleFlashMode() async {
    try {
      await widget.cameraController.setFlashMode(_torchOn ? FlashMode.torch : FlashMode.off);
    } on CameraException catch (_) {
      setState(() => _torchOn = false);
    }
  }
}
