/// A interface with the necessary methods to tokenize words
abstract class Tokenizer {
  final RegExp defaultSeparatorRegExp = RegExp(
      r'''(\s+|[,;:'`´^¨`\'\.°\|\*\•µ\[\]\(\)\!\¡\¿\?\¶\$\%\&\/\\=\}\{\+\-©℗ⓒ·~½¬ſþˀ\_\«\»\<\>\¢\@\€\←\↓\→\ð\ø\¢\”\“\„\"]|[\wẃĺĸẗŕýảẻủỷỉỏẢẺỶỦỈỎƙïßśŔŸËẄÄŸÏÖÜüÍÁẂÉÚÝÓÁäëÿïößðẅẍæëïüãñõáéíóúýâêîôûöáéíñǵñÑüÜçÇàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛãõÃÕćóúüñÁÉÍÓÚÜÑ]+)''');
  final RegExp? separatorRegExp;
  Tokenizer({this.separatorRegExp});
  bool canTokenizeText(String text);
  List<String> tokenize(String content,
      {@Deprecated(
          'removeAllEmptyWords are no longer used and will be removed in future releases')
      bool removeAllEmptyWords = false});
}
