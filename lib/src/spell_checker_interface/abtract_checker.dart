// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:simple_spell_checker/src/spell_checker_interface/mixin/disposable.dart';
import '../common/cache_object.dart';
import '../common/language_identifier.dart';
import '../common/strategy_language_search_order.dart';
import '../common/tokenizer.dart';
import '../utils.dart';
import '../word_tokenizer.dart';
import 'mixin/check_ops.dart';

/// add a cache var let us add any custom language
CacheObject<List<String>> _languagesRegistry = CacheObject(
  object: [...defaultLanguages],
);

abstract class Checker<T extends Object, R>
    with CheckOperations<List<TextSpan>, R>, Disposable, DisposableStreams {
  late T _language;

  /// if it is true the checker always will be return null
  bool _turnOffChecking = false;

  /// If the current language is not founded on [customLanguages] or default ones,
  /// then select one of the existent to avoid conflicts
  late bool _safeDictionaryLoad;

  /// If it is true then the spell checker
  /// ignores if the dictionary or language is not founded
  late bool _worksWithoutDictionary;

  /// Decides how the text will be divided and if the text could be tokenized
  late Tokenizer _wordTokenizer;

  final bool caseSensitive;

  /// the state of SimpleSpellChecker and to store to a existent language with its dictionary
  /// If _safeDictionaryLoad is true, this will be used as the default language to update
  final String safeLanguageName;
  StrategyLanguageSearchOrder strategy;

  /// decide if the checker is disposed
  bool _disposed = false;

  /// this just can be called on closeControllers
  bool _disposedControllers = false;

  final StreamController<Object?> _simpleSpellCheckerWidgetsState =
      StreamController.broadcast();
  final StreamController<T?> _languageState = StreamController.broadcast();
  Checker({
    required T language,
    Tokenizer? wordTokenizer,
    bool safeDictionaryLoad = false,
    bool worksWithoutDictionary = false,
    this.caseSensitive = true,
    this.safeLanguageName = 'en',
    this.strategy = StrategyLanguageSearchOrder.byPackage,
  }) {
    initializeChecker(
      language: language,
      wordTokenizer: wordTokenizer,
      safeDictionaryLoad: safeDictionaryLoad,
      worksWithoutDictionary: worksWithoutDictionary,
      safeLanguageName: safeLanguageName,
      caseSensitive: caseSensitive,
      strategy: strategy,
    );
  }

  @protected
  Tokenizer get wordTokenizer => _wordTokenizer;

  @protected
  bool get safeDictionaryLoad => _safeDictionaryLoad;

  @protected
  bool get turnOffChecking => _turnOffChecking;

  @protected
  void setRegistryToDefault() {
    _languagesRegistry.set = [...defaultLanguages];
  }

  @protected
  List<String> get languagesRegistry =>
      List.unmodifiable(_languagesRegistry.get);

  @protected
  bool get worksWithoutDictionary => _worksWithoutDictionary;

  @protected
  void initDictionary(String words);

  Stream get languageStream {
    verifyState();
    return _languageState.stream;
  }

  Stream get stream {
    verifyState();
    return _simpleSpellCheckerWidgetsState.stream;
  }

  void addCustomLanguage(LanguageIdentifier language);

  @protected
  void addNewEventToLanguageState(T? language) {
    if (!_languageState.isClosed || !_disposedControllers) {
      _languageState.add(_language);
    }
  }

  @protected
  void addNewEventToWidgetsState(Object? object) {
    if (!_simpleSpellCheckerWidgetsState.isClosed || !_disposedControllers) {
      _simpleSpellCheckerWidgetsState.add(object);
    }
  }

  /// Use dispose when you don't need the SimpleSpellchecker already
  @override
  void dispose() {
    if (!_simpleSpellCheckerWidgetsState.isClosed)
      _simpleSpellCheckerWidgetsState.close();
    if (!_languageState.isClosed) _languageState.close();
    _disposed = true;
    _disposedControllers = true;
  }

  /// Use disposeControllers is just never will be use the StreamControllers
  @override
  void disposeControllers() {
    if (!_simpleSpellCheckerWidgetsState.isClosed)
      _simpleSpellCheckerWidgetsState.close();
    if (!_languageState.isClosed) _languageState.close();
    _disposedControllers = true;
  }

  /// This will return all the words contained on the current state of the dictionary
  T getCurrentLanguage() {
    verifyState();
    return _language;
  }

  /// Initialize important parts of the Checker
  @protected
  void initializeChecker({
    required T language,
    Tokenizer? wordTokenizer,
    bool safeDictionaryLoad = false,
    bool worksWithoutDictionary = false,
    String safeLanguageName = 'en',
    bool caseSensitive = true,
    StrategyLanguageSearchOrder strategy =
        StrategyLanguageSearchOrder.byPackage,
  }) {
    _languagesRegistry.set = [...defaultLanguages];
    addNewEventToWidgetsState(null);
    _language = language;
    addNewEventToLanguageState(_language);
    _safeDictionaryLoad = safeDictionaryLoad;
    _worksWithoutDictionary = worksWithoutDictionary;
    this.strategy = strategy;
    _wordTokenizer = wordTokenizer ?? WordTokenizer();
    reloadDictionarySync();
  }

  bool isCheckerActive() {
    return !_turnOffChecking;
  }

  /// **register the language** with the default ones supported
  /// by the package to let you use customLanguages properly since
  /// we always check if the current language is already registered
  /// on [_languagesRegistry]
  void registerLanguage(String language) {
    verifyState();
    if (!_languagesRegistry.get.contains(language)) {
      _languagesRegistry.set = [..._languagesRegistry.get, language];
    }
  }

  @override
  Future<void> reloadDictionary() async {
    verifyState();
    reloadDictionarySync();
  }

  void reloadStreamStates() {
    verifyState();
    _simpleSpellCheckerWidgetsState.add(null);
    _languageState.add(null);
  }

  void setNewLanguageToState(T language) {
    verifyState();
    _language = language;
    addNewEventToLanguageState(_language);
  }

  void setNewStrategy(StrategyLanguageSearchOrder strategy) {
    verifyState();
    this.strategy = strategy;
  }

  /// Set a new cusotm Tokenizer instance to be used by the package
  void setNewTokenizer(Tokenizer tokenizer) {
    verifyState();
    _wordTokenizer = tokenizer;
  }

  /// Reset the Tokenizer instance to use the default implementation
  /// crated by the package
  void setWordTokenizerToDefault() {
    verifyState();
    _wordTokenizer = WordTokenizer();
  }

  /// toggle the state of the checking
  ///
  /// if the current checking is deactivate when this be called then should activate
  /// if the current checking is activate when this be called then should deactivate
  void toggleChecker() {
    _turnOffChecking = !_turnOffChecking;
  }

  /// Verify if [Checker] is not disposed yet
  @protected
  void verifyState() {
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
}
