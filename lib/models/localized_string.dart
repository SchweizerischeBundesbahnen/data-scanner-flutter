import 'package:flutter/material.dart';

/// Contains a string localized in German, French and Italian.
class LocalizedString {
  LocalizedString({required this.de, required this.fr, required this.it, required this.en});

  /// The German localization.
  final String de;

  /// The French localization.
  final String fr;

  /// The Italian localization.
  final String it;

  /// The English localization.
  final String en;

  /// Value corresponsing to the current language (`de`,`fr`,`it`) of [context].
  /// Requires a [Localizations] widget in scope. Returns the German value when
  /// no language matches [context].
  String of(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'de':
        return de;
      case 'fr':
        return fr;
      case 'it':
        return it;
      default:
        return de;
    }
  }

  @override
  String toString() => '{de: $de, fr: $fr, it: $it}';
}
