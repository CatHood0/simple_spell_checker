import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

mixin CheckOperations<T extends Object, R> {
  bool isWordValid(String word);
  Future<void> reloadDictionary();
  bool checkLanguageRegistry(R language);
  void reloadDictionarySync();
  T? check(
    String text, {
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)? customLongPressRecognizerOnWrongSpan,
  });

  Stream<T?> checkStream(
    String text, {
    TextStyle? wrongStyle,
    TextStyle? commonStyle,
    LongPressGestureRecognizer Function(String)? customLongPressRecognizerOnWrongSpan,
  });

  List<O>? checkBuilder<O>(
    String text, {
    required O Function(String, bool) builder,
  });

  Stream<List<O>> checkBuilderStream<O>(
    String text, {
    required O Function(String, bool) builder,
  });
}
