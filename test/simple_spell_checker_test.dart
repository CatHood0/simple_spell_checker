import 'package:flutter_test/flutter_test.dart';
import 'package:simple_spell_checker/src/spell_checker.dart';

void main() {
  test('Should return a simple map with right parts and wrong parts', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'en',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content =
        spellchecker.checkBuilder<Map<String, bool>>('this is a tsr (with) sme errors', builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'this ': false}, // is not wrong
      {'is ': false}, // is not wrong
      {'a ': false}, // is not wrong
      {'tsr': true}, // is wrong
      {' ': false}, // is wrong
      {'(': false},
      {'with': false}, // is not wrong
      {') ': false},
      {'sme': true}, // is wrong
      {' ': false}, // is wrong
      {'errors': false}, // is not wrong
    ]);
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.registerLanguage('Shouldn\'t add this language');
    }, throwsA(isA<AssertionError>()));
  });
}
