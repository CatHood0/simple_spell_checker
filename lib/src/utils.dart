import 'package:simple_spell_checker/src/dictionaries/de/join_deutsch_words.dart';
import 'package:simple_spell_checker/src/dictionaries/en/join_english_words.dart';
import 'package:simple_spell_checker/src/dictionaries/es/join_es_words.dart';
import 'package:simple_spell_checker/src/dictionaries/fr/join_french_words.dart';
import 'package:simple_spell_checker/src/dictionaries/it/join_italian_words.dart';
import 'package:simple_spell_checker/src/dictionaries/pt/join_portuguese_words.dart';
import 'dictionaries/no/no_words.dart';
import 'dictionaries/sv/sv_words.dart';

final List<String> defaultLanguages = List.unmodifiable(
  ['pt', 'de', 'en', 'es', 'it', 'fr', 'no', 'sv'],
);

/// This are a list of special languages that can be RTL or that need a special
/// build of it's characters. we use this list to avoid check languages that cannot be
/// support and doesn't have characters such as English or Spanish
final List<String> notSupportedLanguages = List.unmodifiable([
  'zh',
  'ru',
  'ja',
  'ko',
  'ar',
  'he',
  'el',
  'hi',
  'th',
  'bn',
  'ta',
  'ur',
  'fa',
  'ml',
  'te',
  'pa',
  'kn',
  'gu',
  'si',
  'my'
]);

final Map<String, String> defaultLanguagesMap = Map.unmodifiable({
  'en': joinEnglishWords,
  'de': joinDeutschWords,
  'es': joinSpanishWords,
  'it': joinItalianWords,
  'fr': joinFrenchWords,
  'no': noWords,
  'sv': svWords,
  'pt': joinPortugueseWords,
});

bool isWordHasNumber(String s) {
  return s.contains(RegExp(r'[0-9]'));
}
