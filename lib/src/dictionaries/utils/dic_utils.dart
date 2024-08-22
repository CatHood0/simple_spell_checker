final RegExp removeDicCharacter = RegExp(r'\/(\S+)?');

String removeUnnecessaryCharacters(String original, [Object? replace]) {
  return original.replaceAll('-', '${replace ?? '\n'}').replaceAll(removeDicCharacter, '');
}
