import 'package:simple_spell_checker/src/dictionaries/pt/pt_words1.dart';
import 'package:simple_spell_checker/src/dictionaries/pt/pt_words2.dart';
import 'package:simple_spell_checker/src/dictionaries/utils/dic_utils.dart';

/// we use join functions instead getting dictionaries directly
/// since the dictionaries are too bigger to be used in just one file
final String joinPortugueseWords =
    [removeUnnecessaryCharacters(ptWords2), ptWords1].join('\n');
