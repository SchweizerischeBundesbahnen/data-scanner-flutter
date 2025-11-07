import 'package:sbb_data_scanner/extractors/uic_details_extractor.dart';
import 'package:sbb_data_scanner/models/localized_string.dart';
import 'package:sbb_data_scanner/models/uic_details.dart';

/// Utilities for working with UIC numbers.
class UICDetailsService {
  final RegExp _everythingExceptDigits = RegExp(r'[^\d]');

  /// Splits a 12-digit [uic] into its [UICDetails]. [category] defaults to
  /// [UICCategory.passengerCoach]. Returns an empty list for non-12-digit
  /// UIC numbers.
  List<UICDescription> extractUICValues(String uic, [UICCategory category = UICCategory.passengerCoach]) {
    final onlyDigits = uic.replaceAll(_everythingExceptDigits, '');
    if (onlyDigits.length < 12) return [];
    switch (category) {
      case UICCategory.tractionUnit:
        return _tractionUnitUIC(onlyDigits);
      case UICCategory.passengerCoach:
        return _passengerCoachUIC(onlyDigits);
      case UICCategory.freightWagon:
        return _freightWagonUIC(onlyDigits);
    }
  }

  /// Tries to determine the [UICCategory] of [uic]. Returns `null` for
  /// 7-digit long and invalid UIC numbers, as well as UIC number whose category
  /// couldn't be determined.
  UICCategory? determineCategory(String uic) {
    for (final category in UICCategory.values) {
      final details = extractUICValues(uic, category);
      final relevantDescriptions = category == UICCategory.freightWagon ? 3 : 2;
      if (!details.take(relevantDescriptions).map((detail) => detail.description).contains(null)) {
        return category;
      }
    }

    return null;
  }

  /// Tries to determine the [UICType] of [uic]. Returns null if [uic.length]
  /// is invalid (ergo neither `7` nor `12`).
  UICType? determineType(String uic) {
    switch (uic.replaceAll(_everythingExceptDigits, '').length) {
      case 7:
        return UICType.sevenDigits;
      case 12:
        return UICType.twelveDigits;
      default:
        return null;
    }
  }

  /// Formats [uic] to match the common format of [type] (defaults to
  /// [UICType.twelveDigits]) and [category] (defaults to
  /// [UICCategory.passengerCoach], ignored with 7-digit [uic]).
  String formatUIC(
    String uic, {
    UICType? type = UICType.twelveDigits,
    UICCategory? category = UICCategory.passengerCoach,
  }) {
    final onlyDigits = uic.replaceAll(_everythingExceptDigits, '');

    if (type == null && category == null) return onlyDigits;

    // 000 000-0
    if (type == UICType.sevenDigits) {
      return onlyDigits.substring(0, 3) + ' ' + onlyDigits.substring(3, 6) + '-' + onlyDigits[6];
    }

    switch (category!) {
      // 00 00 0 000 000-0
      case UICCategory.tractionUnit:
        return onlyDigits.substring(0, 2) +
            ' ' +
            onlyDigits.substring(2, 4) +
            ' ' +
            onlyDigits[4] +
            ' ' +
            onlyDigits.substring(5, 8) +
            ' ' +
            onlyDigits.substring(8, 11) +
            '-' +
            onlyDigits[11];

      // 00 00 00-00 000-0
      case UICCategory.passengerCoach:
        return onlyDigits.substring(0, 2) +
            ' ' +
            onlyDigits.substring(2, 4) +
            ' ' +
            onlyDigits.substring(4, 6) +
            '-' +
            onlyDigits.substring(6, 8) +
            ' ' +
            onlyDigits.substring(8, 11) +
            '-' +
            onlyDigits[11];

      // 00 00 000 0 000-0
      case UICCategory.freightWagon:
        return onlyDigits.substring(0, 2) +
            ' ' +
            onlyDigits.substring(2, 4) +
            ' ' +
            onlyDigits.substring(4, 7) +
            ' ' +
            onlyDigits[7] +
            ' ' +
            onlyDigits.substring(8, 11) +
            '-' +
            onlyDigits[11];
    }
  }

