import 'package:flutter/material.dart';

final theme = ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue);
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
);

const defaultSpacing = 16.0;
const defaultPadding = EdgeInsets.all(defaultSpacing);
