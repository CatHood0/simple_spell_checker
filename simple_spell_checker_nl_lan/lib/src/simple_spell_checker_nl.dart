import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker;
import 'package:simple_spell_checker_nl_lan/src/nl/join_dutch_words.dart';

class SimpleSpellCheckerNlRegister {
  static const _splitter = LineSplitter();

  /// this can be used to register manually the dutch
  /// language to be supported by the `SimpleSpellChecker`
  static void registerLan() {
    if (SimpleSpellChecker.containsLanguage('nl')) return;
    SimpleSpellChecker.setLanguage('nl', _createDictionary(joinDutchWords));
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

  static void removeLan() {
    SimpleSpellChecker.removeLanguage('nl');
  }
}
