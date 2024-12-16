import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_data_scanner/extractors/uic_details_extractor.dart';
import 'package:sbb_data_scanner/models/uic_details.dart';
import 'package:sbb_data_scanner/services/uic_details_service.dart';

void main() {
  late UICDetailsService service;

  setUp(() {
    service = UICDetailsService();
  });

  group('UICDetailsService', () {
    group('extractUICValues', () {
      test(
        'should return [] for UIC numbers shorter than 12 digits',
        () async {
          final testValues = [
            '540 020-5',
            '40 85 94 37 70-7',
            'Lorem Ipsum',
          ];

          testValues.forEach((testValue) => expect(service.extractUICValues(testValue), []));
        },
      );

      test(
        'should return filled List<UICDescription> for UIC numbers with 12 digits',
        () async {
          final testValues = [
            '40 85 94 37 707-4',
            '50 85 39-43 853-3',
            '91 85 4 420 210-7',
          ];

          testValues.forEach((testValue) {
            final results = service.extractUICValues(testValue);
            expect(results, isA<List<UICDescription>>());
            expect(results.length > 0, isTrue);
          });
        },
      );

      test(
        'should ignore all digits after the first 12',
        () async {
          final testValues = [
            '408594377074000',
            '508539438533000',
            '918544202107000',
          ];

          testValues.forEach((testValue) {
            final results = service.extractUICValues(testValue);

            var extractedUIC = '';
            results.forEach((r) => extractedUIC += r.digits);

            expect(extractedUIC.length, 12);
            expect(testValue.substring(0, 12), extractedUIC);
          });
        },
      );

      test(
        'should return null for UICDescription.description when digits have no meaning',
        () async {
          final testValues = [
            '00 00 0 000 000-0',
            '11 00 0 000 000-0',
            '22 00 0 000 000-0',
          ];

          testValues.forEach((testValue) {
            final results = service.extractUICValues(testValue);
            expect(results.first.description, null);
          });
        },
      );
    });

    group('formatUIC', () {
      test(
        'should correctly format 7-digit UIC number',
        () async {
          final testValues = [
            'A 40   85 94 37  707-4',
            '50   85 - 39----43 853-3',
            '918544202107',
          ];

          // 000 000-0
          final format = RegExp(r'\d\d\d\s\d\d\d-\d');

          testValues.forEach((testValue) {
            final result = service.formatUIC(testValue, type: UICType.sevenDigits);
            expect(format.hasMatch(result), isTrue);
          });
        },
      );

      test(
        'should correctly format 12-digit traction unit UIC numbers',
        () async {
          final testValues = [
            '40 85    94 - 37    707-4',
            '   -- 50 85 39-43 853-3 --',
            '91 85-4-420 210 7',
          ];

          // 00 00 0 000 000-0
          final format = RegExp(r'\d\d\s\d\d\s\d\s\d\d\d\s\d\d\d-\d');

          testValues.forEach((testValue) {
            final result = service.formatUIC(
              testValue,
              type: UICType.twelveDigits,
              category: UICCategory.tractionUnit,
            );

            expect(format.hasMatch(result), isTrue);
          });
        },
      );

      test(
        'should correctly format 12-digit passenger coach UIC numbers',
        () async {
          final testValues = [
            '40 85    94 - 37    707-4',
            '   -- 50 85 39-43 853-3 --',
            '91 85-4-420 210 7',
          ];

          // 00 00 00-00 000-0
          final format = RegExp(r'\d\d\s\d\d\s\d\d-\d\d\s\d\d\d-\d');

          testValues.forEach((testValue) {
            final result = service.formatUIC(
              testValue,
              type: UICType.twelveDigits,
              category: UICCategory.passengerCoach,
            );

            expect(format.hasMatch(result), isTrue);
          });
        },
      );

      test(
        'should correctly format 12-digit freight wagon UIC numbers',
        () async {
          final testValues = [
            '40 85    94 - 37    707-4',
            '   -- 50 85 39-43 853-3 --',
            '91 85-4-420 210 7',
          ];

          // 00 00 000 0 000-0
          final format = RegExp(r'\d\d\s\d\d\s\d\d\d\s\d\s\d\d\d-\d');

          testValues.forEach((testValue) {
            final result = service.formatUIC(
              testValue,
              type: UICType.twelveDigits,
              category: UICCategory.freightWagon,
            );

            expect(format.hasMatch(result), isTrue);
          });
        },
      );
    });
  });
}
