import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_ru_lan/src/ru/join_russian_words.dart';

class SimpleSpellCheckerRuRegister {
  static const _splitter = LineSplitter();

  /// `registerPortugueseLanguage` can be used to register manually the portuguese 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerRussianLanguage() {
    if (languagesToBeUsed.containsKey('ru')) return;
    SimpleSpellChecker.setLanguage('ru', _createDictionary(joinRussianWords));
  }

  static Map<String, int> _createDictionary(String words) {
    if (words.trim().isEmpty) {
      return {};
    }
    final Iterable<MapEntry<String, int>> entries = _splitter.convert(words).map(
          (element) => MapEntry(
            element.trim().toLowerCase(),
            1,
          ),
        );
    return {}..addEntries(entries);
  }

  static void unRegisterRussianLanguage() {
    languagesToBeUsed.remove('ru');
  }
}
