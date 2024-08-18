import 'dart:async' show Future, Stream, StreamController;
import 'dart:convert';
import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart'
    show
        Colors,
        TextDecoration,
        TextDecorationStyle,
        TextSpan,
        TextStyle,
        visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show
        LanguageIdentifier,
        WordTokenizer,
        defaultLanguages,
        isWordHasNumberOrBracket;
import 'common/cache_object.dart';

CacheObject<LanguageIdentifier>? _cacheLanguageIdentifier;

/// add a cache var to avoid always reload all dictionary (it's a heavy task)
/// and it is automatically reloaded when [_cacheLanguageIdentifier] change
CacheObject<Map<String, int>>? _cacheWordDictionary;

/// add a cache var let us add any custom language
CacheObject<List<String>> _languagesRegistry = CacheObject(
  object: [...defaultLanguages],
);

/// A simple spell checker that split on different spans
/// the wrong words from the right ones.
///
/// SimpleSpellchecker automatically make a cache of the dictionary and languages
/// to avoid always reload a bigger text file with too much words to be parsed to a valid
/// format checking it.
///
//
// if you want to update the language and the directory you will need to use
//
// first:
// [setNewLanguage] method to override the current language from the class
// second:
// [reloadDictionary] or [reloadDictionarySync] methods to set a new state to the directionary
class SimpleSpellChecker {
  late String _language;

  /// By default we only have support for the most used languages
  /// but, we cannot cover all the cases. By this, you can use [customLanguages]
  /// adding the key of the language and your words
  ///
  /// Note: [words] param must be have every element separated by a new line
  List<LanguageIdentifier>? customLanguages;
  bool _disposed = false;
  @visibleForTesting
  bool testingMode = false;

  /// If the current language is not founded on [customLanguages] or default ones,
  /// then select one of the existent to avoid conflicts
  bool safeDirectoryLoad;
  final StreamController<Object?> _simpleSpellCheckerWidgetsState =
      StreamController.broadcast();
  SimpleSpellChecker({
    required String language,
    required this.safeDirectoryLoad,
    bool autoAddLanguagesFromCustomDictionaries = true,
    this.customLanguages,
  }) {
    _language = language;
    if (autoAddLanguagesFromCustomDictionaries) _addLanguagesFromCustomDictionaries();
  }

  /// Check if your line wrong words
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  /// [customLongPressRecognizerOnWrongSpan] let you add a custom recognizer for when you need to show suggestions
  /// or make some custom action for wrong words
  List<TextSpan>? check(
    String text, {
    bool removeEmptyWordsOnTokenize = false,
    LongPressGestureRecognizer Function(String)?
        customLongPressRecognizerOnWrongSpan,
  }) {
    _simpleSpellCheckerWidgetsState.add(null);
    _verifyState();
    if (_cacheLanguageIdentifier == null) {
      reloadDictionarySync();
    }
    if (!_checkLanguageRegistry(_language)) {
      return null;
    }
    if (!WordTokenizer.canTokenizeText(text)) return null;
    final spans = <TextSpan>[];
    final words = WordTokenizer.tokenize(text,
        removeAllEmptyWords: removeEmptyWordsOnTokenize);
    for (var word in words) {
      if (isWordHasNumberOrBracket(text) || !hasWrongWords(word)) {
        spans.add(TextSpan(text: word));
      } else if (hasWrongWords(word)) {
        final longTap = customLongPressRecognizerOnWrongSpan?.call(word);
        spans.add(
          TextSpan(
            text: word,
            recognizer: longTap,
            spellOut: true,
            style: const TextStyle(
              decorationColor: Colors.red,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.wavy,
            ),
          ),
        );
      }
      _simpleSpellCheckerWidgetsState.add([...spans]);
    }
    return [...spans];
  }

  /// a custom implementation for check if your line wrong words and return a custom list of widgets
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  List<T>? checkBuilder<T>(
    String text, {
    required T Function(String, bool) builder,
    bool removeEmptyWordsOnTokenize = false,
  }) {
    _simpleSpellCheckerWidgetsState.add(null);
    _verifyState();
    if (_cacheLanguageIdentifier == null) {
      reloadDictionarySync();
    }
    if (!_checkLanguageRegistry(_language)) {
      throw UnsupportedError(
          'The $_language is not supported or registered as a custom language. Please, first add your new language using [addNewLanguage] and after add your [customLanguages] to avoid this message.');
    }
    if (!WordTokenizer.canTokenizeText(text)) return null;
    final spans = <T>[];
    final words = WordTokenizer.tokenize(text,
        removeAllEmptyWords: removeEmptyWordsOnTokenize);
    for (var word in words) {
      if (isWordHasNumberOrBracket(word) || !hasWrongWords(word)) {
        spans.add(builder.call(word, true));
      } else if (hasWrongWords(word)) {
        spans.add(builder.call(word, false));
      }
      _simpleSpellCheckerWidgetsState.add([...spans]);
    }
    return [...spans];
  }

