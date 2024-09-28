// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_fr_lan/src/fr/join_french_words.dart';

class SimpleSpellCheckerFrRegister {
  static const _splitter = LineSplitter();

  /// `registerFrenchLanguage` can be used to register manually the french
  /// language to be supported by the `SimpleSpellChecker`
  static void registerFrenchLanguage() {
    if (languagesToBeUsed.containsKey('fr')) return;
    SimpleSpellChecker.setLanguage('fr', _createDictionary(joinFrenchWords));
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

  static void unRegisterFrenchLanguage() {
    languagesToBeUsed.remove('fr');
  }
}
