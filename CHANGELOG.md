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
