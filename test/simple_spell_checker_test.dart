import 'package:flutter_test/flutter_test.dart';
import 'package:simple_spell_checker/src/spell_checker.dart';

void main() {
  test('Should return a simple map with right parts and wrong parts in english',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'en',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'this is a tśr (with) sme errors', builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'this ': false}, // is not wrong
      {'is ': false}, // is not wrong
      {'a ': false}, // is not wrong
      {'tśr': true}, // is wrong
      {' ': false}, // is wrong
      {'(': false},
      {'with': false}, // is not wrong
      {') ': false},
      {'sme': true}, // is wrong
      {' ': false}, // is not wrong
      {'errors': false}, // is not wrong
    ]);
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.registerLanguage('Shouldn\'t add this language');
    }, throwsA(isA<AssertionError>()));
  });

  // TODO: you will need to add test where there are words with accents at the middle at them should be wrong
  test('Should return a simple map with right parts and wrong parts in spanish',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'es',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'Ésto es un tesr (con) alnu errores', builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Ésto ': false}, // is not wrong
      {'es ': false}, // is not wrong
      {'un ': false}, // is not wrong
      {'tesr': true}, // is wrong
      {' ': false}, // is wrong
      {'(': false},
      {'con': false}, // is not wrong
      {') ': false},
      {'alnu': true}, // is wrong
      {' ': false}, // is not wrong
      {'errores': false}, // is not wrong
    ]);
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.registerLanguage('Shouldn\'t add this language');
    }, throwsA(isA<AssertionError>()));
  });
}
