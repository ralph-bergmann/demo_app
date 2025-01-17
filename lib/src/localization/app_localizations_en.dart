import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Demo App';

  @override
  String get loading_data => 'Lade Daten...';

  @override
  String get error_while_loading_data => 'Fehler beim Laden der Daten';

  @override
  String greeting({required String gender}) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'all': 'Alle',
        'male': 'Herren',
        'female': 'Damen',
        'other': 'andere',
      },
    );
    return '$_temp0';
  }
}
