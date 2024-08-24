import 'dart:async' show Stream, StreamController;
import 'dart:convert' show LineSplitter;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart'
    show Colors, TextDecoration, TextDecorationStyle, TextSpan, TextStyle;
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show LanguageIdentifier, isWordHasNumber;
import 'package:simple_spell_checker/src/common/extensions.dart';
import 'package:simple_spell_checker/src/spell_checker_interface/abtract_checker.dart';
import 'package:simple_spell_checker/src/utils.dart'
    show defaultLanguagesDictionaries, isWordHasNumber;
import 'common/cache_object.dart' show CacheObject;

CacheObject<List<LanguageIdentifier>>? _cacheLanguageIdentifiers;

/// add a cache var to avoid always reload all dictionary (it's a heavy task)
/// and it is automatically reloaded when [_cacheLanguageIdentifier] change
CacheObject<Map<String, int>>? _cacheWordDictionary;

/// A multi spell checker that split on different spans
/// the wrong words from the right ones.
///
/// MultiSpellChecker automatically make a cache of the dictionary and languages
/// to avoid always reload a bigger text file with too much words to be parsed to a valid
/// format checking it.
///
/// This checker use a multiple languages into itself
/// you can see this like you spell checker have selected
/// different languages like: "en", "es", "ru" and if you want
/// to use some word from Russian language the checker can
/// check correctly the Russian word from the other ones
//
// if you want to update the language and the directory you will need to use
//
// first:
// [setNewLanguage] method to override the current language from the class
// second:
// [reloadDictionary] or [reloadDictionarySync] methods to set a new state to the directionary
class MultiSpellChecker extends Checker<List<String>, List<String>> {
  List<LanguageIdentifier>? customLanguages;
  MultiSpellChecker({
    required super.language,
    super.wordTokenizer,
    super.safeDictionaryLoad,
    super.worksWithoutDictionary,
    super.caseSensitive = false,
    super.safeLanguageName,
    super.strategy,
    this.customLanguages,
  }) {
    _cacheWordDictionary = null;
    _cacheLanguageIdentifiers = null;
    initializeChecker(
      language: getCurrentLanguage(),
      safeDictionaryLoad: safeDictionaryLoad,
      worksWithoutDictionary: worksWithoutDictionary,
      safeLanguageName: safeLanguageName,
      strategy: strategy,
      wordTokenizer: wordTokenizer,
      caseSensitive: caseSensitive,
    );
  }

  @protected
  void registryLanguagesFromCustomDictionaries() {
    verifyState();
    customLanguages ??= [];
    for (var identifier in customLanguages!) {
      if (!languagesRegistry.contains(identifier.language)) {
        registerLanguage(identifier.language);
      }
    }
  }

