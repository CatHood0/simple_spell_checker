# Simple Spell Checker

![simple spell checker example preview](https://github.com/CatHood0/resources/blob/Main/simple_spell_checker/clideo_editor_49b21800e993489fa4cdbbd160ffd60c%20(online-video-cutter.com).gif)

`SimpleSpellChecker` is a simple but powerful spell checker, that allows to all developers detect and highlight spelling errors in text. _The package caches language dictionaries_ and allows customization of languages, providing efficient and adaptable spell-checking for various applications.

## Features

- **Real-time Spell Checking**: Split text into spans with correct and incorrect words, highlighting errors dynamically.
- **Custom Language Support**: Add custom dictionaries for languages not included by default.
- **Caching for Performance**: Automatically caches dictionaries and languages to avoid reloading large text files.
- **Customizable Error Handling**: Optionally use custom gesture recognizers for wrong words, enabling custom interactions.
- **Stream-based State Management**: Provides a stream of updates for spell-checking states, allowing reactive UI updates.

## Current languages supported (more languages will be added in future releases)

The package already have a default list of words for these languages:

* German - `de`
* English - `en`
* Spanish - `es`
* French - `fr`
* Italian - `it`
* Norwegian - `no`
* Portuguese - `pt`
* Swedish - `sv`

## Getting Started

To use the `SimpleSpellChecker` in your `Flutter` project, follow these steps:

1. **Add the Dependency**:

Add the following line to your `pubspec.yaml` file:

```yaml
dependencies:
  simple_spell_checker: <latest_version>
```

Import the necessary components into your `Dart` file and initialize the Spell-Checker:

 ```dart
import 'package:simple_spell_checker/simple_spell_checker.dart';

SimpleSpellChecker spellChecker = SimpleSpellChecker(
   language: 'en', // the current language that the user is using
   safeLanguageName: 'en', // when was not founded a custom language and safeDictionaryLoad is true this value is used
   safeDictionaryLoad: true, // avoid throws UnSupportedError if a custom language is not founded 
   caseSensitive: false,
);
```
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

### Handling Custom Languages:

Add and use `addCustomLanguage()` by updating the `customLanguages` parameter:

```dart
final LanguageIdentifier languageId = LanguageIdentifier(language: 'custom_lang', words: '<your_dictionary>');
// this need to be called for cases when we check if the language into the Spellchecker is already registered
// then, if the language on SimpleSpellChecker
spellChecker.registerLanguage(languageId.language);
spellChecker.addCustomLanguage(languageId);
// to set this new custom language to the state of the [SimpleSpellChecker] then use:
spellChecker.setNewLanguageToState(languageId.language);
```

#### Note:

When you add a custom language you will need to call `registerLanguage()` and pass the language id to avoid return null in `check()` or `checkBuilder()` method since it always call `_checkLanguageRegistry()` to ensure to check if the current state of the language in `SimpleSpellChecker` is already registered with the other ones).

## Additional Information

### Language Management

* **setNewLanguageToState(String language)**: override the current language into the Spellchecker.
* **registerLanguage(String language)**: Add a new language to the cache with the default ones supported.
* **updateCustomLanguageIfExist(LanguageIdentifier language)**: override the current value if exist in `customLanguages` var.
* **reloadDictionarySync()**: Reload the dictionary synchronously to update the language or dictionary.

### State 

* **toggleChecker()**: activate or deactivate the spell checking. If it is deactivate `check()` methods always will return null 
* **isCheckerActive()**: return the state of the spell checker.

### Customization Options

* **checkBuilder**: Use the `checkBuilder()` method for a custom widget-based approach to handling spelling errors.
* **setNewStrategy**: Use the `setNewStrategy()` method to modify the current value to change the behvarior if the dictionary is reloaded.
* **customLongPressRecognizerOnWrongSpan**: Attach custom gesture recognizers to wrong words for tailored interactions.

### Caching

The package uses caching mechanisms (`CacheObject`) to store loaded dictionaries and languages, significantly reducing the load time when checking large texts.

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

## Contributions

If you find a bug or want to add a new feature, please open an **issue** or submit a **pull request** on the [GitHub repository](https://github.com/CatHood0/simple_spell_checker/).

This project is licensed under the **MIT License** - see the [LICENSE](https://github.com/CatHood0/simple_spell_checker/blob/Main/LICENSE) file for details.
