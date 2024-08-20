/// A interface with the necessary methods to tokenize words
abstract class Tokenizer {
  final RegExp defaultSeparatorRegExp = RegExp(
      r'(\s+|[,;\.°|·̣•µ\[\]\(\)\!\¡\¿\?\¶\$\%\&\/\\=\}\{\+\-©℗ⓒ\_\«\»\<\>\¢\@\€\←\↓\→\ð\ø\¢\”\“\„\"]|[\wẃĺĸẗŕýảẻủỷỉỏẢẺỶỦỈỎƙïßśŔŸËẄÄŸÏÖÜüÍÁẂÉÚÝÓÁäëÿïößðẅẍæëïüãñõáéíóúýâêîôûöáéíñǵñÑüÜçÇàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛãõÃÕćóúüñÁÉÍ`´^¨`ÓÚÜÑ]+)');
  final RegExp? separatorRegExp;
  Tokenizer({this.separatorRegExp});
  bool canTokenizeText(String text);
  List<String> tokenize(String content, {bool removeAllEmptyWords = false});
}
