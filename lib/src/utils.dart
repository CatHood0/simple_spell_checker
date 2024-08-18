import 'package:simple_spell_checker/src/dictionaries/de_words.dart';
import 'package:simple_spell_checker/src/dictionaries/en_words.dart';
import 'package:simple_spell_checker/src/dictionaries/es_words.dart';
import 'package:simple_spell_checker/src/dictionaries/fr_words.dart';
import 'package:simple_spell_checker/src/dictionaries/it_words.dart';
import 'package:simple_spell_checker/src/dictionaries/no_words.dart';
import 'package:simple_spell_checker/src/dictionaries/pt_words.dart';
import 'package:simple_spell_checker/src/dictionaries/sv_words.dart';

final List<String> defaultLanguages = List.unmodifiable(
  ['pt', 'de', 'en', 'es', 'it', 'fr', 'no', 'sv'],
);

final Map<String, String> defaultLanguagesMap = {
  'en': enWords,
  'de': deWords,
  'es': esWords,
  'it': itWords,
  'fr': frWords,
  'no': noWords,
  'sv': svWords,
  'pt': ptWords,
};


bool isWordHasNumberOrBracket(String s) {
  return s.contains(RegExp(r'[0-9\()]'));
}
