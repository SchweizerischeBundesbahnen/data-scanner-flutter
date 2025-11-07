import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sbb_data_scanner/services/uic_validation_service.dart';

class MockLuhn extends Mock implements Luhn {}

void main() {
  group('UICValidatorService', () {
    late UICValidatorService service;
    late MockLuhn mockLuhn;

    setUp(() {
      mockLuhn = MockLuhn();
      service = UICValidatorService(luhn: mockLuhn);
    });

    group('validate', () {
      test('should check Luhn checksum', () async {
        when(() => mockLuhn.validate(any())).thenReturn(true);

        final testValue = '918544202107';
        service.validate(testValue);

        verify(() => mockLuhn.validate(testValue));
      });
    });
  });

  group('Luhn', () {
    late Luhn luhn;

    setUp(() {
      luhn = Luhn();
    });

    group('validate', () {
      final testValues = [
        // Only numbers
        {'testValue': '508510952130', 'expected': true},
        // With spaces and hyphens
        {'testValue': '50 85 10-95 213-0', 'expected': true},
        // With text characters
        {'testValue': 'RABe 94 85 05-11 028-8', 'expected': true},
        // 7 digit UIC
        {'testValue': '460 015-1', 'expected': true},

        // Empty string
        {'testValue': '', 'expected': false},
        // Checksum is wrong
        {'testValue': '50 85 10-95 213-8', 'expected': false},
        // To many chars
        {'testValue': '50 85 100-95 213-8', 'expected': false},
        // Zero is an 'O'
        {'testValue': '5O 85 10-95 213-8', 'expected': false},
        // Invalid UIC
        {'testValue': '44 44 44-44 444-4', 'expected': false},
      ];

      testValues.forEach((testValue) {
        test('should correctly validate the Luhn checksum of [${testValue['testValue']}]', () async {
          final result = luhn.validate(testValue['testValue'] as String);
          expect(result, testValue['expected']);
        });
      });
    });
  });
}
