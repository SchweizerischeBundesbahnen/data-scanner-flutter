import 'package:flutter/material.dart';

/// Contains a string localized in German, French and Italian.
class LocalizedString {
  /// The German localization.
  final String de;

  /// The French localization.
  final String fr;

  /// The Italian localization.
  final String it;

  /// The English localization.
  final String en;

  LocalizedString({required this.de, required this.fr, required this.it, required this.en});

  /// Value corresponsing to the current language (`de`,`fr`,`it`) of [context].
  /// Requires a [Localizations] widget in scope. Returns the German value when
  /// no language matches [context].
  String of(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'de':
        return this.de;
      case 'fr':
        return this.fr;
      case 'it':
        return this.it;
      default:
        return this.de;
    }
  }

  @override
  String toString() => '{de: $de, fr: $fr, it: $it}';
}
