import 'package:flutter_test/flutter_test.dart';
import 'package:simple_spell_checker/simple_spell_checker.dart';

void main() {
  test('Should return a simple map with right parts and wrong parts in english',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'en',
      safeDictionaryLoad: false,
    );
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'this is a tśr (with) sme errors.', builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'this ': true}, // is not wrong
      {'is ': true}, // is not wrong
      {'a ': true}, // is not wrong
      {'tśr': false}, // is wrong
      {' ': true}, // is not wrong
      {'(': true},
      {'with': true}, // is not wrong
      {') ': true},
      {'sme': false}, // is wrong
      {' ': true}, // is not wrong
      {'errors': true}, // is not wrong
      {'.': true}, // is not wrong
    ]);
  });

  test('Should return a simple map with right parts and wrong parts in deutsch',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'de',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = false;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'Dies ist ein Tst (Äpfel, Männer) eiige Fehler',
        builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Dies ': true}, // is not wrong
      {'ist ': true}, // is not wrong
      {'ein ': true}, // is not wrong
      {'Tst': false}, // is wrong
      {' ': true}, // is wrong
      {'(': true},
      {'Äpfel': true}, // is not wrong
      {', ': true}, // is not wrong
      {'Männer': true}, // is not wrong
      {') ': true},
      {'eiige': false}, // is wrong
      {' ': true}, // is not wrong
      {'Fehler': true}, // is not wrong
    ]);
  });

  test('Should return a simple map with right parts and wrong parts in italian',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'it',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = false;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'Questo è un test (con) aluni errori grammaticali',
        builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Questo ': true}, // is not wrong
      {'è ': true}, // is not wrong
      {'un ': true}, // is not wrong
      {'test': false}, // is wrong
      {' ': true}, // is wrong
      {'(': true},
      {'con': true}, // is not wrong
      {') ': true},
      {'aluni': false}, // is wrong
      {' ': true}, // is not wrong
      {'errori ': true}, // is not wrong
      {'grammaticali': true}, // is not wrong
    ]);
  });

  test('Should return a simple map with right parts and wrong parts in spanish',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'es',
      safeDictionaryLoad: false,
    );
    //spellchecker.testingMode = false;
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'Ésto es un tesr (con) alnu errores', builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Ésto ': true}, // is not wrong
      {'es ': true}, // is not wrong
      {'un ': true}, // is not wrong
      {'tesr': false}, // is wrong
      {' ': true}, // is not wrong
      {'(': true},
      {'con': true}, // is not wrong
      {') ': true},
      {'alnu': false}, // is wrong
      {' ': true}, // is not wrong
      {'errores': true}, // is not wrong
    ]);
  });

  test('Should works even the language not exist', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: '',
      safeDictionaryLoad: true,
      worksWithoutDictionary: true,
    );
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'Questo è un test (con) aluni errori grammaticali',
        builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Questo': false}, // is wrong
      {' ': true}, // is not wrong
      {'è': false}, // is wrong
      {' ': true}, // is not wrong
      {'un': false}, // is wrong
      {' ': true}, // is not wrong
      {'test': false}, // is wrong
      {' ': true}, // is not wrong
      {'(': true}, // is not wrong
      {'con': false}, // is wrong
      {') ': true}, // is not wrong
      {'aluni': false}, // is wrong
      {' ': true}, // is not wrong
      {'errori': false}, // is wrong
      {' ': true}, // is not wrong
      {'grammaticali': false}, // is wrong
    ]);
  });

  test(
      'Should dispose service and throw error when try to use checkBuilder() method',
      () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final SimpleSpellChecker spellchecker = SimpleSpellChecker(
      language: 'de',
      safeDictionaryLoad: false,
    );
    spellchecker.dispose();
    // this should throws an error
    expect(() {
      spellchecker.checkBuilder<Map<String, bool>>(
          'Dies ist ein Tst (Äpfel, Männer) eiige Fehler',
          builder: (word, isValid) {
        return {word: isValid};
      });
    }, throwsA(isA<AssertionError>()));
  });

  // this process could be heavy since is loading different dictionaries
  test('Should work with different languages at the same time', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final MultiSpellChecker spellchecker = MultiSpellChecker(
      language: ['en', 'ru'],
    );
    final content = spellchecker.checkBuilder<Map<String, bool>>(
        'Questo è un test (con) aluni errori grammaticali and правильно',
        builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content, isNotNull);
    expect(content, isNotEmpty);
    expect(content, [
      {'Questo': false}, // is wrong
      {' ': true}, // is not wrong
      {'è': false}, // is wrong
      {' ': true}, // is not wrong
      {'un': false}, // is wrong
      {' ': true}, // is not wrong
      {'test ': true}, // is wrong
      {'(': true}, // is not wrong
      {'con': true}, // is wrong
      {') ': true}, // is not wrong
      {'aluni': false}, // is wrong
      {' ': true}, // is not wrong
      {'errori': false}, // is wrong
      {' ': true}, // is not wrong
      {'grammaticali': false}, // is wrong
      {' ': true}, // is not wrong
      {'and ': true}, // is not wrong
      {'правильно': true}, // is not wrong
    ]);
    spellchecker.registerLanguage('custom_it');
    // automatically adds the new language to the current state
    spellchecker.addCustomLanguage(const LanguageIdentifier(
        language: 'custom_it', words: 'Questo\naluni'));
    spellchecker.reloadDictionarySync();
    final content2 = spellchecker.checkBuilder<Map<String, bool>>(
        'Questo è un test (con) aluni errori grammaticali and правильно',
        builder: (word, isValid) {
      return {word: isValid};
    });
    expect(content2, isNotNull);
    expect(content2, isNotEmpty);
    expect(content2, [
      {'Questo ': true}, // is wrong
      {'è': false}, // is wrong
      {' ': true}, // is not wrong
      {'un': false}, // is wrong
      {' ': true}, // is not wrong
      {'test ': true}, // is wrong
      {'(': true}, // is not wrong
      {'con': true}, // is wrong
      {') ': true}, // is not wrong
      {'aluni ': true}, // is wrong
      {'errori': false}, // is wrong
      {' ': true}, // is not wrong
      {'grammaticali': false}, // is wrong
      {' ': true}, // is not wrong
      {'and ': true}, // is not wrong
      {'правильно': true}, // is not wrong
    ]);
  });
}
