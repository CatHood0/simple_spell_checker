final RegExp removeDicCharacter = RegExp(r'\/(\S+)?');

String removeUnnecessaryCharacters(String original) {
  return original.replaceAll('-', ' ').replaceAll(removeDicCharacter, '');
}
