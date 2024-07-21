import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Color.fromARGB(255, 4, 0, 233),
    secondary: Colors.white,
    inversePrimary: Color.fromARGB(255, 4, 0, 233),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
    onError: Colors.white,
    error: Colors.red,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 4, 0, 233),
    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
  ),
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,
  iconTheme: IconThemeData(
    color: Color.fromARGB(255, 4, 0, 233),
  ),);