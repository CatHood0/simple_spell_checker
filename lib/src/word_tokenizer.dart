class WordTokenizer {
  static final RegExp separatorRegExp = RegExp(
      r'(\s+|[,;°|·̣•µ\[\]\(\)\!\¡\¿\?\¶\$\%\&\/\\=\}\{\+\-©℗ⓒ\_\«\»\<\>\¢\@\€\←\↓\→]|[\wẃéÿĺĸẗŕýïßśëŔŸËẄÄŸÏÖÜüÍÁẂÉÚÝÓÁäëÿïößðẅẍæëïüãñõáéíóúýâêîôûöáéíñǵćóúüñÁÉÍ`´¨`ÓÚÜÑ]+)');

  static bool canTokenizeText(String text) {
    return separatorRegExp.hasMatch(text);
  }

  /// Divides a string into words
  static List<String> tokenize(
    String content, {
    bool removeAllEmptyWords = false,
  }) {
    final List<String> words = separatorRegExp
        .allMatches(content)
        .map((match) => match.group(0)!)
        .toList();
    if (!removeAllEmptyWords) return [...words];
    return words.where((String element) => element.isNotEmpty).toList();
  }
}
