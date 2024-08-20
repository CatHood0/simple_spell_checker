import 'package:simple_spell_checker/src/common/tokenizer.dart';

/// Default work tokenizer implemented by the package
class WordTokenizer extends Tokenizer {
  WordTokenizer({
    super.separatorRegExp,
  });

  @override
  bool canTokenizeText(String text) {
    return (separatorRegExp ?? defaultSeparatorRegExp).hasMatch(text);
  }

  /// Divides a string into words
  @override
  List<String> tokenize(
    String content, {
    @Deprecated(
        'removeAllEmptyWords are no longer used and will be removed in future releases')
    bool removeAllEmptyWords = false,
  }) {
    final List<String> words = (separatorRegExp ?? defaultSeparatorRegExp)
        .allMatches(content)
        .map(
          (match) => match.group(0)!,
        )
        .toList();
    return words;
  }
}
