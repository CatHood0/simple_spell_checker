
// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart' show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_bg_lan/src/bg/join_bulgarian_words.dart';

class SimpleSpellCheckerBgRegister {
  static const _splitter = LineSplitter();

  /// `registerBulgarianLanguage` can be used to register manually the arabic 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerBulgarianLanguage() {
    if (languagesToBeUsed.containsKey('bg')) return;
    SimpleSpellChecker.setLanguage('bg', _createDictionary(joinBulgarianWords));
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

  static void unRegisterBulgarianLanguage() {
    languagesToBeUsed.remove('bg');
  }
}