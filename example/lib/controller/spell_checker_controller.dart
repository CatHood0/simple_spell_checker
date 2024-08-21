import 'package:flutter/material.dart';
import 'package:simple_spell_checker/simple_spell_checker.dart';

class SpellCheckerController extends TextEditingController {
  final SimpleSpellChecker spellchecker;
  SpellCheckerController({
    super.text,
    required this.spellchecker,
  });

  @override
  void dispose() {
    spellchecker.dispose();
    super.dispose();
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    assert(!value.composing.isValid || !withComposing || value.isComposingRangeValid);
    final bool composingRegionOutOfRange = !value.isComposingRangeValid || !withComposing;

    // basically, if is not in focus this is builded
    if (composingRegionOutOfRange) {
      return TextSpan(style: style, children: _buildCheckedSpans(text));
    }

    final TextStyle composingStyle = style?.merge(const TextStyle(decoration: TextDecoration.underline)) ??
        const TextStyle(decoration: TextDecoration.underline);
    final leftPart = value.composing.textBefore(value.text);
    final currentPart = value.composing.textInside(value.text);
    final rightPart = value.composing.textAfter(value.text);
    return TextSpan(
      style: style,
      children: <TextSpan>[
        ..._buildCheckedSpans(leftPart),
        ..._buildCheckedSpans(currentPart, composingStyle),
        ..._buildCheckedSpans(rightPart),
      ],
    );
  }

  List<TextSpan> _buildCheckedSpans(String text, [TextStyle? style]) {
    final spans = spellchecker.check(
      text,
      wrongStyle: TextStyle(
        backgroundColor: Colors.red.withOpacity(0.2),
        decoration: TextDecoration.underline,
        decorationStyle: style?.decorationStyle ?? TextDecorationStyle.wavy,
        decorationColor: Colors.red,
      ).merge(style),
      commonStyle: style,
    );
    // nothing to check
    if (spans == null || spans.isEmpty) {
      return [TextSpan(text: text, style: style)];
    }
    return spans;
  }
}
