import 'package:simple_spell_checker/src/dictionaries/en/gb/en_gb_words1.dart';
import 'package:simple_spell_checker/src/dictionaries/en/join_english_words.dart';

import '../../utils/dic_utils.dart';

final joinBritishWords =
    '${removeUnnecessaryCharacters(britishWords1)}\n$joinEnglishWords';
