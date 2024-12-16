/// Extracts content from a string.
abstract class Extractor<T> {
  /// Extracts elements from [input] and returns them.
  T? extract(String? input);
}
