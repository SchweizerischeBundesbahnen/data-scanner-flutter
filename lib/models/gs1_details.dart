import 'package:sbb_data_scanner/extractors/gs1_details_extractor.dart';
import 'package:sbb_data_scanner/models/localized_string.dart';

/// Holds information about gs1 digits.
class GS1Description {
  /// The described digits.
  final String digits;

  /// Description of [digits]. Is `null` when no description matches [digits].
  final LocalizedString? description;

  GS1Description(this.digits, this.description);

  @override
  String toString() => '{digits: $digits, description: $description}';
}

/// Contains details about the meaning behind a GS1 code.
class GS1Details {
  /// The full GS1 code.
  final String gs1Code;

  /// The normalized GS1 code.
  String get gs1Normalized => gs1Code.replaceAll(RegExp(r'\D'), '');

  /// The raw value which was extracted. Can contain special characters like <GS>
  /// (group separator ASCII#29)
  final String rawValue;

  /// The [GS1Type] of the [GS1Details] instance. Is `null` if the type couldn't
  /// be determined.
  final GS1Type? gs1type;

  /// The GS1 code split into its different segments.
  final List<GS1Description> descriptions;

  GS1Details({
    required this.gs1Code,
    required this.rawValue,
    required this.gs1type,
    required this.descriptions,
  });

  /// Prints an object string. Use this instead of [GS1Details.toString].
  String toObjectString() => '{gs1Code: $gs1Code, gs1Values: $descriptions}';

  /// Used in combination with generic types to ensure it can be properly
  /// displayed in e.g. [DetectionOutlineConfig] labels. Use
  /// [GS1Details.toObjectString] for printing the object string.
  @override
  String toString() => gs1Code;
}
