// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_ca_lan/src/ca/join_catalan_words.dart';

class SimpleSpellCheckerCaRegister {
  static const _splitter = LineSplitter();

  /// `registerCatalanLanguage` can be used to register manually the catalan 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerCatalanLanguage() {
    if (languagesToBeUsed.containsKey('ca')) return;
    SimpleSpellChecker.setLanguage('ca', _createDictionary(joinCatalanWords));
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

  static void unRegisterCatalanLanguage() {
    languagesToBeUsed.remove('ca');
  }
}