  /// Compares and matches [uicDigits] against details for traction units.
  List<UICDescription> _tractionUnitUIC(String uicDigits) {
    final digits1And2 = uicDigits.substring(0, 2);
    final digits3And4 = uicDigits.substring(2, 4);
    final digit5 = uicDigits[4];
    final digits6to8 = uicDigits.substring(5, 8);
    final digits9to11 = uicDigits.substring(8, 11);
    final digit12 = uicDigits[11];

    return [
      UICDescription(digits1And2, _TractionUnitUICValues.digits1And2[digits1And2]),
      UICDescription(digits3And4, _TractionUnitUICValues.digits3And4[digits3And4]),
      UICDescription(digit5, _TractionUnitUICValues.digit5),
      UICDescription(digits6to8, _TractionUnitUICValues.digits6to8),
      UICDescription(digits9to11, _TractionUnitUICValues.digits9to11),
      UICDescription(digit12, _TractionUnitUICValues.digit12),
    ];
  }

  /// Compares and matches [uicDigits] against details for passenger coaches.
  List<UICDescription> _passengerCoachUIC(String uicDigits) {
    final digits1And2 = uicDigits.substring(0, 2);
    final digits3And4 = uicDigits.substring(2, 4);
    final digit5 = uicDigits[4];
    final digit6 = uicDigits[5];
    final digit7 = uicDigits[6];
    final digit8 = uicDigits[7];
    final digits9to11 = uicDigits.substring(8, 11);
    final digit12 = uicDigits.substring(11, 12);

    return [
      UICDescription(digits1And2, _PassengerWagonUICValues.digits1And2[digits1And2]),
      UICDescription(digits3And4, _PassengerWagonUICValues.digits3And4[digits3And4]),
      UICDescription(digit5, _PassengerWagonUICValues.digit5[digit5]),
      UICDescription(digit6, _PassengerWagonUICValues.digit6[digit6]),
      UICDescription(digit7, _PassengerWagonUICValues.digit7[digit7]),
      UICDescription(digit8, _PassengerWagonUICValues.digit8[digit8]),
      UICDescription(digits9to11, _PassengerWagonUICValues.digits9to11),
      UICDescription(digit12, _PassengerWagonUICValues.digit12),
    ];
  }

  /// Compares and matches [uicDigits] against details for freight wagons.
  List<UICDescription> _freightWagonUIC(String uicDigits) {
    final digit1 = uicDigits[0];
    final digit2 = uicDigits[1];
    final digits3And4 = uicDigits.substring(2, 4);
    final digits5to8 = uicDigits.substring(4, 8);
    final digits9to11 = uicDigits.substring(8, 11);
    final digit12 = uicDigits[11];

    return [
      UICDescription(digit1, _FreightWagonUICValues.digit1[digit1]),
      UICDescription(digit2, _FreightWagonUICValues.digit2[digit2]),
      UICDescription(digits3And4, _FreightWagonUICValues.digits3And4[digits3And4]),
      UICDescription(digits5to8, _FreightWagonUICValues.digits5to8),
      UICDescription(digits9to11, _FreightWagonUICValues.digits9to11),
      UICDescription(digit12, _FreightWagonUICValues.digit12),
    ];
  }
}

// * * * * * * * * * * * * * * //
// DATA MAPPING FOR UIC VALUES //
// * * * * * * * * * * * * * * //