  bool hasWrongWords(String word) {
    _verifyState();
    final wordsMap = _cacheWordDictionary?.get ?? {};
    final int validWord = wordsMap[word] ?? -1;
    return validWord == 1;
  }

  bool _checkLanguageRegistry(String language) {
    _verifyState();
    return _languagesRegistry.get.contains(language);
  }

  void setNewLanguageToState(String language) {
    _verifyState();
    assert(language.isNotEmpty,
        'The country code of your language cannot be empty');
    _language = language;
  }

  /// **register the language** with the default ones supported
  /// by the package to let you use customLanguages properly since
  /// we always check if the current language is already registered
  /// on [_languagesRegistry]
  void registerLanguage(String language) {
    _verifyState();
    if (!_languagesRegistry.get.contains(language)) {
      _languagesRegistry.set = [..._languagesRegistry.get, language];
    }
  }

  void _addLanguagesFromCustomDictionaries() {
    _verifyState();
    if (customLanguages == null) return;
    for (var language in customLanguages!) {
      if (!_languagesRegistry.get.contains(language.language)) {
        _languagesRegistry.set = [..._languagesRegistry.get, language.language];
      }
    }
  }

  void addCustomLanguage(LanguageIdentifier language) {
    _verifyState();
    customLanguages ??= [];
    if (!customLanguages!.contains(language)) {
      customLanguages?.add(language);
    }
  }

  /// Verify if [SimpleSpellChecker] is not disposed yet
  void _verifyState() {
    assert(
      !_disposed && !_simpleSpellCheckerWidgetsState.isClosed,
      'You cannot reuse this SimpleSpellchecker since you dispose it before',
    );
  }

  /// Use dispose when you don't need the SimpleSpellchecker already
  void dispose({bool closeDirectionary = true}) {
    if (closeDirectionary) _cacheWordDictionary = null;
    _cacheLanguageIdentifier = null;
    _simpleSpellCheckerWidgetsState.close();
    _disposed = true;
  }

  Future<void> reloadDictionary() async {
    _verifyState();
    reloadDictionarySync();
  }

  void reloadDictionarySync() async {
    _verifyState();
    if (_cacheLanguageIdentifier?.get.language == _language) return;
    // check if the current language is not registered already
    if (!defaultLanguages.contains(_language) || testingMode) {
      final indexOf = customLanguages
          ?.indexWhere((element) => element.language == _language);
      final invalidIndex = (indexOf == null || indexOf == -1);
      if (invalidIndex && !safeDirectoryLoad) {
        throw UnsupportedError(
          'The $_language is not supported by default and was not founded on your [customLanguages]. We recommend always add first your custom LanguageIdentifier and after set your custom language to avoid this type of errors.',
        );
      } else if (invalidIndex && safeDirectoryLoad) {
        setNewLanguageToState('en');
        reloadDictionarySync();
        return;
      }
      final LanguageIdentifier identifier =
          customLanguages!.elementAt(indexOf!);
      _initDictionary(identifier);
      return;
    }
    final dictionary =
        await rootBundle.loadString('assets/${_language}_words.txt');
    _initDictionary(LanguageIdentifier(language: _language, words: dictionary));
  }

  void _initDictionary(LanguageIdentifier identifier) {
    if (_cacheWordDictionary == null) {
      _cacheLanguageIdentifier = CacheObject(object: identifier);
    } else {
      _cacheLanguageIdentifier!.set = identifier;
    }
    final Iterable<MapEntry<String, int>> entries =
        const LineSplitter().convert(_cacheLanguageIdentifier!.get.words).map(
              (element) => MapEntry(element, 1),
            );
    if (entries.isNotEmpty) {
      final Map<String, int> wordsMap = {}..addEntries(entries);
      _cacheWordDictionary ??= CacheObject(object: {});
      _cacheWordDictionary!.set = wordsMap;
    }
  }

  Stream get stream {
    _verifyState();
    return _simpleSpellCheckerWidgetsState.stream;
  }

  void reloadStreamState() {
    _verifyState();
    _simpleSpellCheckerWidgetsState.add(null);
  }

  /// This will return all the words contained on the current state of the dictionary
  String? getDirectionary() {
    _verifyState();
    return _cacheLanguageIdentifier?.get.words;
  }
}
