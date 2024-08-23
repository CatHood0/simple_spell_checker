import 'package:simple_spell_checker/src/dictionaries/bg/join_bulgarian_words.dart';
import 'package:simple_spell_checker/src/dictionaries/da/join_danish_words.dart';
import 'package:simple_spell_checker/src/dictionaries/de/ch/join_deutsch_ch_words.dart';
import 'package:simple_spell_checker/src/dictionaries/de/join_deutsch_words.dart';
import 'package:simple_spell_checker/src/dictionaries/en/gb/join_en_british_words.dart';
import 'package:simple_spell_checker/src/dictionaries/en/join_english_words.dart';
import 'package:simple_spell_checker/src/dictionaries/es/join_es_words.dart';
import 'package:simple_spell_checker/src/dictionaries/et/join_estonian_words.dart';
import 'package:simple_spell_checker/src/dictionaries/fr/join_french_words.dart';
import 'package:simple_spell_checker/src/dictionaries/he/join_hebrew_words.dart';
import 'package:simple_spell_checker/src/dictionaries/it/join_italian_words.dart';
import 'package:simple_spell_checker/src/dictionaries/ko/join_korean_words.dart';
import 'package:simple_spell_checker/src/dictionaries/nl/join_dutch_words.dart';
import 'package:simple_spell_checker/src/dictionaries/no/join_norwegian_words.dart';
import 'package:simple_spell_checker/src/dictionaries/pt/join_portuguese_words.dart';
import 'package:simple_spell_checker/src/dictionaries/ru/join_russian_words.dart';
import 'package:simple_spell_checker/src/dictionaries/sk/join_slovak_words.dart';
import 'package:simple_spell_checker/src/dictionaries/sv/join_swedish_words.dart';

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

final Map<String, String> defaultLanguagesMap = Map.unmodifiable({
  'en': joinEnglishWords,
  'en-gb': joinBritishWords,
  'de': joinDeutschWords,
  'de-ch': joinDeutschSwitzerlandWords,
  'es': joinSpanishWords,
  'it': joinItalianWords,
  'fr': joinFrenchWords,
  'no': joinNowergianWords,
  'ko': joinKoreanWords,
  'sv': joinSwedishWords,
  'he': joinHebrewWords,
  'et': joinEstonianWords,
  'ca': joinDanishWords,
  'sk': joinSlovakWords,
  'nl': joinDutchWords,
  'pt': joinPortugueseWords,
  'bg': joinBulgarianWords,
  'ru': joinRussianWords,
});

bool isWordHasNumber(String s) {
  return s.contains(RegExp(r'[0-9]'));
}
