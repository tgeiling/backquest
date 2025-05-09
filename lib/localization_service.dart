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
      'ok': _localizations.ok,
      'locale': _localizations.locale,
    };

    return translations[key] ?? 'Translation not found';
  }

  String getTranslatedMessage(String key) {
    String translation = getTranslatedString(key);

    return translation;
  }
}
