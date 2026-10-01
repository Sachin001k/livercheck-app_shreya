import 'package:flutter/material.dart';

import 'services/data_service.dart';
import 'translations.dart';

/// The language the whole app is currently shown in.
final ValueNotifier<AppLanguage> appLanguage =
    ValueNotifier<AppLanguage>(AppLanguage.en);

/// Rebuilds every widget that reads text through [TranslateContext.t]
/// whenever [appLanguage] changes. Installed once, above the Navigator.
class LanguageScope extends InheritedNotifier<ValueNotifier<AppLanguage>> {
  const LanguageScope({super.key, required super.notifier, required super.child});

  static AppLanguage of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LanguageScope>()
          ?.notifier
          ?.value ??
      AppLanguage.en;
}

extension TranslateContext on BuildContext {
  AppLanguage get lang => LanguageScope.of(this);

  /// Text for [key] in the current language (falls back to English).
  String t(String key) => tr(LanguageScope.of(this), key);
}

/// Language picker used in the login screen and the app bar. Saves the
/// choice to the user's profile when they are signed in.
class LanguageDropdown extends StatelessWidget {
  final Color? textColor;
  final Color? dropdownColor;

  const LanguageDropdown({super.key, this.textColor, this.dropdownColor});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<AppLanguage>(
      value: context.lang,
      underline: const SizedBox.shrink(),
      dropdownColor: dropdownColor,
      iconEnabledColor: textColor,
      style: TextStyle(color: textColor ?? Theme.of(context).colorScheme.onSurface),
      items: [
        for (final lang in AppLanguage.values)
          DropdownMenuItem(value: lang, child: Text(lang.nativeName)),
      ],
      onChanged: (value) {
        if (value == null) return;
        appLanguage.value = value;
        DataService.saveLanguage(value);
      },
    );
  }
}
