import 'package:built_value/built_value.dart';
import 'package:flutter/material.dart';

extension SnackBarScaffoldStateExtension on ScaffoldState {
  void snackBar(
    String message, [
    Duration duration = const Duration(seconds: 2),
  ]) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }
}

extension ShowSnackbarGlobalKeyScaffoldStateExtension
    on GlobalKey<ScaffoldState> {
  void snackBar(
    String message, [
    Duration duration = const Duration(seconds: 2),
  ]) {
    currentState?.snackBar(message);
  }
}

int _indentingBuiltValueToStringHelperIndent = 0;

class EmptyBuiltValueToStringHelper implements BuiltValueToStringHelper {
  const EmptyBuiltValueToStringHelper();

  @override
  void add(String field, Object? value) {}

  @override
  String toString() => '<empty>';
}

class CustomIndentingBuiltValueToStringHelper
    implements BuiltValueToStringHelper {
  final bool onlyLength;

  StringBuffer? _result = StringBuffer();

  CustomIndentingBuiltValueToStringHelper(String className, this.onlyLength) {
    _result!..write(className)..write(' {\n');
    _indentingBuiltValueToStringHelperIndent += 2;
  }

  @override
  void add(String field, Object? value) {
    if (value != null) {
      final key = value is Iterable && onlyLength ? '$field.length' : field;
      final val = value is Iterable && onlyLength ? value.length : value;

      _result!
        ..write(' ' * _indentingBuiltValueToStringHelperIndent)
        ..write(key)
        ..write('=')
        ..write(val)
        ..write(',\n');
    }
  }

  @override
  String toString() {
    _indentingBuiltValueToStringHelperIndent -= 2;
    _result!..write(' ' * _indentingBuiltValueToStringHelperIndent)..write('}');
    final stringResult = _result.toString();
    _result = null;
    return stringResult;
  }
}