class _TractionUnitUICValues {
  static Map<String, LocalizedString> digits1And2 = {
    '90': LocalizedString(
      de: 'Dampflokomotiven, Treibfahrzeuge Schmalspur',
      fr: 'Locomotive à vapeur, voiture électrique à voie étroite',
      it: 'Locomotive a vapore, carrozze elettriche a binari stretti',
      en: "Steam locomotives, narrow-gauge traction units",
    ),
    '91': LocalizedString(
      de: 'Elektrolokomotive mit Zugsicherung',
      fr: 'Locomotive électrique avec système de sécurité',
      it: 'Locomotive elettriche con sistemi di sicurezza',
      en: "Electric locomotive with train protection",
    ),
    '92': LocalizedString(
      de: 'Diesellokomotive mit Zugsicherung',
      fr: 'Locomotive diesel avec système de sécurité',
      it: 'Locomotive diesel con sistemi di sicurezza',
      en: "Diesel locomotive with train protection",
    ),
    '93': LocalizedString(
      de: 'Elektrischer Triebwagen oder Triebzug für Hochgeschwindigkeitsverkehr',
      fr: 'Autorail électrique unité multiple pour le trafic à grande vitesse',
      it: 'Treno diesel unità elettrica per il traffico a grande velocità',
      en: "Electric traction unit or multiple unit for high-speed traffic",
    ),
    '94': LocalizedString(
      de: 'Elektrischer Triebwagen oder Triebzug',
      fr: 'Autorail électrique ou rame',
      it: 'Treno diesel elettrico o treno',
      en: "Electric traction unit or multiple unit",
    ),
    '95': LocalizedString(
      de: 'Dieseltriebwagen oder -Triebzug',
      fr: 'Wagon diesel à unité multiple',
      it: 'Treno diesel à unità multiple',
      en: "Diesel traction unit or multiple unit",
    ),
    '96': LocalizedString(
      de: 'Schmalspurwagen',
      fr: 'Wagon à voie étroite',
      it: 'Vagoni a binari stretti',
      en: "Narrow gauge wagon",
    ),
    '97': LocalizedString(
      de: 'Elektrische Lokomotive ohne oder mit vereinfachter Zugsicherung',
      fr: 'Locomotive électrique avec ou sans sécurité simplifiée',
      it: 'Locomotiva elettrica con o senza sicurezza semplificata',
      en: "Electric locomotive with or without simplified train protection",
    ),
    '98': LocalizedString(
      de: 'Diesellokomotive ohne oder mit vereinfachter Zugsicherung',
      fr: 'Locomotive diesel avec ou sans sécurité simplifiée',
      it: 'Locomotiva diesel con o senza sicurezza semplificata',
      en: "Diesel locomotive without or with simplified train protection",
    ),
    '99': LocalizedString(
      de: 'Dienstfahrzeuge (mit oder ohne Eigenantrieb)',
      fr: 'Véhicule de service moteur (avec ou sans son propre lecteur)',
      it: 'Veicolo di servizio à motore (con o senza il proprio lettore)',
      en: "Service vehicles (with or without self-propulsion)",
    ),
  };

  static Map<String, LocalizedString> digits3And4 = {
    '70': LocalizedString(de: 'Grossbritannien', fr: 'Grande-Bretagne', it: 'Gran Bretagna', en: "Great Britain"),
    '71': LocalizedString(de: 'Spanien', fr: 'Espagne', it: 'Spagna', en: "Spain"),
    '74': LocalizedString(de: 'Schweden', fr: 'Suède', it: 'Svezia', en: "Sweden"),
    '76': LocalizedString(de: 'Norwegen', fr: 'Norvège', it: 'Norvegia', en: "Norway"),
    '80': LocalizedString(de: 'Deutschland', fr: 'Allemagne', it: 'Germania', en: "Germany"),
    '81': LocalizedString(de: 'Österreich', fr: 'Autriche', it: 'Austria', en: "Austria"),
    '82': LocalizedString(de: 'Luxemburg', fr: 'Luxembourg', it: 'Lussemburgo', en: "Luxembourg"),
    '83': LocalizedString(de: 'Italien', fr: 'Italie', it: 'Italia', en: "Italy"),
    '84': LocalizedString(de: 'Niederlande', fr: 'Paysbas', it: 'Olanda', en: "Netherlands"),
    '85': LocalizedString(de: 'Schweiz', fr: 'Suisse', it: 'Svizzera', en: "Switzerland"),
    '86': LocalizedString(de: 'Dänemark', fr: 'Danemark', it: 'Danimarca', en: "Denmark"),
    '87': LocalizedString(de: 'Frankreich', fr: 'France', it: 'Francia', en: "France"),
    '88': LocalizedString(de: 'Belgien', fr: 'Belgique', it: 'Belgio', en: "Belgium"),
    '93': LocalizedString(de: 'Portugal', fr: 'Portugal', it: 'Portogallo', en: "Portugal"),
  };

  static LocalizedString digit5 = LocalizedString(
    de: 'Bei Triebzügen als Zähler der Wageneinheiten. Bei Triebfahrzeugen als Nennziffer',
    fr: 'Rame à unité multiple avec compteur de voiture. Véhicule moteur avec chiffre nominal',
    it: 'Treni à unità multiple con veicolo contatore. Veicolo motore con cifre nominali',
    en: "For multiple unit-trains as numerator of the wagon units. For traction units as nominal number",
  );

