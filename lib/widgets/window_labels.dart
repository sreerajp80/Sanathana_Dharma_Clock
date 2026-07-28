import '../core/config/app_localizations.dart';
import '../core/constants/hora_names.dart';
import '../core/constants/muhurta_names.dart';
import '../models/hora_window.dart';
import '../models/muhurta_window.dart';

/// The display name of a named window in the user's language.
///
/// The services build each window with its canonical Sanskrit/English name and
/// a language-free key (`label` + `index`). This maps that key to the wording
/// for the active language. Pure UI mapping with no business logic, so it lives
/// in the widgets layer next to [windowColor].
String windowName(MuhurtaWindow window, AppLocalizations l10n) {
  switch (window.label) {
    case WindowLabel.muhurta:
      return MuhurtaNames.at(window.index, isMalayalam: l10n.isMl);
    case WindowLabel.abhijit:
      return l10n.abhijitMuhurta;
    case WindowLabel.rahuKala:
      return l10n.rahuKala;
    case WindowLabel.yamagandaKala:
      return l10n.yamagandaKala;
    case WindowLabel.gulikaKala:
      return l10n.gulikaKala;
  }
}

/// The ruling planet of a horā in the user's language.
String horaLordName(HoraWindow hora, AppLocalizations l10n) =>
    HoraNames.nameAt(hora.lordIndex, isMalayalam: l10n.isMl);
