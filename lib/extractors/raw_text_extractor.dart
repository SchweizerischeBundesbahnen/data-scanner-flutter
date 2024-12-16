import 'package:sbb_data_scanner/interfaces/extractor.dart';

/// Default extractor with no business logic.
class RawTextExtractor implements Extractor<String> {
  @override
  String? extract(String? input) => input;
}
