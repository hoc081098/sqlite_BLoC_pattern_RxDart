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
