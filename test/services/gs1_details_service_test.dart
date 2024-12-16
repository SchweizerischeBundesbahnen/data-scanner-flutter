import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_data_scanner/extractors/_extractors.dart';
import 'package:sbb_data_scanner/models/gs1_details.dart';
import 'package:sbb_data_scanner/services/gs1_details_service.dart';

void main() {
  late GS1DetailsService service;

  setUp(() {
    service = GS1DetailsService();
  });

  group('GS1DetailsService', () {
    group('extractGS1Values', () {
      test(
        'should return [] for gs1 codes with unknown type',
        () async {
          final testValues = [
            '(9999)761329948010399',
            '9999761329948010399',
            '123',
            'ABCDEF',
            ''
          ];

          testValues.forEach((testValue) =>
              expect(service.extractGS1Values(testValue, GS1Type.unknown), []));
        },
      );

      test(
        'should return filled List<GS1Description> for giai codes',
        () async {
          final testValues = [
            '8004761329948010399',
            '(8004)761329948010399',
          ];

          testValues.forEach((testValue) {
            final results = service.extractGS1Values(testValue, GS1Type.giai);
            expect(results, isA<List<GS1Description>>());
            expect(results.length > 0, isTrue);
          });
        },
      );
    });

    group('formatGS1', () {
      test(
        'should correctly format giai codes',
        () async {
          final testValues = [
            '8004761329948010399',
            '(8004)761329948010399',
          ];

          // (0000)0...
          final format = RegExp(r'\(\d\d\d\d\)\d+');

          testValues.forEach((testValue) {
            final result = service.formatGS1(testValue, type: GS1Type.giai);
            expect(format.hasMatch(result), isTrue);
          });
        },
      );
    });
  });
}
