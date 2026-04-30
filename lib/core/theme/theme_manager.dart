import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_color.dart';

class ThemeManager {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Color(AppColor.primaryColor),

    // primarySwatch:  MaterialColor(0xffF24D9A, Map<0xffF24D9A, Colors.grey>),
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: AppColor.grey),
    scaffoldBackgroundColor: AppColor.backgroundColor,
    cardColor: Colors.grey[100],
    /*appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black26),
      // systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black.withValues(alpha: 0.2)),
      // backgroundColor: AppColor.primaryColor,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(color: AppColor.primaryColor),
        actionsIconTheme: IconThemeData(color: AppColor.primaryColor)
    ),*/
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white38,
      iconTheme: IconThemeData(color: Colors.black), // Set icon color to black
      titleTextStyle: TextStyle(color: Colors.black), // Set text color to black
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.white
            .withValues(alpha: 0.5), // Set status bar color with opacity
        statusBarIconBrightness:
            Brightness.dark, // Set icon brightness to match white background
        statusBarBrightness: Brightness.light, // For iOS status bar
      ),
    ),

    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColor.textColor),
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColor.textColor),
      bodyMedium: TextStyle(fontSize: 18, color: AppColor.textColor),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColor.primarySwatch.shade500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(AppColor.primaryColor), // Text color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Color(AppColor.primaryColor),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.black, // Icon color
      size: 24, // Icon size
    ),
    primaryIconTheme: IconThemeData(color: Colors.black),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColor.greyColor.shade500),
      ),
      hintStyle: TextStyle(color: Colors.grey),
      labelStyle: TextStyle(color: AppColor.greyColor.shade500),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: AppColor.greyColor.shade500),
      ),
    ),

  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    canvasColor: Color(AppColor.primaryColor),

    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.grey[900]?.withValues(alpha: 0.4),
    // cardColor: Colors.grey[900],
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.black,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 18, color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(AppColor.primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(AppColor.primaryColor), // Text color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white, // Icon color in dark theme
      size: 24,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white),
      ),
      hintStyle: TextStyle(color: Colors.grey),
      labelStyle: TextStyle(color: Colors.white),
    ),

  );
}
