import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker;
import 'package:simple_spell_checker_et_lan/src/et/join_estonian_words.dart';

class SimpleSpellCheckerEtRegister {
  static const _splitter = LineSplitter();

  /// `registerEstonianLanguage` can be used to register manually the estonian
  /// language to be supported by the `SimpleSpellChecker`
  static void registerEstonianLanguage() {
    if (SimpleSpellChecker.containsLanguage('et')) return;
    SimpleSpellChecker.setLanguage('et', _createDictionary(joinEstonianWords));
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

  static void unRegisterEstonianLanguage() {
    SimpleSpellChecker.removeLanguage('et');
  }
}
