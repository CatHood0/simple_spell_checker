extension WordExtension on String {
  String capitalize() =>
      isEmpty || length < 2 ? this : "${this[0].toUpperCase()}${substring(1)}";
  String toLowerCaseFirst() =>
      isEmpty || length < 2 ? this : "${this[0].toLowerCase()}${substring(1)}";
  bool get noWords => RegExp(
          r'''[,;:'\'\.°\|\*\•µ\[\]\(\)\!\¡\¿\?\¶\$\%\&\/\\=\}\{\+\-©℗ⓒ·~½¬ſþˀ\_\«\»\<\>\¢\@\€\←\↓\→\ð\ø\¢\”\“\„\"]''')
      .hasMatch(this);
}
