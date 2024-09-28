// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_en_lan/src/en/gb/join_en_british_words.dart';
import 'package:simple_spell_checker_en_lan/src/en/join_english_words.dart';

class SimpleSpellCheckerEnRegister {
  static const _splitter = LineSplitter();

  /// `registerEnglishLanguage` can be used to register manually the english
  /// language to be supported by the `SimpleSpellChecker`
  ///
  /// [`preferEnglish`] can be only `en` or `en-gb` since just these options
  /// are supported by the `simple_spell_checker_en_lan`
  static void registerEnglishLanguage({String preferEnglish = 'en'}) {
    assert(preferEnglish == 'en' || preferEnglish == 'en-gb',
        'simple_spell_checker_en_lan only support "en" and "en-gb" languages by default. Got $preferEnglish');
    if (languagesToBeUsed.containsKey(preferEnglish)) return;
    if (preferEnglish == 'en') {
      SimpleSpellChecker.setLanguage('en', _createDictionary(joinEnglishWords));
    } else {
      SimpleSpellChecker.setLanguage(
          'en-gb', _createDictionary(joinBritishWords));
    }
  }

  static Map<String, int> _createDictionary(String words) {
    if (words.trim().isEmpty) {
      return {};
    }
    final Iterable<MapEntry<String, int>> entries =
        _splitter.convert(words).map(
              (element) => MapEntry(
                element.trim().toLowerCase(),
                1,
              ),
            );
    return {}..addEntries(entries);
  }

  static void unRegisterEnglishLanguage() {
    languagesToBeUsed.remove('en');
    languagesToBeUsed.remove('en-gb');
  }
}
