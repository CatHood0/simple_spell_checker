import 'package:simple_spell_checker/src/dictionaries/it/it_words1.dart';
import 'package:simple_spell_checker/src/dictionaries/it/it_words2.dart';
import 'package:simple_spell_checker/src/dictionaries/utils/dic_utils.dart';

/// we use join functions instead getting dictionaries directly
/// since the dictionaries are too bigger to be used in just one file
final String joinItalianWords = '${removeUnnecessaryCharacters(itWords2)}\n$itWords1';
