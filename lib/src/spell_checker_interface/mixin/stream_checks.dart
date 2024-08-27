import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

mixin CheckOperationsStreams<T extends Object> {
  Stream<T?> checkStream(
    String text, {
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)?
        customLongPressRecognizerOnWrongSpan,
  });

  Stream<List<O>> checkBuilderStream<O>(
    String text, {
    required O Function(String, bool) builder,
  });
}
