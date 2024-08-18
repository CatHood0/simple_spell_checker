import 'package:flutter_test/flutter_test.dart';
import 'package:simple_spell_checker/src/common/language_identifier.dart';
import 'package:simple_spell_checker/src/spell_checker.dart';
import 'utils/words_testing.dart';

void main() {
  test('Should return a simple map with right parts and wrong parts', () {
    final SimpleSpellchecker spellchecker = SimpleSpellchecker(
      language: 'test',
      safeDirectoryLoad: false,
      customDictionaries: [
        LanguageIdentifier(language: 'test', words: wordsTesting),
      ],
    );
    spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'this is a tes', builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'this': false}, // is not wrong
      {'is': false}, // is not wrong
      {'a': false}, // is not wrong
      {'tes': true} // is wrong
    ]);
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.addNewLanguage('Shouldn\'t add this language');
    }, throwsA(isA<AssertionError>()));
  });
}
