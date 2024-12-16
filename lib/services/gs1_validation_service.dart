

import 'package:sbb_data_scanner/extractors/gs1_details_extractor.dart';

/// Utilities for validating gs1 codes.
class GS1ValidatorService {

  /// Validates a gs1 code.
  /// If type unknown validation is always false. There is no way how to validate
  /// if the type is unknown.
  bool validate(String gs1, GS1Type type) {
    switch (type) {
      case GS1Type.giai:
        return _validateGIAI(gs1);
      default:
        return false;
    }
  }

  // https://www.gs1.org/standards/barcodes/application-identifiers/8004?lang=en
  bool _validateGIAI(String gs1) {
    final onlyDigits = gs1.replaceAll(RegExp(r'\D'), '');
    final isValid = RegExp(
            r'^8004([\x21-\x22\x25-\x2F\x30-\x39\x3A-\x3F\x41-\x5A\x5F\x61-\x7A]{0,30})$')
        .hasMatch(onlyDigits);
    return isValid;
  }
}
