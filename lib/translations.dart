/// Multilingual content for the LivrCheck Flutter app.
///
/// Each language's text lives in its own file under `lib/translations/`.
/// To add a language: create its file, add it to [AppLanguage] with its
/// native name, and register it in [kTranslations].
library;

import 'translations/en.dart';
import 'translations/gu.dart';
import 'translations/hi.dart';
import 'translations/kn.dart';
import 'translations/ml.dart';
import 'translations/mr.dart';
import 'translations/or.dart';
import 'translations/ta.dart';
import 'translations/te.dart';

enum AppLanguage {
  en('English'),
  hi('हिन्दी'),
  ta('தமிழ்'),
  te('తెలుగు'),
  kn('ಕನ್ನಡ'),
  ml('മലയാളം'),
  mr('मराठी'),
  gu('ગુજરાતી'),
  or('ଓଡ଼ିଆ');

  /// Name shown in the language dropdown, written in that language.
  final String nativeName;

  const AppLanguage(this.nativeName);
}

const Map<AppLanguage, Map<String, String>> kTranslations = {
  AppLanguage.en: en,
  AppLanguage.hi: hi,
  AppLanguage.ta: ta,
  AppLanguage.te: te,
  AppLanguage.kn: kn,
  AppLanguage.ml: ml,
  AppLanguage.mr: mr,
  AppLanguage.gu: gu,
  AppLanguage.or: or,
};

/// Looks up [key] in [lang], falling back to English, then to the key itself.
String tr(AppLanguage lang, String key) {
  return kTranslations[lang]?[key] ?? en[key] ?? key;
}
