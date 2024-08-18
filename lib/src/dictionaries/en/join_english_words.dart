import 'package:simple_spell_checker/src/dictionaries/en/en_words1.dart';
import 'package:simple_spell_checker/src/dictionaries/en/en_words2.dart';
import '../utils/dic_utils.dart';

/// we use join functions instead getting dictionaries directly
/// since the dictionaries are too bigger to be used in just one file
final String joinEnglishWords = [removeUnnecessaryCharacters(enWords2), enWords1].join('\n');
