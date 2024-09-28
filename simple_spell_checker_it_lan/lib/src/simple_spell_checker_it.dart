import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_it_lan/src/it/join_italian_words.dart';

class SimpleSpellCheckerItRegister {
  static const _splitter = LineSplitter();

  /// `registerItalianLanguage` can be used to register manually the italian 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerItalianLanguage() {
    if (languagesToBeUsed.containsKey('it')) return;
    SimpleSpellChecker.setLanguage('it', _createDictionary(joinItalianWords));
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

  static void unRegisterItalianLanguage() {
    languagesToBeUsed.remove('it');
  }
}
