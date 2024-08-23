import 'package:simple_spell_checker/src/dictionaries/no/no_words1.dart';
import 'package:simple_spell_checker/src/dictionaries/no/no_words2.dart';
import 'package:simple_spell_checker/src/dictionaries/utils/dic_utils.dart';

final joinNowergianWords =
    '$noWords1\n${removeUnnecessaryCharacters(noWords2)}';
