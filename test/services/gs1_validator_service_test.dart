import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_data_scanner/extractors/_extractors.dart';
import 'package:sbb_data_scanner/services/gs1_validation_service.dart';

void main() {
  group('GS1ValidatorService', () {
    late GS1ValidatorService service;

    setUp(() {
      service = GS1ValidatorService();
    });

    group('validate giai', () {
      final testValues = [
        // Only numbers
        {'testValue': '8004761329948010399', 'expected': true},
        // With spaces and hyphens
        {'testValue': '(8004)7613299 48010399', 'expected': true},

        // Empty string
        {'testValue': '', 'expected': false},
        // too short
        {'testValue': '123', 'expected': false},
        // too long
        {'testValue': '80040000000000000000000000000000000', 'expected': false},
        // wrong application identifier
        {'testValue': '(9999)761329948010399', 'expected': false},
      ];
      testValues.forEach((testValue) {
        test(
          'should correctly validate [${testValue['testValue']}]',
          () async {
            final result = service.validate(testValue['testValue'] as String, GS1Type.giai);
            expect(result, testValue['expected']);
          },
        );
      });
    });
  });
}
