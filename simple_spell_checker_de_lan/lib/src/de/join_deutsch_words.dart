import 'package:simple_spell_checker/src/utils.dart';
import 'de_words1.dart';
import 'de_words2.dart';

/// we use join functions instead getting dictionaries directly
/// since the dictionaries are too bigger to be used in just one file
final String joinDeutschWords =
    [removeUnnecessaryCharacters(deWords2), deWords1].join('\n');
