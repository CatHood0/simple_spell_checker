final List<String> defaultLanguages = List.unmodifiable(
  ['pt', 'de', 'en', 'es', 'it', 'fr', 'no', 'sv'],
);

bool isWordHasNumberOrBracket(String s) {
  return s.contains(RegExp(r'[0-9\()]'));
}