  /// Check if your line wrong words
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  /// [customLongPressRecognizerOnWrongSpan] let you add a custom recognizer for when you need to show suggestions
  /// or make some custom action for wrong words
  @override
  List<TextSpan>? check(
    String text, {
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)?
        customLongPressRecognizerOnWrongSpan,
  }) {
    addNewEventToWidgetsState(null);
    if (turnOffChecking) {
      return null;
    }
    verifyState();
    if (_cacheLanguageIdentifiers == null) {
      reloadDictionarySync();
    }
    if (!checkLanguageRegistry(getCurrentLanguage()) &&
        !worksWithoutDictionary) {
      return null;
    }
    if (!wordTokenizer.canTokenizeText(text)) return null;
    final spans = <TextSpan>[];
    final words = wordTokenizer.tokenize(text);
    for (int i = 0; i < words.length; i++) {
      final word = words.elementAt(i);
      final nextIndex = (i + 1) < words.length - 1 ? i + 1 : -1;
      if (isWordHasNumber(word) ||
          isWordValid(word) ||
          word.contains(' ') ||
          word.noWords) {
        if (nextIndex != -1) {
          final nextWord = words.elementAt(nextIndex);
          if (nextWord.contains(' ')) {
            spans.add(TextSpan(text: '$word$nextWord', style: commonStyle));
            // ignore the next since it was already passed
            i++;
            continue;
          }
        }
        spans.add(TextSpan(text: word, style: commonStyle));
      } else if (!isWordValid(word)) {
        final longTap = customLongPressRecognizerOnWrongSpan?.call(word);
        spans.add(
          TextSpan(
            text: word,
            recognizer: longTap,
            style: wrongStyle ??
                const TextStyle(
                  decorationColor: Colors.red,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.wavy,
                  decorationThickness: 1.75,
                ),
          ),
        );
      }
      addNewEventToWidgetsState(spans);
    }
    return [...spans];
  }

  /// Check spelling in realtime
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  /// [customLongPressRecognizerOnWrongSpan] let you add a custom recognizer for when you need to show suggestions
  /// or make some custom action for wrong words
  @override
  Stream<List<TextSpan>> checkStream(
    String text, {
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)?
        customLongPressRecognizerOnWrongSpan,
  }) async* {
    if (turnOffChecking) {
      yield [];
    }
    verifyState();
    if (_cacheLanguageIdentifiers == null) {
      reloadDictionarySync();
    }
    if (!checkLanguageRegistry(getCurrentLanguage()) &&
        !worksWithoutDictionary) {
      yield [];
    }
    if (!wordTokenizer.canTokenizeText(text)) yield [];
    final spans = <TextSpan>[];
    final words = wordTokenizer.tokenize(text);
    for (int i = 0; i < words.length; i++) {
      final word = words.elementAt(i);
      final nextIndex = (i + 1) < words.length - 1 ? i + 1 : -1;
      if (isWordHasNumber(word) ||
          isWordValid(word) ||
          word.contains(' ') ||
          word.noWords) {
        if (nextIndex != -1) {
          final nextWord = words.elementAt(nextIndex);
          if (nextWord.contains(' ')) {
            spans.add(TextSpan(text: '$word$nextWord', style: commonStyle));
            yield [...spans];
            // ignore the next since it was already passed
            i++;
            continue;
          }
        }
        spans.add(TextSpan(text: word, style: commonStyle));
        yield [...spans];
      } else if (!isWordValid(word)) {
        final longTap = customLongPressRecognizerOnWrongSpan?.call(word);
        spans.add(
          TextSpan(
            text: word,
            recognizer: longTap,
            style: wrongStyle ??
                const TextStyle(
                  decorationColor: Colors.red,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.wavy,
                ),
          ),
        );
        yield [...spans];
      }
    }
    yield [...spans];
  }

  /// a custom implementation for check if your line wrong words and return a custom list of widgets
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  @override
  List<O>? checkBuilder<O>(
    String text, {
    required O Function(String, bool) builder,
  }) {
    addNewEventToWidgetsState(null);
    if (turnOffChecking) {
      return null;
    }
    verifyState();

    if (_cacheLanguageIdentifiers == null) {
      reloadDictionarySync();
    }
    if (!checkLanguageRegistry(getCurrentLanguage()) &&
        !worksWithoutDictionary) {
      throw UnsupportedError(
          'The ${getCurrentLanguage()} is not supported or registered as a custom language. Please, first add your new language using [addNewLanguage] and after add your [customLanguages] to avoid this message.');
    }
    if (!wordTokenizer.canTokenizeText(text)) return null;
    final spans = <O>[];
    final words = wordTokenizer.tokenize(text);
    for (int i = 0; i < words.length; i++) {
      final word = words.elementAt(i);
      final nextIndex = (i + 1) < words.length - 1 ? i + 1 : -1;
      if (isWordHasNumber(word) ||
          isWordValid(word) ||
          word.contains(' ') ||
          word.noWords) {
        if (nextIndex != -1) {
          final nextWord = words.elementAt(nextIndex);
          if (nextWord.contains(' ')) {
            spans.add(builder.call('$word$nextWord', true));
            // ignore the next since it was already passed
            i++;
            continue;
          }
        }
        spans.add(builder.call(word, true));
      } else if (!isWordValid(word)) {
        spans.add(builder.call(word, false));
      }
      addNewEventToWidgetsState(spans);
    }
    return [...spans];
  }

  /// a custom implementation that let us subcribe to it and listen
  /// all changes on realtime the list of wrong and right words
  ///
  /// # Note
  /// By default, this stream not update the default [StreamController] of the spans
  /// implemented in the class
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  @override
  Stream<List<T>> checkBuilderStream<T>(
    String text, {
    required T Function(String, bool) builder,
  }) async* {
    if (turnOffChecking) {
      yield [];
    }
    verifyState();
    if (_cacheLanguageIdentifiers == null) {
      reloadDictionarySync();
    }
    if (!checkLanguageRegistry(getCurrentLanguage()) &&
        !worksWithoutDictionary) {
      throw UnsupportedError(
          'The ${getCurrentLanguage()} is not supported or registered as a custom language. Please, first add your new language using [addNewLanguage] and after add your [customLanguages] to avoid this message.');
    }
    if (!wordTokenizer.canTokenizeText(text)) yield [];
    final spans = <T>[];
    final words = wordTokenizer.tokenize(text);
    for (int i = 0; i < words.length; i++) {
      final word = words.elementAt(i);
      final nextIndex = (i + 1) < words.length - 1 ? i + 1 : -1;
      if (isWordHasNumber(word) ||
          isWordValid(word) ||
          word.contains(' ') ||
          word.noWords) {
        if (nextIndex != -1) {
          final nextWord = words.elementAt(nextIndex);
          if (nextWord.contains(' ')) {
            spans.add(builder.call('$word$nextWord', true));
            yield [...spans];
            // ignore the next since it was already passed
            i++;
            continue;
          }
        }

        spans.add(builder.call(word, true));
        yield [...spans];
      } else if (!isWordValid(word)) {
        spans.add(builder.call(word, false));
        yield [...spans];
      }
    }
    yield [...spans];
  }

  /// Check if the word are registered on the dictionary
  ///
  /// This will throw error if the SimpleSpellChecker is non
  /// initilizated
  @override
  @protected
  bool isWordValid(String word) {
    // if word is just an whitespace then is not wrong
    if (word.trim().isEmpty) return true;
    verifyState(alsoCache: true);
    final wordsMap = _cacheWordDictionary?.get ?? {};
    final newWordWithCaseSensitive =
        caseSensitive ? word.toLowerCaseFirst() : word.trim().toLowerCase();
    final int? validWord = wordsMap[newWordWithCaseSensitive];
    return validWord != null;
  }

  (bool, LanguageIdentifier?) _customContainsLanguage(String lan) {
    customLanguages ??= [];
    for (var language in customLanguages!) {
      if (language.language == lan) return (true, language);
    }
    return (false, null);
  }

  @override
  void reloadDictionarySync() async {
    verifyState();
    _cacheLanguageIdentifiers = null;
    // check if the current language is not registered already
    final List<LanguageIdentifier> dictionaries = [];
    for (var lan in getCurrentLanguage()) {
      final (customContainsLan, identifier) = _customContainsLanguage(lan);
      if (customContainsLan) {
        dictionaries.add(identifier!);
        continue;
      }
      dictionaries.add(
        LanguageIdentifier(
          language: lan,
          words: defaultLanguagesDictionaries[lan] ?? '',
        ),
      );
    }
    _initLanguageCache(dictionaries);
    initDictionary('');
  }

  void _initLanguageCache(List<LanguageIdentifier> identifiers) {
    _cacheLanguageIdentifiers ??= CacheObject(object: []);
    _cacheLanguageIdentifiers!.set = identifiers;
  }

  @override
  @protected
  void setNewLanguageToState(List<String> language) {
    super.setNewLanguageToState(language);
  }

  /// override the current languages
  void setNewLanState(List<String> languages) {
    super.setNewLanguageToState(List.from(languages));
  }

  /// add a new language keeping the current ones
  void setNewLanguageToCurrentLanguages(String language) {
    super.setNewLanguageToState([language, ...getCurrentLanguage()]);
  }

  @override
  @protected
  void initDictionary(String words) {
    _cacheWordDictionary = CacheObject(object: {});
    for (var identifier in _cacheLanguageIdentifiers!.get) {
      final lanWords = identifier.words;
      final Iterable<MapEntry<String, int>> entries =
          const LineSplitter().convert(lanWords).map(
                (element) => MapEntry(
                  element.trim().toLowerCase(),
                  1,
                ),
              );
      final Map<String, int> wordsMap = {};
      wordsMap.addEntries(entries);
      _cacheWordDictionary!.set = {
        ..._cacheWordDictionary!.get,
        ...wordsMap,
      };
    }
  }

  @override
  void dispose({bool closeDictionary = false}) {
    super.dispose();
    if (closeDictionary) _cacheWordDictionary = null;
    _cacheLanguageIdentifiers = null;
  }

  /// This will return all the words contained on the current state of the dictionary
  Map<String, int>? getDictionary() {
    verifyState();
    return _cacheWordDictionary?.get;
  }

  @override
  @protected
  void verifyState({bool alsoCache = false}) {
    super.verifyState();
    if (alsoCache) {
      assert(_cacheWordDictionary != null);
      assert(_cacheLanguageIdentifiers != null);
    }
  }

  @override
  @protected
  bool checkLanguageRegistry(List<String> language) {
    verifyState();
    for (var lan in language) {
      if (!languagesRegistry.contains(lan)) {
        return false;
      }
    }
    return true;
  }

  @override
  void addCustomLanguage(LanguageIdentifier language) {
    verifyState();
    customLanguages ??= [];
    if (!customLanguages!.contains(language)) {
      customLanguages?.add(language);
      if (!getCurrentLanguage().contains(language.language)) {
        setNewLanguageToState([language.language, ...getCurrentLanguage()]);
      }
    }
  }

  void updateCustomLanguageIfExist(LanguageIdentifier language) {
    verifyState();
    customLanguages ??= [];
    if (!customLanguages!.contains(language)) {
      throw StateError(
          'The identifier ${language.language} is not into customLanguages. Please consider add before use update operations');
    }
    int indexOf = customLanguages!
        .indexWhere((element) => element.language == language.language);
    if (indexOf != -1) {
      customLanguages![indexOf] = language;
    }
  }
}
