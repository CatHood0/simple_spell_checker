import 'package:flutter_test/flutter_test.dart';
import 'package:simple_spell_checker/src/spell_checker.dart';

void main() {
  test('Should return a simple map with right parts and wrong parts in english', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'en',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content =
        spellchecker.checkBuilder<Map<String, bool>>('this is a tśr (with) sme errors.', builder: (word, isWrong) {
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
      {'.': false}, // is not wrong
    ]);
  });

  test('Should return a simple map with right parts and wrong parts in deutsch', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'de',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>('Dies ist ein Tst (Äpfel, Männer) eiige Fehler',
        builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Dies ': false}, // is not wrong
      {'ist ': false}, // is not wrong
      {'ein ': false}, // is not wrong
      {'Tst': true}, // is wrong
      {' ': false}, // is wrong
      {'(': false},
      {'Äpfel': false}, // is not wrong
      {', ': false}, // is not wrong
      {'Männer': false}, // is not wrong
      {') ': false},
      {'eiige': true}, // is wrong
      {' ': false}, // is not wrong
      {'Fehler': false}, // is not wrong
    ]);
  });

  test('Should return a simple map with right parts and wrong parts in italian', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'it',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>('Questo è un test (con) aluni errori grammaticali',
        builder: (word, isWrong) {
      return {word: isWrong};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Questo ': false}, // is not wrong
      {'è ': false}, // is not wrong
      {'un ': false}, // is not wrong
      {'test': true}, // is wrong
      {' ': false}, // is wrong
      {'(': false},
      {'con': false}, // is not wrong
      {') ': false},
      {'aluni': true}, // is wrong
      {' ': false}, // is not wrong
      {'errori ': false}, // is not wrong
      {'grammaticali': false}, // is not wrong
    ]);
  });

  test('Should return a simple map with right parts and wrong parts in spanish', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'es',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = true;
    final content = spellchecker.checkBuilder<Map<String, bool>>('Ésto es un tesr (con) alnu errores',
        builder: (word, isWrong) {
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
  });

  test('Should dispose service and throw error when try to use checkBuilder() method', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'de',
      safeDictionaryLoad: false,
    );
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.checkBuilder<Map<String, bool>>('Dies ist ein Tst (Äpfel, Männer) eiige Fehler',
          builder: (word, isWrong) {
        return {word: isWrong};
      });
    }, throwsA(isA<AssertionError>()));
  });
}
