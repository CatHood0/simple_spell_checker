<h1 align="center">Simple Spell Checker</h1>

<p align="center">
<img src=https://github.com/CatHood0/resources/blob/Main/simple_spell_checker/clideo_editor_49b21800e993489fa4cdbbd160ffd60c%20(online-video-cutter.com).gif />
</p>

**Simple Spell Checker** is a simple but powerful spell checker, that allows to all developers detect and highlight spelling errors in text. The package also allows customization of languages, providing efficient and adaptable spell-checking for various applications.

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
   whiteList: <String>[],  
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

Use the `wordTokenizer` param from constructor to set a custom instance of your `Tokenizer` or use `setNewTokenizer()` or `setWordTokenizerToDefault()`. _By default on `MultiSpellChecker` and `SimpleSpellChecker` only accept `Tokenizer` implementations with `List<String>` types only_.

#### Example of a custom `Tokenizer`:

```dart
/// custom tokenizer implemented by the package
class CustomWordTokenizer extends Tokenizer<List<String>> {
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

## Additional Information

### Language Management

* **setNewLanguageToState(String language)**: override the current language into the Spell Checker. _Only available for `SimpleSpellChecker` instances_
* **reloadDictionarySync()**: Reload the dictionary synchronously to update the language or dictionary.

### White List Management

* **SetNewWhiteList(List words)**: override the current white list into the Spell Checker.
* **addNewWordToWhiteList(String words)**: add a new word to the white list.
* **whiteList**: return the current white list state.

### State Management 

* **toggleChecker()**: activate or deactivate the spell checking. If it is deactivate `check()` methods always will return null 
* **isActiveChecking()**: return the state of the spell checker.

### Customization Options

* **checkBuilder**: Use the `checkBuilder()` method for a custom widget-based approach to handling spelling errors.
* **customLongPressRecognizerOnWrongSpan**: Attach custom gesture recognizers to wrong words for tailored interactions.

### Stream Updates

The `SimpleSpellChecker` class provides a stream (stream getter) that broadcasts updates whenever the spell-checker state changes (by now, we just pass the current state of the object list that is always updated when add a new object). This is useful for reactive UI updates.

### For listen the changes of the language into SimpleSpellChecker:

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
