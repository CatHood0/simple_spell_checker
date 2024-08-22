import 'dart:async' show Future, Stream, StreamController;
import 'dart:convert' show LineSplitter;
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
import 'package:simple_spell_checker/src/common/tokenizer.dart' show Tokenizer;
import 'package:simple_spell_checker/src/utils.dart'
    show defaultLanguages, defaultLanguagesMap, isWordHasNumber;
import 'common/cache_object.dart' show CacheObject;
import 'common/strategy_language_search_order.dart';

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

  /// if it is true the checker always will be return null
  bool _turnOffChecking = false;

  /// If the current language is not founded on [customLanguages] or default ones,
  /// then select one of the existent to avoid conflicts
  bool safeDictionaryLoad;

  /// Decides how the text will be divided and if the text could be tokenized
  late Tokenizer _wordTokenizer;

  bool caseSensitive;

  /// If safeDictionaryLoad is true, this will be used as the default language to update
  /// the state of SimpleSpellChecker and to store to a existent language with its dictionary
  String safeLanguageName;
  final StreamController<Object?> _simpleSpellCheckerWidgetsState =
      StreamController.broadcast();
  final StreamController<String?> _languageState = StreamController.broadcast();
  LanguageDicPriorityOrder priorityOrder;
  StrategyLanguageSearchOrder strategy;
  SimpleSpellChecker({
    required String language,
    Tokenizer? wordTokenizer,
    bool autoAddLanguagesFromCustomDictionaries = true,
    this.safeDictionaryLoad = false,
    this.safeLanguageName = 'en',
    this.caseSensitive = true,
    @Deprecated('priorityOrder is no longer used. Please use strategy instead')
    this.priorityOrder = LanguageDicPriorityOrder.defaultFirst,
    this.strategy = StrategyLanguageSearchOrder.byPackage,
    this.customLanguages,
  }) {
    _language = language;
    _languageState.add(_language);
    _languagesRegistry.set = [...defaultLanguages];
    _cacheWordDictionary = null;
    _cacheLanguageIdentifier = null;
    _wordTokenizer = wordTokenizer ?? WordTokenizer();
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
    @Deprecated(
        'removeEmptyWordsOnTokenize are no longer used and will be removed in future releases')
    bool removeEmptyWordsOnTokenize = false,
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)?
        customLongPressRecognizerOnWrongSpan,
  }) {
    _addNewEventToWidgetsState(null);
    if (_turnOffChecking) {
      return null;
    }

    _verifyState();
    if (_cacheLanguageIdentifier == null) {
      reloadDictionarySync();
    }
    if (!_checkLanguageRegistry(_language)) {
      return null;
    }
    if (!_wordTokenizer.canTokenizeText(text)) return null;
    final spans = <TextSpan>[];
    final words = _wordTokenizer.tokenize(text);
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
                ),
          ),
        );
      }
      _addNewEventToWidgetsState(spans);
    }
    return [...spans];
  }

  /// Check spelling in realtime
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  /// [customLongPressRecognizerOnWrongSpan] let you add a custom recognizer for when you need to show suggestions
  /// or make some custom action for wrong words
  Stream<List<TextSpan>> checkStream(
    String text, {
    @Deprecated(
        'removeEmptyWordsOnTokenize are no longer used and will be removed in future releases')
    bool removeEmptyWordsOnTokenize = false,
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)?
        customLongPressRecognizerOnWrongSpan,
  }) async* {
    if (_turnOffChecking) {
      yield [];
    }
    _verifyState();
    if (_cacheLanguageIdentifier == null) {
      reloadDictionarySync();
    }
    if (!_checkLanguageRegistry(_language)) {
      yield [];
    }
    if (!_wordTokenizer.canTokenizeText(text)) yield [];
    final spans = <TextSpan>[];
    final words = _wordTokenizer.tokenize(text);
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
  List<T>? checkBuilder<T>(
    String text, {
    required T Function(String, bool) builder,
    @Deprecated(
        'removeEmptyWordsOnTokenize are no longer used and will be removed in future releases')
    bool removeEmptyWordsOnTokenize = false,
  }) {
    _addNewEventToWidgetsState(null);
    if (_turnOffChecking) {
      return null;
    }
    _verifyState();

    if (_cacheLanguageIdentifier == null) {
      reloadDictionarySync();
    }
    if (!_checkLanguageRegistry(_language)) {
      throw UnsupportedError(
          'The $_language is not supported or registered as a custom language. Please, first add your new language using [addNewLanguage] and after add your [customLanguages] to avoid this message.');
    }
    if (!_wordTokenizer.canTokenizeText(text)) return null;
    final spans = <T>[];
    final words = _wordTokenizer.tokenize(text);
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
      _addNewEventToWidgetsState(spans);
    }
    return [...spans];
  }

  void _addNewEventToWidgetsState(Object? object) {
    if (!_simpleSpellCheckerWidgetsState.isClosed || !_disposedControllers) {
      _simpleSpellCheckerWidgetsState.add(object);
    }
  }

  void _addNewEventToLanguageState(String? language) {
    if (!_languageState.isClosed || !_disposedControllers) {
      _languageState.add(language);
    }
  }

  /// a custom implementation that let us subcribe to it and listen
  /// all changes on realtime the list of wrong and right words
  ///
  /// # Note
  /// By default, this stream not update the default [StreamController] of the spans
  /// implemented in the class
  ///
  /// [removeEmptyWordsOnTokenize] this remove empty strings that was founded while splitting the text
  Stream<List<T>> checkBuilderStream<T>(
    String text, {
    required T Function(String, bool) builder,
    @Deprecated(
        'removeEmptyWordsOnTokenize are no longer used and will be removed in future releases')
    bool removeEmptyWordsOnTokenize = false,
  }) async* {
    if (_turnOffChecking) {
      yield [];
    }
    _verifyState();
    if (_cacheLanguageIdentifier == null) {
      reloadDictionarySync();
    }
    if (!_checkLanguageRegistry(_language)) {
      throw UnsupportedError(
          'The $_language is not supported or registered as a custom language. Please, first add your new language using [addNewLanguage] and after add your [customLanguages] to avoid this message.');
    }
    if (!_wordTokenizer.canTokenizeText(text)) yield [];
    final spans = <T>[];
    final words = _wordTokenizer.tokenize(text);
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
  bool isWordValid(String word) {
    // if word is just an whitespace then is not wrong
    if (word.trim().isEmpty) return true;
    _verifyState(alsoCache: true);
    final wordsMap = _cacheWordDictionary?.get ?? {};
    final newWordWithCaseSensitive =
        caseSensitive ? word.toLowerCaseFirst() : word.trim().toLowerCase();
    final int? validWord = wordsMap[newWordWithCaseSensitive];
    return validWord != null;
  }

  /// toggle the state of the checking
  ///
  /// if the current checking is deactivate when this be called then should activate
  /// if the current checking is activate when this be called then should deactivate
  void toggleChecker() {
    _turnOffChecking = !_turnOffChecking;
  }

  bool isCheckerActive() {
    return !_turnOffChecking;
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
    _addNewEventToLanguageState(_language);
  }

  @Deprecated(
      'SetNewPriorityOrder is no longer used. Please, use setNewStrategy instead')
  void setNewPriorityOrder(LanguageDicPriorityOrder priorityOrder) {
    _verifyState();
    this.priorityOrder = priorityOrder;
  }

  void setNewStrategy(StrategyLanguageSearchOrder strategy) {
    _verifyState();
    this.strategy = strategy;
  }

  /// Set a new cusotm Tokenizer instance to be used by the package
  void setNewTokenizer(Tokenizer tokenizer) {
    _verifyState(alsoCache: true);
    _wordTokenizer = tokenizer;
  }

  /// Reset the Tokenizer instance to use the default implementation
  /// crated by the package
  void setWordTokenizerToDefault() {
    _verifyState(alsoCache: true);
    _wordTokenizer = WordTokenizer();
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
    if ((strategy == StrategyLanguageSearchOrder.byUser ||
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

  /// This will return all the words contained on the current state of the dictionary
  String? getDirectionary() {
    _verifyState();
    return _cacheLanguageIdentifier?.get.words;
  }

  /// This will return all the words contained on the current state of the dictionary
  String? getCurrentLanguage() {
    _verifyState();
    return _language;
  }

  Stream get stream {
    _verifyState();
    return _simpleSpellCheckerWidgetsState.stream;
  }

  Stream get languageStream {
    _verifyState();
    return _languageState.stream;
  }

  void reloadStreamStates() {
    _verifyState();
    _simpleSpellCheckerWidgetsState.add(null);
    _languageState.add(null);
  }

  /// Verify if [SimpleSpellChecker] is not disposed yet
  void _verifyState({bool alsoCache = false}) {
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
    if (alsoCache) {
      assert(_cacheWordDictionary != null);
      assert(_cacheLanguageIdentifier != null);
    }
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
}
