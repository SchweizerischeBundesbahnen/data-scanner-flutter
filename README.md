This package allows the recognition of optical encoded information related to SBB use cases in your
Flutter application. It is built on top of [google_mlkit] and runs solely on-device.

#### Table Of Contents

<details>
<summary>Click to expand</summary>

- [Getting-Started](#getting-started)
    - [Supported platforms](#supported-platforms)
    - [Preconditions](#preconditions)
    - [In Code Usage](#in-code-usage)
- [Documentation](#documentation)
    - [Features](#features)
    - [DataScanner Configuration](#datascanner-configuration)
    - [Vision Processors](#vision-processors)
    - [Extractors](#extractors)
      - [Custom Extractors](#custom-extractors)
- [License](#license)
- [Contributing](#contributing)
  - [Maintainer](#maintainer)
  - [Credits](#credits)
  - [Coding Standards](#coding-standards)
  - [Code of Conduct](#code-of-conduct)

</details>

<a id="Getting-Started"></a>

## Getting-Started

<a name="supported-platforms"></a>

#### Supported platforms

<div id="supported_platforms">
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android badge"/>
  <img src="https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS badge">
</div>

<a name="preconditions"></a>

#### Preconditions

This package uses the Flutter [Camera] plugin to access the device camera.
Make sure to follow their installation instructions.

#### In Code Usage

After importing the library, you can add a `DataScanner` to your widget tree.
You can control its size by wrapping it in a `SizedBox` for example.
If there are no size constraints (e.g. in a `Row` or `Column`), the `DataScanner` will not exceed
the screen's width and/or height (depending on orientation).

```dart
SizedBox(
  height: 250,
  width: 400,
  child: DataScanner( /* ... */ ),
)
```

If you want a full-page scanner, you can use the `DataScannerPage` widget instead.

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => DataScannerPage( /* ... */ ),
  ),
);
```

<a id="Documentation"></a>

## Documentation

#### Features

| Feature                                   | iOS                | Android            |
| ----------------------------------------- | ------------------ | ------------------ |
| **O**ptical **C**haracter **R**ecognition | :white_check_mark: | :white_check_mark: |
| Barcode Scanning                          | :white_check_mark: | :white_check_mark: |
| QR Code Scanning                          | :white_check_mark: | :white_check_mark: |
| UIC Number recognition                    | :white_check_mark: | :white_check_mark: |


#### DataScanner Configuration

You can configure the `DataScanner` by passing a `DataScannerConfiguration<T>` into it, where `T` stands for whichever type a successful extraction will return. This will be covered in detail in the [Extractors](#extractors) section, but is commonly inferred by the compiler. Almost all fields have default values, the exceptions being the required values [`processor`](#vision-processors) and [`extractor`](#extractors) which will be covered in their respective sections.

```dart
DataScanner(
  scannerConfiguration: DataScannerConfiguration<T>(
    processors: // Covered in their own section
    extractors: // Covered in their own section

    routeObserver: RouteObserver<ModalRoute>(),

    onExtracted: (T value) {
      // Called for every extracted value which is
      // a) inside the detection area,
      // b) not null, and
      // c) not equal to the previously extracted value
    },

    onPermissionDenied: () {
      // Called when the app does not have camera permissions
    },

    onError: (String error) {
      // Called when the library encounters any other camera error
    },

    showTorchToggle: true,
    torchToggleMargin: EdgeInsets.all(32),
    torchToggleAlignment: Alignment.bottomCenter,

    showOverlay: true,
    upperHelper: Text('Appears above the detection area'),
    lowerHelper: Text('Appears below the detection area'),

    detectionAreaHeight: 75,
    detectionAreaWidth: 250,
    detectionAreaMode: DetectionAreaMode.containsRect,

    detectionOutline: DetectionOutlineConfig(
      margin: 5,
      padding: 10,

      activeOutlineColor: Colors.green,
      inactiveOutlineColor: Colors.grey,
      outlineWidth: 2,
      cornerRadius: 5,

      enableLabel: true,
      labelColor: Colors.white,
      labelSize: 12,
      labelPosition: DetectionLabelPosition.bottomLeft,
    ),

    enableZoom: true,
    onZoomChanged: (double zoom) {
      // is called if zoom changes with a minimum change sensitivity of 0.01
    }
  ),
)
```

#### Vision Processors

The purpose of vision processors is to detect elements in an image and return their value and position relative to an origin point (usually the top left corner). The library ships with three preconfigured vision processors, all based on [Google ML Kit](https://pub.dev/packages/google_ml_kit):

- [`TextRecognitionVisionProcessor`](#text-recognition)
- [`OneDimensionalBarcodeVisionProcessor`](#one-dimensional-barcode-scanning)
- [`TwoDimensionalBarcodeVisionProcessor`](#two-dimensional-barcode-scanning)

Additionally, it is possible create your own custom vision processor by implementing the `VisionProcessor` interface.
This allows the library to also detect elements other than text, QR-codes and barcodes - see [Example Custom Processor](#vision-processors-custom).

<a name="vision-processors-text"></a>
*Text*

The library's corresponding vision processor for recognizing text in images is named `TextRecognitionVisionProcessor` 
and currently only supports the Latin script.
If you need to scan for a different script, please contact a [maintainer](#overview).
The vision processor takes no parameters:

```dart
DataScanner(
  scannerConfiguration: DataScannerConfiguration(
    // ...
    processors: [
      TextRecognitionVisionProcessor(),
    ],
  ),
)
```

<a name="vision-processors-barcode-one"></a>
*One Dimensional Barcode*

The library's corresponding vision processor for 1-D barcodes (e.g. as you'd find on a carton of milk) is named `OneDimensionalBarcodeVisionProcessor` and takes no parameters:

```dart
DataScanner(
  scannerConfiguration: DataScannerConfiguration(
    // ...
    processors: [
      OneDimensionalBarcodeVisionProcessor(),
    ],
  ),
)
```

<a name="vision-processors-barcode-two"></a>
*Two Dimensional Barcode*

The library's corresponding vision processor for 2-D barcodes (e.g. classic QR-codes or data matrices) is named `TwoDimensionalBarcodeVisionProcessor` and takes no parameters:

```dart
DataScanner(
  scannerConfiguration: DataScannerConfiguration(
    // ...
    processors: [
      TwoDimensionalBarcodeVisionProcessor(),
    ],
  ),
)
```

<a name="vision-processors-custom"></a>
*Example Custom Processor*


```dart
abstract class VisionProcessor {
  Future<Map<Rect, String?>> getBoundingBoxes({
    required CameraImage image,
    required int imageRotation,
  });
}
```

#### Extractors

An extractor takes the values detected by the vision processor,
and tries to extract data in a certain format (like URLs, [UIC Number]s or [GS1 codes]).
At the same time, it also works as a filter, since detected values which to not match the given format are dismissed.
The library ships with three preconfigured extractors, which can be supplied to the `DataScannerConfiguration` via the 
`extractors` parameter.


| Extractor Name      | Return Type (\<T\> of DataScannerConfiguration) | Note                                                                                                          |
| ------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| RawTextExtractor    | String?                                         | Only for unit testing                                                                                         |
| UICDetailsExtractor | UICDetails?                                     | This extractor extracts the value of [UIC number]s and provides information and detailed descriptions for it. |
| GS1DetailsExtractor | GS1Details?                                     | This extractor extracts the value of [GS1 codes] and provides information and detailed descriptions for it.   |

Exemplary `UICDetailsExtractor` implementation:

```dart
DataScanner(
  scannerConfiguration: DataScannerConfiguration<UICDetails>(
    // ...
    extractors: [
      UICDetailsExtractor( /* ... */ ),
    ],
  ),
)
```

##### Custom Extractors

But what about URLs, phone numbers, and brands owned by Nestlé, etc.?
Fear not, it's quite simple to extract these kind of formats.
Simply implement the `Extractor<T>` interface, and you're good to go.

```dart
abstract class Extractor<T> {
  T? extract(String? input);
}
```

The `extract` method must return a nullable type. So, when do we return `null`?
It's simple: When the value cannot be extracted due to formatting, missing components in `input`, or an error.
This causes the `ScannerConfiguration.onExracted` to not be fired, as the detected value has an invalid format.


For example, here is a simple `CompoundSentenceExtractor` which only extracts values which are a compund sentence,
as indicated by a comma and trailing period.

```dart
class CompoundSentenceExtractor implements Extractor<String> {
  String? extract(String? input) {
    if (input == null) return null;

    final containsComma = input.contains(',');
    final isSentence = input.endsWith('.');

    // Why yes, of course ",." is a valid compound sentence!
    return containsComma && isSentence ? input : null;
  }
}
```

You can now use your own extractor:

```dart
DataScanner(
  scannerConfiguration: DataScannerConfiguration<String>(
    // ...
    extractors: [
      CompoundSentenceExtractor(),
    ],
  ),
)
```


<a id="License"></a>

## License

This project is licensed under [MIT](LICENSE).

<a id="Contributing"></a>

## Contributing

This repository includes a [CONTRIBUTING.md](CONTRIBUTING.md) file that outlines how to contribute to the project,
including how to submit bug reports, feature requests, and pull requests.

<a id="maintainer"></a>

### Maintainer

- [Loris Sorace](https://github.com/soracel)

<a id="credits"></a>

### Credits
In addition to the contributors on Github, we thank the following people for their work on previous versions:

- Ulrich Raab (previous maintainer)

<a id="coding-standards"></a>

### Coding Standards

See [CODING_STANDARDS.md](CODING_STANDARDS.md).

<a id="code-of-conduct"></a>

### Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).


[Camera]: https://pub.dev/packages/camera
[UIC number]: https://en.wikipedia.org/wiki/UIC_wagon_numbers
[GS1 codes]: https://en.wikipedia.org/wiki/GS1#Barcodes
[google_mlkit]: https://developers.google.com/ml-kit