  static LocalizedString digits6to8 = LocalizedString(
    de: 'Fahrzeugtyp',
    fr: 'Type de véhicule',
    it: 'Tipo dei veicoli',
    en: "Vehicle type",
  );

  static LocalizedString digits9to11 = LocalizedString(
    de: 'Laufende Nummer der gleichen Serie',
    fr: 'Numéro de série dans la même série',
    it: 'Numero di serie nella stessa serie',
    en: "Sequence number of the same series",
  );

  static LocalizedString digit12 = LocalizedString(
    de: 'Kontrollziffer',
    fr: "Chiffre d'autocontrôle",
    it: 'Cifre di autocontrollo',
    en: "Control digit",
  );
}

class _PassengerWagonUICValues {
  static Map<String, LocalizedString> digits1And2 = {
    '50': LocalizedString(
      de: 'Nur Inlandverkehr',
      fr: 'Seulement trafic intérieur',
      it: 'solo nel traffico interno',
      en: "Domestic traffic only",
    ),
    '51': LocalizedString(
      de: 'Auslandverkehr zugelassen, nicht klimatisiert',
      fr: 'Trafic international autorisé, non climatisée',
      it: 'consentito nel traffico transfrontaliero, senza climatizzazione',
      en: "International traffic admitted, not air-conditioned",
    ),
    '52': LocalizedString(
      de: 'Auslandverkehr zugelassen, nicht klimatisiert, umspurbar (1435/1520 mm)',
      fr: 'Trafic international autorisé, non climatisée, écartement variable possible (1435/1520 mm)',
      it: 'consentito nel traffico transfrontaliero, senza climatizzazione, distanze degli assali variabili (1435/1520 mm)',
      en: "International traffic approved, not air-conditioned, gauge changeable (1435/1520 mm)",
    ),
    '61': LocalizedString(
      de: 'Auslandverkehr zugelassen, klimatisiert',
      fr: 'Trafic international autorisé, climatisée',
      it: 'consentito nel traffico transfrontaliero, con climatizzazione',
      en: "International traffic approved, air-conditioned",
    ),
    '73': LocalizedString(
      de: 'Auslandverkehr zugelassen, klimatisiert, druckertüchtig',
      fr: 'Trafic international autorisé, climatisée, étanche protéger contre les surpressions',
      it: 'consentito nel traffico transfrontaliero, con climatizzazione, veicoli sigillati protette dalle surpressioni',
      en: "International traffic registered, air-conditioned, printable",
    ),
  };

  static Map<String, LocalizedString> digits3And4 = {
    '70': LocalizedString(de: 'Grossbritannien', fr: 'Grande-Bretagne', it: 'Gran Bretagna', en: "Great Britain"),
    '71': LocalizedString(de: 'Spanien', fr: 'Espagne', it: 'Spagna', en: "Spain"),
    '74': LocalizedString(de: 'Schweden', fr: 'Suède', it: 'Svezia', en: "Sweden"),
    '76': LocalizedString(de: 'Norwegen', fr: 'Norvège', it: 'Norvegia', en: "Norway"),
    '80': LocalizedString(de: 'Deutschland', fr: 'Allemagne', it: 'Germania', en: "Germany"),
    '81': LocalizedString(de: 'Österreich', fr: 'Autriche', it: 'Austria', en: "Austria"),
    '82': LocalizedString(de: 'Luxemburg', fr: 'Luxembourg', it: 'Lussemburgo', en: "Luxembourg"),
    '83': LocalizedString(de: 'Italien', fr: 'Italie', it: 'Italia', en: "Italy"),
    '84': LocalizedString(de: 'Niederlande', fr: 'Pays bas', it: 'Olanda', en: "Netherlands"),
    '85': LocalizedString(de: 'Schweiz', fr: 'Suisse', it: 'Svizzera', en: "Switzerland"),
    '86': LocalizedString(de: 'Dänemark', fr: 'Danemark', it: 'Danimarca', en: "Denmark"),
    '87': LocalizedString(de: 'Frankreich', fr: 'France', it: 'Francia', en: "France"),
    '88': LocalizedString(de: 'Belgien', fr: 'Belgique', it: 'Belgio', en: "Belgium"),
    '93': LocalizedString(de: 'Portugal', fr: 'Portugal', it: 'Portogallo', en: "Portugal"),
  };

