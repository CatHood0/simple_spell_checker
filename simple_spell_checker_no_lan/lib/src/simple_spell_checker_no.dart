import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_no_lan/src/no/join_norwegian_words.dart';

class SimpleSpellCheckerNoRegister {
  static const _splitter = LineSplitter();

  /// `registerNorwegianLanguage` can be used to register manually the norwegian 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerNorwegianLanguage() {
    if (languagesToBeUsed.containsKey('no')) return;
    SimpleSpellChecker.setLanguage('no', _createDictionary(joinNowergianWords));
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

  static void unRegisterNorwegianLanguage() {
    languagesToBeUsed.remove('no');
  }
}
