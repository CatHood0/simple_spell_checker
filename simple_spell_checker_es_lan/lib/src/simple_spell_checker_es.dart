// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_es_lan/src/es/join_es_words.dart';

class SimpleSpellCheckerEsRegister {
  static const _splitter = LineSplitter();

  /// `registerEnglishLanguage` can be used to register manually the english
  /// language to be supported by the `SimpleSpellChecker`
  static void registerSpanishLanguage() {
    if (languagesToBeUsed.containsKey('es')) return;
    SimpleSpellChecker.setLanguage('es', _createDictionary(joinSpanishWords));
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

  static void unRegisterEnglishLanguage() {
    languagesToBeUsed.remove('es');
  }
}