  static Map<String, LocalizedString> digit5 = {
    '0': LocalizedString(de: 'Privatwagen', fr: 'Voiture de privés', it: 'Carrozze private', en: "Private car"),
    '1': LocalizedString(de: 'A-Wagen', fr: 'Voiture A', it: 'Veicolo A', en: "A coach"),
    '2': LocalizedString(de: 'B-Wagen', fr: 'Voiture B', it: 'Veicolo B', en: "B coach"),
    '3': LocalizedString(de: 'AB-Wagen', fr: 'Voiture AB', it: 'Veicolo AB', en: "AB coach"),
  };

  static Map<String, LocalizedString> digit6 = {
    '0': LocalizedString(de: '10 Abteile', fr: '10 compartiments', it: '10 scompartimenti', en: "10 compartments"),
    '1': LocalizedString(de: '11 Abteile', fr: '11 compartiments', it: '11 scompartimenti', en: "11 compartments"),
    '2': LocalizedString(de: '12 Abteile', fr: '12 compartiments', it: '12 scompartimenti', en: "12 compartments"),
    '6': LocalizedString(
      de: 'Doppelstockwagen',
      fr: 'Voitures à 2 étages',
      it: 'Carrozze a due piani',
      en: "Double-decker coach",
    ),
    '7': LocalizedString(de: '7 Abteile', fr: '7 compartiments', it: '7 scompartimenti', en: "7 compartments"),
    '8': LocalizedString(de: '8 Abteile', fr: '8 compartiments', it: '8 scompartimenti', en: "8 compartments"),
    '9': LocalizedString(de: '9 Abteile', fr: '9 compartiments', it: '9 scompartimenti', en: "9 compartments"),
  };

  static Map<String, LocalizedString> digit7 = {
    '0': LocalizedString(de: 'Vmax 120 km/h', fr: 'Vmax 120 km/h', it: 'Vmax 120 km/h', en: "Vmax 120 km/h"),
    '1': LocalizedString(de: 'Vmax 120 km/h', fr: 'Vmax 120 km/h', it: 'Vmax 120 km/h', en: "Vmax 120 km/h"),
    '2': LocalizedString(de: 'Vmax 120 km/h', fr: 'Vmax 120 km/h', it: 'Vmax 120 km/h', en: "Vmax 120 km/h"),
    '3': LocalizedString(de: 'Vmax 140 km/h', fr: 'Vmax 140 km/h', it: 'Vmax 140 km/h', en: "Vmax 140 km/h"),
    '4': LocalizedString(de: 'Vmax 140 km/h', fr: 'Vmax 140 km/h', it: 'Vmax 140 km/h', en: "Vmax 140 km/h"),
    '5': LocalizedString(de: 'Vmax 140 km/h', fr: 'Vmax 140 km/h', it: 'Vmax 140 km/h', en: "Vmax 140 km/h"),
    '6': LocalizedString(de: 'Vmax 140 km/h', fr: 'Vmax 140 km/h', it: 'Vmax 140 km/h', en: "Vmax 140 km/h"),
    '7': LocalizedString(de: 'Vmax 160 km/h', fr: 'Vmax 160 km/h', it: 'Vmax 160 km/h', en: "Vmax 160 km/h"),
    '8': LocalizedString(de: 'Vmax 160 km/h', fr: 'Vmax 160 km/h', it: 'Vmax 160 km/h', en: "Vmax 160 km/h"),
    '9': LocalizedString(de: 'Vmax 200 km/h', fr: 'Vmax 200 km/h', it: 'Vmax 200 km/h', en: "Vmax 200 km/h"),
  };

