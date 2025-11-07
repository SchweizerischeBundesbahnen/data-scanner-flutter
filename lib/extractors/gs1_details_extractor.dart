import 'package:sbb_data_scanner/interfaces/extractor.dart';
import 'package:sbb_data_scanner/models/gs1_details.dart';
import 'package:sbb_data_scanner/services/gs1_details_service.dart';
import 'package:sbb_data_scanner/services/gs1_validation_service.dart';

enum GS1Type { giai, unknown }

/// Extracts details of GS1 codes.
class GS1DetailsExtractor implements Extractor<GS1Details> {
  /// The [GS1ValidatorService] to be used.
  final GS1ValidatorService _gs1ValidatorService;

  /// The [GS1DetailsService] to be used
  final GS1DetailsService _gs1DetailsService;

  final RegExp _everythingExceptDigits = RegExp(r'\D');

  GS1DetailsExtractor({GS1ValidatorService? gs1ValidatorService, GS1DetailsService? gs1DetailsService})
    : _gs1ValidatorService = gs1ValidatorService ?? GS1ValidatorService(),
      _gs1DetailsService = gs1DetailsService ?? GS1DetailsService();

  /// Extracts an gs1 code from [input] and splits it up into its
  /// [GS1Details] Returns `null` if [input] is `null` or if the resulting gs1
  /// code is invalid.
  @override
  GS1Details? extract(String? input) {
    if (input == null) return null;
    final gs1 = input.replaceAll(_everythingExceptDigits, '');
    final type = _gs1DetailsService.determineType(gs1);

    if (!_gs1ValidatorService.validate(gs1, type)) return null;

    final List<GS1Description> values = _gs1DetailsService.extractGS1Values(gs1, type);

    return GS1Details(
      gs1Code: _gs1DetailsService.formatGS1(gs1, type: type),
      rawValue: input,
      gs1type: type,
      descriptions: values,
    );
  }
}
