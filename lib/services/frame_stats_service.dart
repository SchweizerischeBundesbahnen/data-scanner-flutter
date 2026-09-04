import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/scheduler.dart';

/// Tracks a plain frames-processed-vs-frames-dropped number for profiling,
/// without needing to eyeball DevTools/Instruments traces.
///
/// Two independent counts are kept:
/// - Camera frames: how many arrived from [CameraController.startImageStream]
///   versus how many were actually handed to the recognition pipeline
///   (the rest were skipped because a previous frame was still processing,
///   or the scanner was paused).
/// - UI frames: how many Flutter frames missed the device's refresh budget
///   ([FrameTiming.totalSpan] longer than one refresh period), i.e. jank.
///
/// A summary is logged via `dart:developer` (visible in `flutter run` output
/// and the DevTools/Instruments console) on every [start]'s `logInterval`,
/// and also emitted as a Timeline instant event so it lines up with the
/// `DataScanner.*` spans on the same trace.
abstract class FrameStatsService {
  static Timer? _logTimer;
  static bool _isSchedulerAttached = false;

  static int _cameraFramesReceived = 0;
  static int _cameraFramesProcessed = 0;
  static int _cameraFramesSkipped = 0;

  static int _uiFramesTotal = 0;
  static int _uiFramesJanky = 0;

  /// Starts collecting statistics. Safe to call multiple times; only the
  /// first call attaches listeners.
  static void start({Duration logInterval = const Duration(seconds: 5)}) {
    if (!_isSchedulerAttached) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
      _isSchedulerAttached = true;
    }
    _logTimer ??= Timer.periodic(logInterval, (_) => _logSummary());
  }

  /// Stops collecting, logs a final summary, and resets all counters.
  static void stop() {
    if (_isSchedulerAttached) {
      SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
      _isSchedulerAttached = false;
    }
    _logTimer?.cancel();
    _logTimer = null;
    _logSummary();
    reset();
  }

  /// Records that a camera frame arrived from the image stream, and whether
  /// it was handed to the recognition pipeline ([processed]) or skipped.
  static void recordCameraFrame({required bool processed}) {
    _cameraFramesReceived++;
    if (processed) {
      _cameraFramesProcessed++;
    } else {
      _cameraFramesSkipped++;
    }
  }

  static void _onFrameTimings(List<FrameTiming> timings) {
    final budget = Duration(microseconds: (1000000 / _refreshRateHz()).round());

    for (final timing in timings) {
      _uiFramesTotal++;
      if (timing.totalSpan > budget) {
        _uiFramesJanky++;
      }
    }
  }

  static double _refreshRateHz() {
    try {
      final refreshRate = SchedulerBinding.instance.platformDispatcher.views.first.display.refreshRate;
      return refreshRate > 0 ? refreshRate : 60;
    } catch (_) {
      return 60;
    }
  }

  static void _logSummary() {
    final skippedPercent = _cameraFramesReceived == 0 ? 0.0 : (_cameraFramesSkipped / _cameraFramesReceived) * 100;
    final jankyPercent = _uiFramesTotal == 0 ? 0.0 : (_uiFramesJanky / _uiFramesTotal) * 100;

    developer.log(
      'camera frames: received=$_cameraFramesReceived processed=$_cameraFramesProcessed '
      'skipped=$_cameraFramesSkipped (${skippedPercent.toStringAsFixed(1)}%) | '
      'UI frames: total=$_uiFramesTotal janky=$_uiFramesJanky (${jankyPercent.toStringAsFixed(1)}%)',
      name: 'DataScanner.frameStats',
    );

    developer.Timeline.instantSync(
      'DataScanner.frameStats',
      arguments: {
        'cameraFramesReceived': _cameraFramesReceived,
        'cameraFramesProcessed': _cameraFramesProcessed,
        'cameraFramesSkipped': _cameraFramesSkipped,
        'uiFramesTotal': _uiFramesTotal,
        'uiFramesJanky': _uiFramesJanky,
      },
    );
  }

  /// Resets all counters. Called automatically by [stop].
  static void reset() {
    _cameraFramesReceived = 0;
    _cameraFramesProcessed = 0;
    _cameraFramesSkipped = 0;
    _uiFramesTotal = 0;
    _uiFramesJanky = 0;
  }
}
