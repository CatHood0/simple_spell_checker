// ignore: depend_on_referenced_packages
import 'dart:convert';
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show SimpleSpellChecker, languagesToBeUsed;
import 'package:simple_spell_checker_de_lan/src/de/ch/join_deutsch_ch_words.dart';
import 'package:simple_spell_checker_de_lan/src/de/join_deutsch_words.dart';

class SimpleSpellCheckerDeRegister {
  static const _splitter = LineSplitter();

  /// `registerDeutschLanguage` can be used to register manually the deutsch 
  /// language to be supported by the `SimpleSpellChecker`
  static void registerDeutschLanguage({String preferDeutsch = 'de'}) {
    assert(preferDeutsch == 'de' || preferDeutsch == 'de-ch',
        'simple_spell_checker_de_lan only support "de" and "de-ch" languages by default. Got $preferDeutsch');
    if (languagesToBeUsed.containsKey(preferDeutsch)) return;
    if (preferDeutsch == 'de') {
      SimpleSpellChecker.setLanguage('de', _createDictionary(joinDeutschWords));
    } else {
      SimpleSpellChecker.setLanguage(
          'de-ch', _createDictionary(joinDeutschSwitzerlandWords));
    }
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

  static void unRegisterDeutschLanguage() {
    languagesToBeUsed.remove('de');
  }
}
