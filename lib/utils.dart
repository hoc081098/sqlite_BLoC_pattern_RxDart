import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
  ScaffoldState scaffolState,
  String message, [
  Duration duration = const Duration(seconds: 2),
]) {
  return scaffolState?.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
    ),
  );
}
