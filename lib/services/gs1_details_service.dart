import 'package:sbb_data_scanner/extractors/gs1_details_extractor.dart';
import 'package:sbb_data_scanner/models/gs1_details.dart';
import 'package:sbb_data_scanner/models/localized_string.dart';

/// Utilities for working with gs1 codes.
class GS1DetailsService {
  final RegExp _everythingExceptDigits = RegExp(r'\D');

  /// Splits a gs1 code into its [GS1Details]. If type is [GS1Type.unknown] returns [].
  List<GS1Description> extractGS1Values(String gs1, GS1Type type) {
    if (type == GS1Type.unknown) return [];

    final onlyDigits = gs1.replaceAll(_everythingExceptDigits, '');
    final digits1to4 = onlyDigits.substring(0, 4);
    final rest = onlyDigits.substring(4);
    return [
      GS1Description(digits1to4, _GS1Values.digits1To4[digits1to4]),
      GS1Description(rest, _GS1Values.assetIdentifier),
    ];
  }

  /// Formats [gs1] to match the common format of [type] (defaults to
  /// [GS1Type.unknown] (does not get recognized)).
  String formatGS1(String gs1, {GS1Type type = GS1Type.unknown}) {
    final onlyDigits = gs1.replaceAll(_everythingExceptDigits, '');

    switch (type) {
      case GS1Type.giai:
        return '(' + onlyDigits.substring(0, 4) + ')' + onlyDigits.substring(4);
      case GS1Type.unknown:
        return onlyDigits;
    }
  }

  GS1Type determineType(String gs1) {
    if (gs1.length < 4) return GS1Type.unknown;
    final onlyDigits = gs1.replaceAll(_everythingExceptDigits, '');
    final digits1to4 = onlyDigits.substring(0, 4);

    switch (digits1to4) {
      case '8004':
        return GS1Type.giai;
      default:
        return GS1Type.unknown;
    }
  }
}

// * * * * * * * * * * * * * * //
// DATA MAPPING FOR GS1 VALUES //
// * * * * * * * * * * * * * * //

class _GS1Values {
  static Map<String, LocalizedString> digits1To4 = {
    '8004': LocalizedString(
      de: 'Global Individual Asset Identifier (GIAI)',
      fr: 'Global Individual Asset Identifier (GIAI)',
      it: 'Global Individual Asset Identifier (GIAI)',
      en: "Global Individual Asset Identifier (GIAI)",
    ),
  };

  static LocalizedString assetIdentifier = LocalizedString(
    de: 'Asset Identifier',
    fr: 'Asset Identifier',
    it: 'Asset Identifier',
    en: "Asset Identifier",
  );
}
