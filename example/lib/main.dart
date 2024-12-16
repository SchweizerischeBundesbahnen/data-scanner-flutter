import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sbb_data_scanner/sbb_data_scanner.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver();

void main() => runApp(DataScannerExample());

class DataScannerExample extends StatelessWidget {
  const DataScannerExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Scanner Example',
      themeMode: ThemeMode.system,
      theme: SBBTheme.light(),
      darkTheme: SBBTheme.dark(),
      home: MainPage(),
      navigatorObservers: [routeObserver],
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final double _spacing = 16;

  bool _scannerActive = false;

  final TextRecognitionVisionProcessor _textRecognitionProcessor =
      TextRecognitionVisionProcessor();
  final TwoDimensionalBarcodeVisionProcessor _twoDimensionalBarcodeProcessor =
      TwoDimensionalBarcodeVisionProcessor();
  final OneDimensionalBarcodeVisionProcessor _oneDimensionalBarcodeProcessor =
      OneDimensionalBarcodeVisionProcessor();

  final _rawTextExtractor = RawTextExtractor();
  final _uicDetailsStrictExtractor = UICDetailsExtractor(
    uicDetectionMode: UICDetectionMode.strict,
  );
  final _uicDetailsLooseExtractor = UICDetailsExtractor(
    uicDetectionMode: UICDetectionMode.loose,
  );
  final _gs1DetailsExtractor = GS1DetailsExtractor();
  late Extractor _extractor = _rawTextExtractor;

  late DataScannerConfiguration _scannerConfiguration;

  DetectionAreaMode _detectionAreaMode = DetectionAreaMode.containsRect;
  bool _detectText = true;
  bool _detectOneDimensionalBarcodes = true;
  bool _detectTwoDimensionalBarcodes = true;

  /// Size(0, 0) = fullscreen
  Size _scannerSize = Size(0, 0);
  Size _detectionAreaSize = Size(250, 50);

  TextEditingController _upperHelperTextController = TextEditingController(
    text: 'Point your camera at something',
  );
  TextEditingController _lowerHelperTextController = TextEditingController(
    text: 'lower helper example',
  );

  bool _showDetectionLabels = true;
  bool _showOverlay = true;
  bool _showTorchToggle = true;
  bool _enableZoom = true;

