import 'package:flutter/foundation.dart' show immutable;

/// [LanguageIdentifier] is a representation of a register of a language with it's dictionary
///   [language] ref to the country code
///   [word] ref to the dictionary
///
/// [words] dictionary must have a plain text format where the new lines separate every word
///
/// # Example:
/// it language should have a dictionary format like:
///
/// italia
/// miniatura
/// famiglia
/// specie
/// europa
/// latino
/// animalia
/// roma
///
/// Making simple and easier add custom dictionaries for everyone
@immutable
class LanguageIdentifier {
  final String language;
  final String words;

  const LanguageIdentifier({
    required this.language,
    required this.words,
  });

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
