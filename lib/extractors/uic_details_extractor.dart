import 'package:sbb_data_scanner/interfaces/extractor.dart';
import 'package:sbb_data_scanner/models/uic_details.dart';
import 'package:sbb_data_scanner/services/uic_details_service.dart';
import 'package:sbb_data_scanner/services/uic_validation_service.dart';

enum UICCategory { tractionUnit, passengerCoach, freightWagon }

enum UICType { sevenDigits, twelveDigits }

enum UICDetectionMode { strict, loose }

/// Extracts details of UIC numbers.
class UICDetailsExtractor implements Extractor<UICDetails> {
  /// The [UICValidatorService] to be used.
  final UICValidatorService _uicValidatorService;

  /// The [UICDetailsService] to be used
  final UICDetailsService _uicDetailsService;

  /// The [UICDetectionMode] to be used
  final UICDetectionMode _uicDetectionMode;

  final RegExp _everythingExceptDigits = RegExp(r'[^\d]');

  UICDetailsExtractor({
    UICDetectionMode? uicDetectionMode,
    UICValidatorService? uicValidatorService,
    UICDetailsService? uicDetailsService,
  })  : _uicDetectionMode = uicDetectionMode ?? UICDetectionMode.strict,
        _uicValidatorService = uicValidatorService ?? UICValidatorService(),
        _uicDetailsService = uicDetailsService ?? UICDetailsService();

  /// Extracts an UIC number from [input] and splits it up into its
  /// [UICDetails] Returns `null` if [input] is `null` or if the resulting UIC
  /// number is invalid. Extracts details for 12-digit UIC numbers, otherwise
  /// [UICDetails.descriptions] is empty.
  @override
  UICDetails? extract(String? input) {
    if (input == null) return null;
    final uic = _extractUICFromString(input);
    if (uic == null || uic.isEmpty) return null;

    final uicCategory = _uicDetailsService.determineCategory(uic);
    final uicType = _uicDetailsService.determineType(uic);
    final List<UICDescription> values =
        uicCategory != null ? _uicDetailsService.extractUICValues(uic, uicCategory) : [];

    return UICDetails(
      uicNumber: _uicDetailsService.formatUIC(
        uic,
        category: uicCategory,
        type: uicType,
      ),
      uicType: uicType,
      descriptions: values,
      uicCategory: uicCategory,
    );
  }

  /// Extracts and validates an UIC number of type [type] from [input].
  /// Returns `null` when [input] is `null` or an invalid UIC number.
  String? _extractUICFromString(String? input) {
    if (input == null) return null;

    final onlyDigits = input.replaceAll(_everythingExceptDigits, '');

    if (_uicDetailsService.determineType(onlyDigits) != null) {
      if (_uicValidatorService.validate(onlyDigits)) {
        return onlyDigits;
      }
    }

    String? potentialUic;
    if (_uicDetectionMode == UICDetectionMode.loose) {
      if (onlyDigits.length > 12) {
        potentialUic = _extractX(onlyDigits, 12);
      }
      if (potentialUic == null && onlyDigits.length > 7) {
        potentialUic = _extractX(onlyDigits, 7);
      }
    }

    return potentialUic;
  }

  String? _extractX(String input, int x) {
    final length = input.length;
    for (var i = 0; i <= length - x; i++) {
      final potentialUic = input.substring(i, i + x);
      if (_uicValidatorService.validate(potentialUic)) {
        return potentialUic;
      }
    }
    return null;
  }
}
