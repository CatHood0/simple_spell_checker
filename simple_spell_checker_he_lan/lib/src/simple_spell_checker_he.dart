import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_he_lan/src/he/join_hebrew_words.dart';

class SimpleSpellCheckerHeRegister {
  static const _splitter = LineSplitter();

  /// `registerHebrewLanguage` can be used to register manually the hebrew 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerHebrewLanguage() {
    if (languagesToBeUsed.containsKey('he')) return;
    SimpleSpellChecker.setLanguage('he', _createDictionary(joinHebrewWords));
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

  static void unRegisterHebrewLanguage() {
    languagesToBeUsed.remove('he');
  }
}
