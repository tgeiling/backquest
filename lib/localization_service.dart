import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationService {
  late AppLocalizations _localizations;

  // Initialize with the correct localizations
  void initialize(AppLocalizations localizations) {
    _localizations = localizations;
  }

  // Getter for translations
  String getTranslatedString(String key) {
    final translations = {
      'level1Description': _localizations.level1Description,
      'level2Description': _localizations.level2Description,
      'level3Description': _localizations.level3Description,
      'level4Description': _localizations.level4Description,
      'level5Description': _localizations.level5Description,
      'level6Description': _localizations.level6Description,
      'level7Description': _localizations.level7Description,
      'level8Description': _localizations.level8Description,
      'level9Description': _localizations.level9Description,
      'level10Description': _localizations.level10Description,
      'level11Description': _localizations.level11Description,
      'level12Description': _localizations.level12Description,
      'level13Description': _localizations.level13Description,
      'level14Description': _localizations.level14Description,
      'level15Description': _localizations.level15Description,
      'level16Description': _localizations.level16Description,
      'level17Description': _localizations.level17Description,
      'level18Description': _localizations.level18Description,
      'level19Description': _localizations.level19Description,
      'level20Description': _localizations.level20Description,
      'locale': _localizations.locale,
    };

    return translations[key] ?? 'Translation not found';
  }

  String getTranslatedMessage(String key) {
    String translation = getTranslatedString(key);

    return translation;
  }
}
