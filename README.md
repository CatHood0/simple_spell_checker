# Simple Spell Checker

![simple spell checker example preview](https://github.com/CatHood0/resources/blob/Main/simple_spell_checker/clideo_editor_49b21800e993489fa4cdbbd160ffd60c%20(online-video-cutter.com).gif)

**Simple Spell Checker** is a simple but powerful spell checker, that allows to all developers detect and highlight spelling errors in text. The package also allows customization of languages, providing efficient and adaptable spell-checking for various applications.

## Use with caution

**Simple Spell Checker** is a client-side dependency that works without any need for an internet connection, so, it could weigh more than expected due to each of the dictionaries. As mentioned below, it supports a very wide variety of languages which can have a file of up to 300.000 words (this being just one language, since there are others such as Russian that contain up to 400.000 words), which makes the package increase in size more than expected. If you want to avoid your application increasing in size significantly, the best thing you can do is use the native solution [DefaultSpellCheckService](https://api.flutter.dev/flutter/services/DefaultSpellCheckService-class.html) to avoid this.

## Features

- **Real-time Spell Checking**: Split text into spans with correct and incorrect words, highlighting errors dynamically.
- **Custom Language Support**: Add custom dictionaries for languages not included by default.
- **Caching for Performance**: Automatically caches dictionaries and languages to avoid reloading large text files.
- **Customizable Error Handling**: Optionally use custom gesture recognizers for wrong words, enabling custom interactions.
- **Stream-based State Management**: Provides a stream of updates for spell-checking states, allowing reactive UI updates.

## Current languages supported

The package already have a default list of words for these languages:

* German - `de`, `de-ch` 
* English - `en`, `en-gb`
* Spanish - `es`
* Catalan - `ca`
* Arabic - `ar`
* Danish - `da`
* French - `fr`
* Bulgarian - `bg`
* Dutch - `nl`
* Korean - `ko`
* Estonian - `et`
* Hebrew - `he`
* Slovak - `sk`
* Italian - `it`
* Norwegian - `no`
* Portuguese - `pt`
* Swedish - `sv`
* Russian - `ru`

## Getting Started

**Add the Dependency**:

```yaml
dependencies:
  simple_spell_checker: <latest_version>
```

**Import the necessary components into your `Dart` file and initialize the Spell-Checker**:

### SimpleSpellChecker 

`SimpleSpellChecker` is a single language checker.

 ```dart
import 'package:simple_spell_checker/simple_spell_checker.dart';

SimpleSpellChecker spellChecker = SimpleSpellChecker(
   language: 'en', // the current language that the user is using
   // if we have a current custom language and it is not found into the custom languages this value is used
   safeLanguageName: 'es', 
   // avoid throws UnSupportedError if a custom language is not founded
   safeDictionaryLoad: true,  
   // if the language if not founded creates an empty instance to replace the not founded lan
   worksWithoutDictionary: true, 
   // byPackage | byUser -> defines if the language need to be searched first in customLanguages or in the default ones
   strategy: StrategyLanguageSearchOrder.byPackage, 
   // this is a list of words that will be ignored by check ops
   whiteList: <String>[],  
   customLanguages: <LanguageIdentifier>[],
   // if is true, will take all languages into [customLanguages] to add them to the registry
   autoAddLanguagesFromCustomDictionaries: false,
   caseSensitive: false,
);
```

### MultiSpellChecker 

`MultiSpellChecker` is a instance of the same type of `SimpleSpellChecker` but this one let us add multiple languages to be checked in real-time.

 ```dart
import 'package:simple_spell_checker/simple_spell_checker.dart';

MultiSpellChecker spellChecker = MultiSpellChecker(
   // the current languages that the user is using and correspond with english, russian, italian, and british english
   language: ['en', 'ru', 'it', 'en-gb'], 
   // if we have a current custom language and it is not found into the custom languages this value is used
   safeLanguageName: 'en', 
   // avoid throws UnSupportedError if a custom language is not founded
   safeDictionaryLoad: true,  
   // if the language if not founded creates an empty instance to replace the not founded lan
   worksWithoutDictionary: true, 
   // byPackage | byUser -> defines if the language need to be searched first in customLanguages or in the default ones
   strategy: StrategyLanguageSearchOrder.byPackage, 
   // this is a list of words that will be ignored by check ops
   whiteList: [],  
   customLanguages: <LanguageIdentifier>[],
   // if is true, will take all languages into [customLanguages] to add them to the registry
   autoAddLanguagesFromCustomDictionaries: false,
   caseSensitive: false,
);
```

## Check functions

### Check your text:

Use the `check()` method to analyze a `String` for spelling errors:

```dart
List<TextSpan>? result = spellChecker.check(
  'Your text here',
  wrongStyle: TextStyle(backgroundColor: Colors.red.withOpacity(0.2)), // set you custom style to the wrong spans 
  commonStyle: TextStyle(your_normal_styles_for_non_wrong_words), 
);
```

### Check your text using a custom builder:

Use the `checkBuilder<T>()` method to analyze a `String` for spelling errors and build your own widget with the text:

```dart
List<Widget>? result = spellChecker.checkBuilder<Widget>(
  'Your text here',
  builder: (word, isWrong) {
    return Text(word, style: TextStyle(color: isWrong ? Colors.red : null));
  }
);
```

## Word tokenizer customization

### Creating your custom `Tokenizer`

Use the `wordTokenizer` param from constructor to set a custom instance of your `Tokenizer` or use `setNewTokenizer()` or `setWordTokenizerToDefault()`.

#### Example of a custom `Tokenizer`:

```dart
/// custom tokenizer implemented by the package
class CustomWordTokenizer extends Tokenizer {
  CustomWordTokenizer() : super(separatorRegExp: RegExp(r'\S+|\s+'));

  @override
  bool canTokenizeText(String text) {
    return separatorRegExp!.hasMatch(text);
  }

  /// Divides a string into words
  @override
  List<String> tokenize(
    String content, {
    bool removeAllEmptyWords = false,
  }) {
    final List<String> words = separatorRegExp!.allMatches(content).map((match) => match.group(0)!).toList();
    return [...words];
  }
}
```

## Handling Custom Languages:

Add and use `addCustomLanguage()` by updating the `customLanguages` parameter:

### SimpleSpellChecker

```dart
// You dictionary should be a string splitted by new lines
// since this is the current format supported 
//
// Note: this could change in future releases
final LanguageIdentifier identifier = LanguageIdentifier(language: 'custom_lang', words: '<your_dictionary>');
// this need to be called for cases when we check if the language into the Spellchecker is already registered
// then, if the language on SimpleSpellChecker
spellChecker.registerLanguage(identifier.language);
// this method add new custom language to the current ones
// with it's own custom dictionary
spellChecker.addCustomLanguage(identifier);
// to set this new custom language to the state of the [SimpleSpellChecker] then use:
spellChecker.setNewLanguageToState(identifier.language);
```

### MultiSpellChecker

```dart
final LanguageIdentifier identifier = LanguageIdentifier(language: 'custom_lang', words: '<your_dictionary>');
// this need to be called for cases when we check if the language into the Spellchecker is already registered
// then, if the language on SimpleSpellChecker
spellChecker.registerLanguage(identifier.language);
// this method to update the state automatically adding this 
// new language identifier to the current languages in the state
spellChecker.addCustomLanguage(identifier);
```

### Note:

When you add a custom language you will need to call `registerLanguage()` and pass the language id to avoid throw an `UnSupportedError` in `check()` or `checkBuilder()` method since it always check if the current state of the language/languages, is/are already registered with the other ones.

## Additional Information

### Language Management

* **setNewLanguageToState(String language)**: override the current language into the Spell Checker. _Only available for `SimpleSpellChecker` instances_
* **setNewLanguageToCurrentLanguages(String language)**: add the language to the current ones into the Spell Checker. _Only available for `MultiSpellChecker` instances_
* **setNewLanState(List languages)**: override the current languages into the Spell Checker. _Only available for `MultiSpellChecker` instances_
* **registerLanguage(String language)**: Add a new language to the registries (the registry is a different instance that the current languages that contains all languages available and is used in `check()` methods to avoid check if the language is not available _however, this is overrided if `worksWithoutDictionary` is true_).
* **updateCustomLanguageIfExist(LanguageIdentifier language, bool withException)**: override the current value if exist in `customLanguages` var.
* **reloadDictionarySync()**: Reload the dictionary synchronously to update the language or dictionary.

### White List Management

* **SetNewWhiteList(List words)**: override the current white list into the Spell Checker.
* **addNewWordToWhiteList(String words)**: add a new word to the white list.
* **whiteList**: return the current white list state.

### State Management 

* **toggleChecker()**: activate or deactivate the spell checking. If it is deactivate `check()` methods always will return null 
* **isCheckerActive()**: return the state of the spell checker.

### Customization Options

* **checkBuilder**: Use the `checkBuilder()` method for a custom widget-based approach to handling spelling errors.
* **setNewStrategy**: Use the `setNewStrategy()` method to modify the current value to change the behvarior if the dictionary is reloaded.
* **customLongPressRecognizerOnWrongSpan**: Attach custom gesture recognizers to wrong words for tailored interactions.

### Caching

The package uses caching mechanisms to store loaded dictionaries and languages, significantly reducing the load time when checking large texts. The cache mechanisms share the same instances used by both type of the Spell Checkers (`SimpleSpellChecker` and `MultiSpellChecker`).

* **Language Caching**: The package caches language identifiers and word dictionaries to avoid reloading them multiple times, which is particularly useful for large dictionaries.
* **Custom Language Caching**: When adding custom languages, they are cached automatically to improve performance.

### Stream Updates

The `SimpleSpellChecker` class provides a stream (stream getter) that broadcasts updates whenever the spell-checker state changes (by now, we just pass the current state of the object list that is always updated when add a new object). This is useful for reactive UI updates.

#### Native methods streams without using `StreamController`

Use the `checkStream()` or `checkBuilderStream<T>()` method to analyze a `String` for spelling errors:

_Note: this functions let us dispose the controllers using `disposeControllers()` without lost the realtime functionality_.

```dart
late StreamSubscription subscription;
subscription = spellChecker 
   .checkStream(
      'Your text here',
      removeEmptyWordsOnTokenize: true,
   )
   .listen(
      (List<TextSpan> data) {},
);
/// remenber call cancel
subscription.cancel();
```
or 

```dart
late StreamSubscription subscription;
subscription = spellChecker
    .checkBuilderStream<Widget>(
      'Your text here',
      builder: (word, isWrong) {
        return Text(word, style: TextStyle(color: isWrong ? Colors.red : null));
      },
  ).listen(
    (List<Widget> data) {},
);

/// remenber call cancel
subscription.cancel();
```

#### For listen the list of the widgets while is checking:

```dart
spellChecker.stream.listen((event) {
  print("Spell check state updated.");
});
```

For listen the changes of the language into SimpleSpellChecker:

```dart
spellChecker.languageStream.listen((event) {
  print("Spell check language state updated.");
});
```

### Disposing of Resources

When the `SimpleSpellChecker` is no longer needed, ensure you dispose of it properly:

```dart
//Avoid reuse this spellchecker after dispose since it will throws error
spellChecker.dispose();
```

Or also, if you don't need listen the StreamControllers then you can dispose them:

```dart
//Avoid reuse the streams of the spellchecker after dispose since it will throws error
spellChecker.disposeControllers();
```

It clears any cached data and closes the internal stream to prevent memory leaks.

## You can create your custom `SpellChecker` extending it from `Checker` class

As you now we create default implementation that can check your text without any issue (as we expect), but sometimes, we could need some different implementation from the default ones. By this, we can create our custom spell checker extending it from `Checker` class that contains all params and
methods used by `MultiSpellChecker` or `SimpleSpellChecker`.

```dart
// if you want to add also the check streams ops
// you ca implement the interface [CheckOperationsStreams]
abstract class Checker<T extends Object, R> with CheckOperations<List<TextSpan>, R>, Disposable, DisposableStreams {

// params
final Set<String> _whiteList = {};
late T _language;

/// if it is true the checker always will be return null
bool _turnOffChecking = false;

/// If the current language is not founded on [customLanguages] or default ones,
/// then select one of the existent to avoid conflicts
late bool _safeDictionaryLoad;

/// If it is true then the spell checker
/// ignores if the dictionary or language is not founded
late bool _worksWithoutDictionary;

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

// methods

@protected
bool get safeDictionaryLoad => _safeDictionaryLoad;

@protected
bool get turnOffChecking => _turnOffChecking;

@protected
void setRegistryToDefault() => _languagesRegistry.set = {...defaultLanguages};

@protected
List<String> get languagesRegistry => List.unmodifiable(_languagesRegistry.get);

/// This will return all the words contained on the current state of the dictionary
T getCurrentLanguage() {
   verifyState();
   return _language;
}

@protected
bool get worksWithoutDictionary => _worksWithoutDictionary;

@protected
void initDictionary(String words);

void addCustomLanguage(LanguageIdentifier language);

/// This method is already defined and doesn't need to be override
/// since it is used to initialize the params into [Checker]
void initializeChecker({...});

/// Verify if [Checker] is not disposed yet
@protected
@mustCallSuper
void verifyState();

// these methods let us add new states to the [StreamControllers] 
// and them are already defined
@protected
@mustCallSuper
void addNewEventToLanguageState(T? language);

@protected
@mustCallSuper
void addNewEventToWidgetsState(Object? object);

// dispose methods
@mustCallSuper
void dispose();

@mustCallSuper
void disposeControllers();

// methods from [CheckOperations] interface
// that need to be implemented by the developer
Future<void> reloadDictionary();
bool isWordValid(String word);
void reloadDictionarySync();
bool checkLanguageRegistry(R language);
T? check(
  String text, {
  TextStyle? wrongStyle,
  TextStyle? commonStyle,
  LongPressGestureRecognizer Function(String)?
      customLongPressRecognizerOnWrongSpan,
});

List<O>? checkBuilder<O>(
  String text, {
  required O Function(String, bool) builder,
});
}
```

## Contributions

If you find a bug or want to add a new feature, please open an **issue** or submit a **pull request** on the [GitHub repository](https://github.com/CatHood0/simple_spell_checker/).

This project is licensed under the **MIT License** - see the [LICENSE](https://github.com/CatHood0/simple_spell_checker/blob/Main/LICENSE) file for details.
