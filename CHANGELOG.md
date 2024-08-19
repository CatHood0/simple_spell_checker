## 1.1.0

* Fix: avoid spellchecker default behavior when the current language like chinese, japanese, russian, etc that for now it's characters are not registered
* Feat: added more characteres to add better support for the default implementation 
* Feat: support for custom word tokenizer
* Feat: support for realtime subscription to changes using directly `checkStream` or `checkBuilderStream` instead controllers

## 1.0.9 

* Fix: restore a removed character that is needed to avoid missing character while typing

## 1.0.8

* Fix(de): Deutsch language cause some characters are ignore like: `ẅ`, `ä`, `ë`, `ï`, `ö`, `ÿ`, etc

## 1.0.7

* Fix: words with accents are detected as a special character instead a common word
* Fix: bad updating of cache instances when initalize different instances
* Chore: added some missing translations for english and spanish

## 1.0.6

* Fix: accents are ignored
* Chore: more missing words and sentences for spanish translation

## 1.0.5

* Fix: several language characters are ignored
* Chore: added some missing words for spanish translation

## 1.0.4

* Fix: line is ignored directly if contains a special character (like: "(", "[", etc)
* Feat: improved separator regexp to divide also special chars from the words
* Feat: more translations for `pt`, `de`, `en`, `es`, `it` and `fr` languages
* Feat: ability to close controller if we don't need them
* Feat: ability to override any current language if exist in `customLanguages`
* Feat: added priority order when the directionary is realoding using `LanguageDicPriorityOrder` enum 
* Feat: now we can set a default safeLanguageName to the `SimpleSpellChecker` instead pref `en` translation always

## 1.0.3

* Fix: unable to load assets

## 1.0.2

* Fix: whitespaces are removed or ignored

## 1.0.1

* Fix: typo on `SimpleSpellChecker` class and README 
* Doc: more docs about `LanguageIdentifier` 

## 1.0.0

Initial commit
