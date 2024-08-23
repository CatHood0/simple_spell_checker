import 'package:simple_spell_checker/src/dictionaries/sv/sv_words1.dart';
import 'package:simple_spell_checker/src/dictionaries/sv/sv_words2.dart';
import 'package:simple_spell_checker/src/dictionaries/utils/dic_utils.dart';

final joinSwedishWords = '$svWords1\n${removeUnnecessaryCharacters(svWords2)}';
