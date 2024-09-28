import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_ko_lan/src/ko/join_korean_words.dart';

class SimpleSpellCheckerKoRegister {
  static const _splitter = LineSplitter();

  /// `registerKoreanLanguage` can be used to register manually the korean
  /// language to be supported by the `SimpleSpellChecker`
  static void registerKoreanLanguage() {
    if (languagesToBeUsed.containsKey('ko')) return;
    SimpleSpellChecker.setLanguage('ko', _createDictionary(joinKoreanWords));
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

  static void unRegisterKoreanLanguage() {
    languagesToBeUsed.remove('ko');
  }
}
