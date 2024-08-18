import 'dart:async' show Future, Stream, StreamController;
import 'dart:convert';
import 'package:flutter/gestures.dart' show LongPressGestureRecognizer;
import 'package:flutter/material.dart'
    show Colors, TextDecoration, TextDecorationStyle, TextSpan, TextStyle;
import 'package:simple_spell_checker/simple_spell_checker.dart'
    show
        LanguageIdentifier,
        WordTokenizer,
        defaultLanguages,
        isWordHasNumber,
        LanguageDicPriorityOrder;
import 'package:simple_spell_checker/src/common/extensions.dart';
import 'package:simple_spell_checker/src/utils.dart';
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

  /// this just can be called on closeControllers
  bool _disposedControllers = false;

  /// If the current language is not founded on [customLanguages] or default ones,
  /// then select one of the existent to avoid conflicts
  bool safeDictionaryLoad;

  bool caseSensitive;

  /// If safeDictionaryLoad is true, this will be used as the default language to update
  /// the state of SimpleSpellChecker and to store to a existent language with its dictionary
  String safeLanguageName;
  final StreamController<Object?> _simpleSpellCheckerWidgetsState =
      StreamController.broadcast();
  final StreamController<String?> _languageState = StreamController.broadcast();
  final LanguageDicPriorityOrder priorityOrder;
  SimpleSpellChecker({
    required String language,
    required this.safeDictionaryLoad,
    this.safeLanguageName = 'en',
    this.caseSensitive = true,
    this.priorityOrder = LanguageDicPriorityOrder.defaultFirst,
    bool autoAddLanguagesFromCustomDictionaries = true,
    this.customLanguages,
  }) {
    _language = language;
    _languageState.add(_language);
    _languagesRegistry.set = [...defaultLanguages];
    _cacheWordDictionary = null;
    _cacheLanguageIdentifier = null;
    reloadDictionarySync();
    if (autoAddLanguagesFromCustomDictionaries)
      _addLanguagesFromCustomDictionaries();
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
    for (int i = 0; i < words.length; i++) {
      final word = words.elementAt(i);
      final nextIndex = (i + 1) < words.length - 1 ? i + 1 : -1;
      if (isWordHasNumber(word) ||
          !hasWrongWords(word) ||
          word.contains(' ') ||
          word.noWords) {
        if (nextIndex != -1) {
          final nextWord = words.elementAt(nextIndex);
          if (nextWord.contains(' ')) {
            spans.add(TextSpan(text: '$word$nextWord'));
            // ignore the next since it was already passed
            i++;
            continue;
          }
        }
        spans.add(TextSpan(text: word));
      } else if (hasWrongWords(word)) {
        final longTap = customLongPressRecognizerOnWrongSpan?.call(word);
        spans.add(
          TextSpan(
            text: word,
            recognizer: longTap,
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
    for (int i = 0; i < words.length; i++) {
      final word = words.elementAt(i);
      final nextIndex = (i + 1) < words.length - 1 ? i + 1 : -1;
      if (isWordHasNumber(word) ||
          !hasWrongWords(word) ||
          word.contains(' ') ||
          word.noWords) {
        if (nextIndex != -1) {
          final nextWord = words.elementAt(nextIndex);
          if (nextWord.contains(' ')) {
            spans.add(builder.call('$word$nextWord', false));
            // ignore the next since it was already passed
            i++;
            continue;
          }
        }
        spans.add(builder.call(word, false));
      } else if (hasWrongWords(word)) {
        spans.add(builder.call(word, true));
      }
      _simpleSpellCheckerWidgetsState.add([...spans]);
    }
    return [...spans];
  }

  bool hasWrongWords(String word) {
    // if word is just an whitespace then is not wrong
    if (word.trim().isEmpty) return false;
    _verifyState();
    final wordsMap = _cacheWordDictionary?.get ?? {};
    final newWordWithCaseSensitive =
        caseSensitive ? word.toLowerCaseFirst() : word.trim().toLowerCase();
    final int? validWord = wordsMap[newWordWithCaseSensitive];
    return validWord == null;
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
    _languageState.add(_language);
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

  void updateCustomLanguageIfExist(LanguageIdentifier language) {
    _verifyState();
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

  /// Verify if [SimpleSpellChecker] is not disposed yet
  void _verifyState() {
    if (!_disposedControllers) {
      assert(
        !_disposed &&
            !_simpleSpellCheckerWidgetsState.isClosed &&
            !_languageState.isClosed,
        'You cannot reuse this SimpleSpellchecker since you dispose it before',
      );
      return;
    }
    assert(!_disposed,
        'You cannot reuse this SimpleSpellchecker since you dispose it before');
  }

  /// Use dispose when you don't need the SimpleSpellchecker already
  void dispose({bool closeDirectionary = true}) {
    if (closeDirectionary) _cacheWordDictionary = null;
    _cacheLanguageIdentifier = null;
    if (!_simpleSpellCheckerWidgetsState.isClosed)
      _simpleSpellCheckerWidgetsState.close();
    if (!_languageState.isClosed) _languageState.close();
    _disposed = true;
    _disposedControllers = true;
  }

  /// Use disposeControllers is just never will be use the StreamControllers
  void disposeControllers() {
    if (!_simpleSpellCheckerWidgetsState.isClosed)
      _simpleSpellCheckerWidgetsState.close();
    if (!_languageState.isClosed) _languageState.close();
    _disposedControllers = true;
  }

  Future<void> reloadDictionary() async {
    _verifyState();
    reloadDictionarySync();
  }

  /// this count about a accidental recursive calling
  int _intoCount = 0;
  void reloadDictionarySync() async {
    _verifyState();
    if (_cacheLanguageIdentifier?.get.language == _language) return;
    // check if the current language is not registered already
    if ((priorityOrder == LanguageDicPriorityOrder.customFirst ||
            !defaultLanguages.contains(_language)) &&
        _intoCount <= 2) {
      final indexOf = customLanguages
          ?.indexWhere((element) => element.language == _language);
      final invalidIndex = (indexOf == null || indexOf == -1);
      if (invalidIndex && !safeDictionaryLoad) {
        throw UnsupportedError(
          'The $_language is not supported by default and was not founded on your [customLanguages]. We recommend always add first your custom LanguageIdentifier and after set your custom language to avoid this type of errors.',
        );
      } else if (invalidIndex && safeDictionaryLoad) {
        setNewLanguageToState(_intoCount >= 2 ? 'en' : safeLanguageName);
        _intoCount++;
        reloadDictionarySync();
        return;
      }
      final LanguageIdentifier identifier =
          customLanguages!.elementAt(indexOf!);
      _initDictionary(identifier);
      return;
    }
    final dictionary = defaultLanguagesMap[_language]!;
    _initDictionary(LanguageIdentifier(language: _language, words: dictionary));
  }

  void _initDictionary(LanguageIdentifier identifier) {
    _intoCount = 0;
    if (_cacheWordDictionary == null) {
      _cacheLanguageIdentifier = CacheObject(object: identifier);
    } else {
      _cacheLanguageIdentifier!.set = identifier;
    }
    final Iterable<MapEntry<String, int>> entries =
        const LineSplitter().convert(identifier.words).map(
              (element) => MapEntry(
                element.trim().toLowerCase(),
                1,
              ),
            );
    final Map<String, int> wordsMap = {};
    wordsMap.addEntries(entries);
    _cacheWordDictionary ??= CacheObject(object: {});
    _cacheWordDictionary!.set = {...wordsMap};
  }

  Stream get stream {
    _verifyState();
    return _simpleSpellCheckerWidgetsState.stream;
  }

  Stream get languageStream {
    _verifyState();
    return _languageState.stream;
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
