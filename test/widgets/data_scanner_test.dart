import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_data_scanner/sbb_data_scanner.dart';

void main() {
  const cameraChannel = MethodChannel('plugins.flutter.io/camera');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      cameraChannel,
      (call) async => call.method == 'availableCameras' ? <Object>[] : null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(cameraChannel, null);
  });

  group('DataScanner', () {
    testWidgets('stops observing its route after the route is popped', (tester) async {
      final routeObserver = RouteObserver<ModalRoute>();
      final navigatorKey = GlobalKey<NavigatorState>();
      final scannerRoute = MaterialPageRoute<void>(
        builder: (_) => DataScanner<String>(
          scannerConfiguration: DataScannerConfiguration(
            processors: [],
            extractors: [],
            onError: (_) {},
            routeObserver: routeObserver,
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(navigatorKey: navigatorKey, navigatorObservers: [routeObserver], home: const SizedBox()),
      );
      navigatorKey.currentState!.push(scannerRoute);
      await tester.pumpAndSettle();

      expect(routeObserver.debugObservingRoute(scannerRoute), isTrue);

      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(routeObserver.debugObservingRoute(scannerRoute), isFalse);
    });
  });
}
