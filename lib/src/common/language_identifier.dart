class LanguageIdentifier {
  final String language;
  final String words;

  LanguageIdentifier({
    required this.language,
    required this.words,
  }) : assert(language.isNotEmpty);

  LanguageIdentifier copyWith({
    String? language,
    String? words,
  }) {
    return LanguageIdentifier(
      language: language ?? this.language,
      words: words ?? this.words,
    );
  }

  @override
  bool operator ==(covariant LanguageIdentifier other) {
    if (identical(this, other)) return true;
    return language == other.language && words == other.words;
  }

  @override
  int get hashCode => language.hashCode ^ words.hashCode;
}
