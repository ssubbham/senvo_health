import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get data => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xfff4f7f8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0b6e69), brightness: Brightness.light),
        fontFamily: 'sans',
        cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18)))),
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)))),
      );
}