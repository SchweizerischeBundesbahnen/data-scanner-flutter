import 'package:flutter/material.dart';
import 'package:sbb_data_scanner/drawables/sbb_drawable.dart';
import 'package:sbb_data_scanner/widgets/data_scanner.dart';

/// Ready-to-use fullscreen [DataScanner].
class DataScannerPage<T> extends StatelessWidget {
  /// Configuration of the [DataScanner].
  final DataScannerConfiguration<T> scannerConfiguration;

  /// App bar title.
  final Widget? title;

  /// Whether to display the SBB logo.
  final bool showSBBLogo;

  DataScannerPage({
    Key? key,
    required this.scannerConfiguration,
    this.title,
    this.showSBBLogo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: title,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [if (showSBBLogo) SBBLogoDrawable()],
      ),
      body: SizedBox(
        height: screen.size.height,
        width: screen.size.width,
        child: DataScanner(scannerConfiguration: scannerConfiguration),
      ),
    );
  }
}
