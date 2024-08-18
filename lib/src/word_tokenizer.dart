// This comes from Spell-check-on-client

class WordTokenizer {
  static final RegExp separatorRegExp =
      RegExp('[ .*+!)?,:;@£§€\\{\\[\\]\\}\\\\\\?«» ºª\$%&/()=\\|!\'\\"#<>-]+');

  static bool canTokenizeText(String text) {
    return separatorRegExp.hasMatch(text);
  }

  /// Divides a string into words
  static List<String> tokenize(String content,
      {bool removeAllEmptyWords = false}) {
    final List<String> words = content.split(separatorRegExp);
    if (!removeAllEmptyWords) return [...words];
    return words.where((String element) => element.isNotEmpty).toList();
  }
}
