import 'package:meta/meta.dart';

final List<String> defaultLanguages = List.unmodifiable(
  [
    'pt',
    'de',
    'de-ch',
    'en',
    'en-gb',
    'es',
    'it',
    'ko',
    'fr',
    'no',
    'nl',
    'sv',
    'ru',
    'he',
    'et',
    'ar',
    'bg',
    'sk',
    'ca',
    'da',
  ],
);

@Deprecated('defaultLanguagesDictionaries is no longer used and will be removed in future releases')
final Map<String, String> defaultLanguagesDictionaries = Map.unmodifiable({});

/// This variable is used by the checker to add using [setLanguage]
/// where the key is the language code, and the value is the dictionary
@experimental
final Map<String, Map<String, int>> languagesToBeUsed = {};

@experimental
bool isWordHasNumber(String s) {
  return s.contains(RegExp(r'[0-9]'));
}
