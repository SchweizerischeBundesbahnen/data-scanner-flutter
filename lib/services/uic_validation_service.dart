import 'package:sbb_data_scanner/services/uic_details_service.dart';

/// Utilities for validating UIC numbers.
class UICValidatorService {
  /// Instance of the Luhn algorithm.
  final Luhn _luhn;

  UICValidatorService({Luhn? luhn}) : _luhn = luhn ?? Luhn();

  /// Validates a digit-only UIC number. Make sure [uic] only contains digits.
  bool validate(String uic) {
    final validLuhn = _luhn.validate(uic);
    final uicDetailsService = UICDetailsService();
    final validDigits = uicDetailsService.determineCategory(uic) != null;
    return validLuhn && validDigits;
  }
}

/// Luhn checksum algorithm. https://en.wikipedia.org/wiki/Luhn_algorithm
class Luhn {
  /// Calculates and returns the validity of the Luhn checksum of [input].
  bool validate(String input) {
    final onlyDigits = input.replaceAll(RegExp(r'[^\d]'), '');
    if (onlyDigits.trim().length <= 1) return false;

    var sum = 0;
    var counter = 0;
    final zero = '0'.codeUnitAt(0);
    final nine = '9'.codeUnitAt(0);

    for (final digit in onlyDigits.split('').reversed) {
      if (_isDigit(digit)) {
        final code = digit.codeUnitAt(0);
        if (code < zero || code > nine) return false;

        if (counter % 2 == 1) {
          sum += digit == '9' ? 9 : (int.parse(digit) * 2) % 9;
        } else {
          sum += int.parse(digit);
        }

        counter++;
      }
    }

    return sum % 10 == 0;
  }

  bool _isDigit(String char) => RegExp(r'\d').hasMatch(char);
}
