import 'package:flutter/material.dart';
import 'package:iskole/core/theme/app_palette.dart';

class AppTheme{
  static final lightTheme = ThemeData.light().copyWith(
    // scaffoldBackgroundColor: Palette.scaffoldBackground,
    scaffoldBackgroundColor: Palette.whiteColor,
    appBarTheme: const AppBarTheme(
      color:  Palette.whiteColor,
      surfaceTintColor:  Palette.whiteColor,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      shadowColor: Palette.appBarShadow,
      iconTheme: IconThemeData(
          color: Palette.welcomeButtonTextColor,
        size: 32,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Palette.welcomeButtonTextColor,
      ),
      toolbarTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
    ),
  );
}