  @override
  Widget build(BuildContext context) {
    _scannerConfiguration = DataScannerConfiguration(
      extractors: [_extractor],
      processors: [
        if (_detectText) _textRecognitionProcessor,
        if (_detectOneDimensionalBarcodes) _oneDimensionalBarcodeProcessor,
        if (_detectTwoDimensionalBarcodes) _twoDimensionalBarcodeProcessor,
      ],
      routeObserver: routeObserver,
      onExtracted: (v) => _onExtracted(v, context),
      onPermissionDenied: () => _onPermissionDenied(context),
      onError: (e) => _onScannerError(e, context),
      upperHelper: _upperHelper(),
      lowerHelper: _lowerHelper(),
      detectionAreaHeight: _detectionAreaSize.height,
      detectionAreaWidth: _detectionAreaSize.width,
      detectionAreaMode: _detectionAreaMode,
      showOverlay: _showOverlay,
      showTorchToggle: _showTorchToggle,
      torchToggleAlignment: Alignment.bottomRight,
      detectionOutline: DetectionOutlineConfig(
        enableLabel: _showDetectionLabels,
      ),
      enableZoom: _enableZoom,
    );

    return Scaffold(
      appBar: SBBHeader(title: 'Data Scanner Example'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(children: [
            SizedBox(height: _spacing),
            _configurationOptions(context),
            SizedBox(height: _spacing * 2),
            _scannerToggleButton(),
            if (!_fullscreenSelected() && _scannerActive) ...[
              SizedBox(height: _spacing * 2),
              _inlineScanner(),
            ],
            SizedBox(height: _spacing * 4),
          ]),
        ),
      ),
    );
  }

  Widget _configurationOptions(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _spacing),
      child: Column(
        children: [
          ..._scanningConfiguration(),
          SizedBox(height: _spacing),
          ..._visualConfiguration(),
        ],
      ),
    );
  }

  List<Widget> _scanningConfiguration() {
    return [
      SBBListHeader(
        'Scanning configuration',
        padding: EdgeInsets.only(left: _spacing, bottom: _spacing / 2),
      ),
      SBBGroup(
        child: Column(children: [
          _processorEnablers(),
          _extractorSelector(),
          _detectionAreaModeSelector(),
          _zoomEnabler(),
        ]),
      ),
    ];
  }

  List<Widget> _visualConfiguration() {
    return [
      SBBListHeader(
        'Visual configuration',
        padding: EdgeInsets.only(left: _spacing, bottom: _spacing / 2),
      ),
      SBBGroup(
        child: Column(children: [
          _detectionLabelEnabler(),
          _overlayEnabler(),
          _torchToggleEnabler(),
          _scannerSizeSelector(context),
          _detectionAreaSizeSelector(),
          _upperHelperTextInput(),
          _lowerHelperTextInput(),
        ]),
      ),
    ];
  }

  Widget _processorEnablers() {
    return Column(children: [
      SBBCheckboxListItem(
        value: _detectText,
        label: 'Enable text recognition',
        secondaryLabel: 'Will detect text in the Latin script.',
        onChanged: _scannerActive
            ? null
            : (enabled) => setState(() => _detectText = enabled!),
      ),
      SBBCheckboxListItem(
        value: _detectOneDimensionalBarcodes,
        label: 'Enable 1-D barcode scanning',
        secondaryLabel:
            'Will detect one-dimensional barcodes, such as you would scan in the store.',
        onChanged: _scannerActive
            ? null
            : (enabled) => setState(
                  () => _detectOneDimensionalBarcodes = enabled!,
                ),
      ),
      SBBCheckboxListItem(
        value: _detectTwoDimensionalBarcodes,
        label: 'Enable 2-D barcode scanning',
        secondaryLabel:
            'Will detect two-dimensional barcodes, such as classic QR codes or data matrices.',
        onChanged: _scannerActive
            ? null
            : (enabled) => setState(
                  () => _detectTwoDimensionalBarcodes = enabled!,
                ),
      ),
    ]);
  }

  Widget _extractorSelector() {
    return SBBSelect<Extractor>(
      label: 'Value detection strategy',
      value: _extractor,
      isLastElement: false,
      onChanged: _scannerActive
          ? null
          : (extractor) => setState(() => _extractor = extractor!),
      items: [
        SelectMenuItem(
          value: _rawTextExtractor,
          label: 'Raw text',
        ),
        SelectMenuItem(
          value: _uicDetailsStrictExtractor,
          label: 'UIC number (strict)',
        ),
        SelectMenuItem(
          value: _uicDetailsLooseExtractor,
          label: 'UIC number (loose)',
        ),
        SelectMenuItem(
          value: _gs1DetailsExtractor,
          label: 'GS1',
        ),
      ],
    );
  }

  Widget _detectionAreaModeSelector() {
    return SBBSelect<DetectionAreaMode>(
      label: 'Detection within detection area',
      value: _detectionAreaMode,
      isLastElement: true,
      onChanged: _scannerActive
          ? null
          : (mode) => setState(() => _detectionAreaMode = mode!),
      items: [
        SelectMenuItem(
          value: DetectionAreaMode.containsRect,
          label: 'Element fully contained',
        ),
        SelectMenuItem(
          value: DetectionAreaMode.intersects,
          label: 'Element intersecting',
        ),
        SelectMenuItem(
          value: DetectionAreaMode.containsHorizontally,
          label: 'Element within horizontal bounds',
        ),
        SelectMenuItem(
          value: DetectionAreaMode.containsVertically,
          label: 'Element within vertical bounds',
        ),
      ],
    );
  }

  Widget _zoomEnabler() {
    return SBBCheckboxListItem(
      label: 'Enable zoom',
      secondaryLabel:
          'Displays the zoom level and enables zoom though pinch gesture.',
      value: _enableZoom,
      onChanged: _scannerActive
          ? null
          : (enabled) => setState(
                () => _enableZoom = enabled ?? false,
              ),
    );
  }

  Widget _detectionLabelEnabler() {
    return SBBCheckboxListItem(
      label: 'Enable detection labels',
      secondaryLabel:
          'Displays the contained value when highlighting a detected element.',
      value: _showDetectionLabels,
      onChanged: _scannerActive
          ? null
          : (enabled) => setState(
                () => _showDetectionLabels = enabled ?? false,
              ),
    );
  }

  Widget _overlayEnabler() {
    return SBBCheckboxListItem(
      label: 'Enable overlay',
      secondaryLabel:
          'Darkens the area outside of whats being detected and shows the helper text.',
      value: _showOverlay,
      onChanged: _scannerActive
          ? null
          : (enabled) => setState(
                () => _showOverlay = enabled ?? false,
              ),
    );
  }

  Widget _torchToggleEnabler() {
    return SBBCheckboxListItem(
      label: 'Enable torch toggle',
      secondaryLabel: 'Shows a button to toggle the torch.',
      value: _showTorchToggle,
      isLastElement: true,
      onChanged: _scannerActive
          ? null
          : (enabled) => setState(
                () => _showTorchToggle = enabled ?? false,
              ),
    );
  }

  Widget _scannerSizeSelector(BuildContext context) {
    final screen = MediaQuery.of(context);
    final squareSize = screen.orientation == Orientation.portrait
        ? screen.size.width
        : screen.size.height;

    return SBBSelect<Size>(
      label: 'Scanner size',
      value: _scannerSize,
      onChanged: _scannerActive
          ? null
          : (size) => setState(() => _scannerSize = size!),
      items: [
        SelectMenuItem(
          value: Size(0, 0),
          label: 'Fullscreen',
        ),
        SelectMenuItem(
          value: Size(0, 250),
          label: 'Inline, wide',
        ),
        SelectMenuItem(
          value: Size(squareSize, squareSize),
          label: 'Inline, square',
        ),
        SelectMenuItem(
          value: Size(0, 750),
          label: 'Inline, tall',
        ),
      ],
    );
  }

  Widget _detectionAreaSizeSelector() {
    return SBBSelect<Size>(
      label: 'Detection area size',
      value: _detectionAreaSize,
      onChanged: _scannerActive
          ? null
          : (size) => setState(() => _detectionAreaSize = size!),
      items: [
        SelectMenuItem(
          value: Size(250, 50),
          label: 'Wide',
        ),
        SelectMenuItem(
          value: Size(150, 150),
          label: 'Square',
        ),
        SelectMenuItem(
          value: Size(75, 150),
          label: 'Tall',
        ),
        SelectMenuItem(
          value: Size(double.infinity, double.infinity),
          label: 'Full (deactivate Overlay)',
        ),
      ],
    );
  }

  Widget _upperHelperTextInput() {
    return SBBTextFormField(
      labelText: 'Upper helper text',
      controller: _upperHelperTextController,
      enabled: !_scannerActive,
    );
  }

  Widget _lowerHelperTextInput() {
    return SBBTextFormField(
      labelText: 'Lower helper text',
      controller: _lowerHelperTextController,
      enabled: !_scannerActive,
    );
  }

  Widget _scannerToggleButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _spacing),
      child: SBBPrimaryButton(
        label: _scannerActive ? 'Close scanner' : 'Open scanner',
        onPressed: _toggleScanner,
      ),
    );
  }

  Widget _inlineScanner() {
    return SizedBox(
      height: _scannerSize.height,
      width: _scannerSize.width == 0 ? null : _scannerSize.width,
      child: DataScanner(scannerConfiguration: _scannerConfiguration),
    );
  }

  Padding _upperHelper() {
    return Padding(
      padding: EdgeInsets.only(bottom: _spacing * 2),
      child: Text(
        _upperHelperTextController.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Padding _lowerHelper() {
    return Padding(
      padding: EdgeInsets.only(top: _spacing * 2),
      child: Text(
        _lowerHelperTextController.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  bool _fullscreenSelected() => _scannerSize == Size(0, 0);

  void _toggleScanner() {
    if (!_fullscreenSelected()) {
      setState(() => _scannerActive = !_scannerActive);
    } else {
      if (_scannerActive) {
        setState(() => _scannerActive = false);
        Navigator.of(context).pop();
      } else {
        setState(() => _scannerActive = true);
        Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => DataScannerPage(
                scannerConfiguration: _scannerConfiguration,
              ),
            ))
            .whenComplete(
              () => setState(() => _scannerActive = false),
            );
      }
    }
  }

  void _onExtracted(dynamic value, BuildContext context) {
    if (_scannerActive) {
      _toggleScanner();
    }

    final style = SBBControlStyles.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (value.runtimeType == String) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: isDark ? style.groupBackgroundColor : null,
        content: Row(children: [
          Padding(
            padding: EdgeInsets.only(right: _spacing / 2, bottom: _spacing / 4),
            child: Icon(
              SBBIcons.tick_small,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style.accordionBodyTextStyle?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ]),
      ));
    } else if (value.runtimeType == UICDetails) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: isDark ? style.groupBackgroundColor : null,
        action: SnackBarAction(
          label: 'DETAILS',
          onPressed: () => _showUicDetails(value),
        ),
        content: Row(children: [
          Padding(
            padding: EdgeInsets.only(right: _spacing / 2, bottom: _spacing / 4),
            child: Icon(
              SBBIcons.tick_small,
              color: Colors.white,
            ),
          ),
          Text(
            (value as UICDetails).uicNumber,
            style: style.accordionBodyTextStyle?.copyWith(
              color: Colors.white,
            ),
          ),
        ]),
      ));
    } else if (value.runtimeType == GS1Details) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: isDark ? style.groupBackgroundColor : null,
        action: SnackBarAction(
          label: 'DETAILS',
          onPressed: () => _showGS1Details(value),
        ),
        content: Row(children: [
          Padding(
            padding: EdgeInsets.only(right: _spacing / 2, bottom: _spacing / 4),
            child: Icon(
              SBBIcons.tick_small,
              color: Colors.white,
            ),
          ),
          Text(
            (value as GS1Details).gs1Code,
            style: style.accordionBodyTextStyle?.copyWith(
              color: Colors.white,
            ),
          ),
        ]),
      ));
    }
  }

  void _onPermissionDenied(BuildContext context) {
    SBBToast.of(context).show(message: 'Missing camera permission');
    _toggleScanner();
  }

  void _onScannerError(String error, BuildContext context) {
    SBBToast.of(context).show(message: 'Error: $error');
    _toggleScanner();
  }

  void _showUicDetails(UICDetails uicDetails) {
    final categoryNames = {
      UICCategory.tractionUnit: 'Traction unit',
      UICCategory.passengerCoach: 'Passenger coach',
      UICCategory.freightWagon: 'Freight wagon',
    };

    showSBBModalSheet(
      context: context,
      title: uicDetails.uicNumber,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(_spacing, 0, _spacing, _spacing * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (uicDetails.descriptions.isEmpty)
                  Text('No details available for this UIC number.')
                else ...[
                  SBBListHeader(
                    'Vehicle type',
                    padding: EdgeInsets.only(left: 0, bottom: _spacing / 2),
                  ),
                  Text(categoryNames[uicDetails.uicCategory] ?? 'Unknown'),
                  SizedBox(height: _spacing),
                  SBBListHeader(
                    'Description',
                    padding: EdgeInsets.only(left: 0, bottom: _spacing / 2),
                  ),
                  ...uicDetails.descriptions
                      .map(
                        (description) => Padding(
                          padding: EdgeInsets.only(bottom: _spacing / 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: _spacing * 4,
                                height: _spacing * 1.5,
                                child: Text(
                                  description.digits,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  description.description?.en ?? 'Unknown',
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGS1Details(GS1Details gs1Details) {
    showSBBModalSheet(
      context: context,
      title: gs1Details.gs1Code,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(_spacing, 0, _spacing, _spacing * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (gs1Details.descriptions.isEmpty)
                  Text('No details available for this gs1 code.')
                else ...[
                  SBBListHeader(
                    'Description',
                    padding: EdgeInsets.only(left: 0, bottom: _spacing / 2),
                  ),
                  ...gs1Details.descriptions
                      .map(
                        (description) => Padding(
                          padding: EdgeInsets.only(bottom: _spacing / 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: _spacing * 4,
                                height: _spacing * 1.5,
                                child: Text(
                                  description.digits,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  description.description?.en ?? 'Unknown',
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