  static Map<String, LocalizedString> digit8 = {
    '3': LocalizedString(
      de: 'Zugsammelschiene 1000 V',
      fr: 'Ligne de train 1000 V',
      it: 'Condotta elettrica ad alta tensione 1000 V',
      en: "1000 V train busbar",
    ),
    '4': LocalizedString(
      de: 'Zugsammelschiene 1000 V',
      fr: 'Ligne de train 1000 V',
      it: 'Condotta elettrica ad alta tensione 1000 V',
      en: "1000 V train busbar",
    ),
    '5': LocalizedString(
      de: 'Für Pendelzugverkehr eingerichtet',
      fr: 'Equipée pour circuler en train-navette',
      it: 'Equipaggiata per traffico pendolare',
      en: "Equipped for shuttle train traffic",
    ),
  };

  static LocalizedString digits9to11 = LocalizedString(
    de: 'Wagennummer innerhalb der gleichen Serie',
    fr: 'Numéro de voiture de la même série',
    it: "Numero del carro all'interno della stessa serie",
    en: "Wagon number within the same series",
  );

  static LocalizedString digit12 = LocalizedString(
    de: 'Kontrollziffer',
    fr: "Chiffre d'autocontrôle",
    it: 'Cifre di autocontrollo',
    en: "Control digit",
  );
}

class _FreightWagonUICValues {
  static Map<String, LocalizedString> digit1 = {
    '0': LocalizedString(
      de: 'EUROP, INTERFRIGO (Wagen mit Einzelachsen)',
      fr: 'EUROP, INTERFRIGO (Wagon avec un seul axe)',
      it: 'EUROP, INTERFRIGO (Vagoni con un sole asse)',
      en: "EUROP, INTERFRIGO (wagons with single axles)",
    ),
    '1': LocalizedString(
      de: 'EUROP, INTERFRIGO (Wagen mit Drehgestell)',
      fr: 'EUROP, INTERFRIGO (Wagon avec bogie)',
      it: 'EUROP, INTERFRIGO (Vagoni con un solo carrello)',
      en: "EUROP, INTERFRIGO (wagons with bogie)",
    ),
    '2': LocalizedString(
      de: 'RIV (Wagen mit Einzelachsen)',
      fr: 'RIV (Wagon avec un seul axe)',
      it: 'RIV (Vagoni con un sole asse)',
      en: "RIV (wagon with single axles)",
    ),
    '3': LocalizedString(
      de: 'RIV (Wagen mit Drehgestell)',
      fr: 'RIV (Wagon avec un bogie)',
      it: 'RIV (Vagoni con un solo carrello)',
      en: "RIV (wagon with bogie)",
    ),
    '4': LocalizedString(
      de: 'Sonderwagen international zugelassen (Wagen mit Einzelachsen)',
      fr: 'Wagon spéciaux pour trafic international (Wagon avec un seul axe)',
      it: 'Vagoni per il traffico internazionale (Vagoni con un sole asse)',
      en: "Special wagons internationally registered (wagons with single axles)",
    ),
    '8': LocalizedString(
      de: 'Sonderwagen international zugelassen (Wagen mit Drehgestell)',
      fr: 'Wagon spéciaux pour trafic international (Wagon avec un bogie)',
      it: 'Vagoni per il traffico internazionale (Vagoni con un solo carrello)',
      en: "Special wagons internationally registered (wagons with bogie)",
    ),
  };

  static Map<String, LocalizedString> digit2 = {
    '0': LocalizedString(de: 'Dienstwagen', fr: "Wagon d'entreprise", it: "Vagoni d'azienda", en: "Company wagon"),
    '1': LocalizedString(
      de: 'Bahneigener Wagen',
      fr: 'Wagon des chemin de fer',
      it: 'Vagoni delle ferrovie',
      en: "Railway's own wagon",
    ),
    '2': LocalizedString(
      de: 'Bahneigener Wagen',
      fr: 'Wagon des chemin de fer',
      it: 'Vagoni delle ferrovie',
      en: "Railway wagon",
    ),
    '3': LocalizedString(de: 'Privater Wagen', fr: 'Wagon privé', it: 'Vagoni privati', en: "Private wagon"),
    '4': LocalizedString(de: 'Privater Wagen', fr: 'Wagon privé', it: 'Vagoni privati', en: "Private wagon"),
    '5': LocalizedString(
      de: 'Vermieteter Privatwagen',
      fr: 'Wagon privé pour location',
      it: 'Vagoni da affittare privati',
      en: "Rented private car",
    ),
    '6': LocalizedString(
      de: 'Vermieteter Privatwagen',
      fr: 'Wagon privé pour location',
      it: 'Vagoni da affittare privati',
      en: "Rented private car",
    ),
  };

