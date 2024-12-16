import 'package:sbb_data_scanner/extractors/uic_details_extractor.dart';
import 'package:sbb_data_scanner/models/localized_string.dart';

/// Holds information about UIC digits.
class UICDescription {
  /// The described digits.
  final String digits;

  /// Description of [digits]. Is `null` when no description matches [digits].
  final LocalizedString? description;

  UICDescription(this.digits, this.description);

  @override
  String toString() => '{digits: $digits, description: $description}';
}

/// Contains details about the meaning behind an UIC number.
class UICDetails {
  /// The full UIC number.
  final String uicNumber;

  /// The normalized UIC number.
  String get uicNumberNormalized => uicNumber.replaceAll(RegExp(r'\D'), '');

  /// The [UICType] of the [UICDetails] instance. Is `null` if the type couldn't
  /// be determined.
  final UICType? uicType;

  /// The [UICCategory] of the [UICDetails] instance. Is `null` if the category
  /// could not be determined (e.g. for non-Swiss UIC number or 7-digit numbers).
  final UICCategory? uicCategory;

  /// The UIC number split into its different segments. Is empty for
  /// non-12-digit UIC number.
  final List<UICDescription> descriptions;

  UICDetails({
    required this.uicNumber,
    required this.descriptions,
    required this.uicType,
    this.uicCategory,
  });

  /// Prints an object string. Use this instead of [UICDetails.toString].
  String toObjectString() =>
      '{uicNumber: $uicNumber, uicValues: $descriptions}';

  /// Used in combination with generic types to ensure it can be properly
  /// displayed in e.g. [DetectionOutlineConfig] labels. Use
  /// [UICDetails.toObjectString] for printing the object string.
  @override
  String toString() => uicNumber;
}
