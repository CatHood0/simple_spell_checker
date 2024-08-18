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

final Map<String, String> defaultLanguagesMap = {
  'en': joinEnglishWords,
  'de': joinDeutschWords,
  'es': joinSpanishWords,
  'it': joinItalianWords,
  'fr': joinFrenchWords,
  'no': noWords,
  'sv': svWords,
  'pt': joinPortugueseWords,
};


bool isWordHasNumberOrBracket(String s) {
  return s.contains(RegExp(r'[0-9\()]'));
}