  static Map<String, LocalizedString> digits3And4 = {
    '10': LocalizedString(de: 'Finnland', fr: 'Finlande', it: 'Finlandia', en: "Finland"),
    '20': LocalizedString(de: 'Russland', fr: 'Russie', it: 'Russia', en: "Russia"),
    '41': LocalizedString(de: 'Albanien', fr: 'Albanie', it: 'Albania', en: "Albania"),
    '54': LocalizedString(de: 'Tschechien', fr: 'Cechie', it: 'Ceca', en: "Czech Republic"),
    '55': LocalizedString(de: 'Ungarn', fr: 'Hongrie', it: 'Ungheria', en: "Hungary"),
    '56': LocalizedString(de: 'Slowakei', fr: 'Slovaquie', it: 'Slovacchia', en: "Slovakia"),
    '70': LocalizedString(de: 'UK', fr: 'Grande-Bretagne', it: 'Gran Bretagna', en: "UK"),
    '71': LocalizedString(de: 'Spanien', fr: 'Espagne', it: 'Spagna', en: "Spain"),
    '73': LocalizedString(de: 'Griechenland', fr: 'Grèce', it: 'Grecia', en: "Greece"),
    '74': LocalizedString(de: 'Schweden', fr: 'Suède', it: 'Svezia', en: "Sweden"),
    '76': LocalizedString(de: 'Norwegen', fr: 'Norvège', it: 'Norvegia', en: "Norway"),
    '78': LocalizedString(de: 'Kroatien', fr: 'Croatie', it: 'Croazia', en: "Croatia"),
    '79': LocalizedString(de: 'Slowenien', fr: 'Slovaquie', it: 'Slovenia', en: "Slovenia"),
    '80': LocalizedString(de: 'Deutschland', fr: 'Allemagne', it: 'Germania', en: "Germany"),
    '81': LocalizedString(de: 'Österreich', fr: 'Autriche', it: 'Austria', en: "Austria"),
    '82': LocalizedString(de: 'Luxemburg', fr: 'Luxembourg', it: 'Lussemburgo', en: "Luxembourg"),
    '83': LocalizedString(de: 'Italien', fr: 'Italie', it: 'Italia', en: "Italy"),
    '84': LocalizedString(de: 'Niederlande', fr: 'Pays bas', it: 'Olanda', en: "Netherlands"),
    '85': LocalizedString(de: 'Schweiz', fr: 'Suisse', it: 'Svizzera', en: "Switzerland"),
    '86': LocalizedString(de: 'Dänemark', fr: 'Danemark', it: 'Danimarca', en: "Denmark"),
    '87': LocalizedString(de: 'Frankreich', fr: 'France', it: 'Francia', en: "France"),
    '88': LocalizedString(de: 'Belgien', fr: 'Belgique', it: 'Belgio', en: "Belgium"),
    '93': LocalizedString(de: 'Portugal', fr: 'Portugal', it: 'Portogallo', en: "Portugal"),
  };

  static LocalizedString digits5to8 = LocalizedString(
    de: 'Typencode: Gibt die Wagengattung und die Betriebsmerkmale sowohl für bahneigene wie für Privatwagen an',
    fr: "Type de code: Indique le type de wagon et les caractéristiques d'utilisations des chemins de fer ou des privés.",
    it: "Tipi di codice: Indica il tipo di vagone e le caratteristiche d'utilizzazione delle ferrovie o dei privati.",
    en: "Type Indicates the wagon type and the operational characteristics for both railway and private wagons",
  );

  static LocalizedString digits9to11 = LocalizedString(
    de: 'Wagennummer innerhalb der gleichen Serie',
    fr: 'Numéro de voiture de la même série',
    it: "Numero del carro all'interno della stessa serie",
    en: "Wagon number within the same series",
  );

  static LocalizedString digit12 = LocalizedString(
    de: 'Kontrollziffer',
    fr: "Chiffre d'autocontrôle",
    it: 'Cifre di autocontrollo',
    en: "Control digit",
  );
}
