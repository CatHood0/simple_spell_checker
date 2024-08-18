import 'package:flutter_test/flutter_test.dart';
import 'package:simple_spell_checker/src/common/language_identifier.dart';
import 'package:simple_spell_checker/src/spell_checker.dart';
import 'utils/words_testing.dart';

void main() {
  test('Should return a simple map with right parts and wrong parts', () {
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'test',
      safeDirectoryLoad: false,
      customLanguages: [
        LanguageIdentifier(language: 'test', words: wordsTesting),
      ],
    );
    spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'this is a tsr', builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'this': false}, // is not wrong
      {'is': false}, // is not wrong
      {'a': false}, // is not wrong
      {'tsr': true} // is wrong
    ]);
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.registerLanguage('Shouldn\'t add this language');
    }, throwsA(isA<AssertionError>()));
  });
}
