# Simple Spell Checker

SimpleSpellChecker provides a simple and powerful spell checker, allowing developers to detect and highlight spelling errors in text. The package caches language dictionaries and allows customization of languages, providing efficient and adaptable spell-checking for various applications.

## Features

- **Real-time Spell Checking**: Split text into spans with correct and incorrect words, highlighting errors dynamically.
- **Custom Language Support**: Add custom dictionaries for languages not included by default.
- **Caching for Performance**: Automatically caches dictionaries and languages to avoid reloading large text files.
- **Customizable Error Handling**: Optionally use custom gesture recognizers for wrong words, enabling custom interactions.
- **Stream-based State Management**: Provides a stream of updates for spell-checking states, allowing reactive UI updates.

## Current languages supported by default

The package already have a default list of words for these languages:

* German - de_words.txt
* English - en_words.txt
* Spanish - es_words.txt
* French - fr_words.txt
* Italian - it_words.txt
* Norwegian - no_words.txt
* Portuguese - pt_words.txt
* Swedish - sv_words.txt

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
  safeDirectoryLoad: true, // avoid throws UnSupportedError if a custom language is not founded 
);
```
### Check your text:

Use the `check()` method to analyze a `String` for spelling errors:

```dart
List<TextSpan>? result = spellChecker.check(
  'Your text here',
  removeEmptyWordsOnTokenize: true,
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

When you add a custom language you'll need to call always `registerLanguage()` and pass the language code to avoid return null
always when `_checkLanguageRegistry()` it's called _(this method ensure to check if the current state of the language in `SimpleSpellChecker` is already registered with the other ones)_.

## Additional Information

### Language Management

* **setNewLanguageToState(String language)**: override the current language into the Spellchecker.
* **registerLanguage(String language)**: Add a new language to the cache with the default ones supported.
* **reloadDictionarySync()**: Reload the dictionary synchronously to update the language or dictionary.

### Customization Options

* **checkBuilder**: Use the checkBuilder() method for a custom widget-based approach to handling spelling errors.
* **customLongPressRecognizerOnWrongSpan**: Attach custom gesture recognizers to wrong words for tailored interactions.

### Caching

The package uses caching mechanisms (`CacheObject`) to store loaded dictionaries and languages, significantly reducing the load time when checking large texts.
State Management

* **Language Caching**: The package caches language identifiers and word dictionaries to avoid reloading them multiple times, which is particularly useful for large dictionaries.
* **Custom Language Caching**: When adding custom languages, they are cached automatically to improve performance.

### Stream Updates

The `SimpleSpellChecker` class provides a stream (stream getter) that broadcasts updates whenever the spell-checker state changes (by now, we just pass the current state of the object list that is always updated when add a new object). This is useful for reactive UI updates.

```dart
spellChecker.stream.listen((event) {
  print("Spell check state updated.");
});
```
### Disposing of Resources

When the `SimpleSpellChecker` is no longer needed, ensure you dispose of it properly:

```dart
//Avoid reuse this spellchecker after dispose since it will throws error
spellChecker.dispose();
```

This clears any cached data and closes the internal stream to prevent memory leaks.

## Contributions

If you find a bug or want to add a new feature, please open an **issue** or submit a **pull request** on the [GitHub repository](https://github.com/CatHood0/simple_spell_checker/).

This project is licensed under the **MIT License** - see the [LICENSE](https://github.com/CatHood0/simple_spell_checker/blob/Main/LICENSE) file for details.
