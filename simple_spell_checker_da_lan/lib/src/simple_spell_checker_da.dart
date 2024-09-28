// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker;
import 'package:simple_spell_checker_da_lan/src/da/join_danish_words.dart';

class SimpleSpellCheckerDaRegister {
  static const _splitter = LineSplitter();

  /// `registerDanishLanguage` can be used to register manually the danish 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerDanishLanguage() {
    if (SimpleSpellChecker.containsLanguage('da')) return;
    SimpleSpellChecker.setLanguage('da', _createDictionary(joinDanishWords));
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

  static void unRegisterDanishLanguage() {
    SimpleSpellChecker.removeLanguage('da');
  }
}
