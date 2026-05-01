import 'package:flutex_admin/core/utils/color_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData light = ThemeData(
  brightness: Brightness.light,
  primaryColor: ColorResources.primaryColor,
  secondaryHeaderColor: ColorResources.secondaryColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFEFF3F8),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    actionsIconTheme: IconThemeData(color: ColorResources.primaryColor),
    foregroundColor: ColorResources.primaryColor,
    titleTextStyle: TextStyle(
      color: ColorResources.primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: 'Montserrat-Arabic',
    ),
    iconTheme: IconThemeData(color: ColorResources.primaryColor),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Color(0xFFEFF3F8),
      statusBarIconBrightness: Brightness.dark,
    ),
  ),
  fontFamily: 'Montserrat-Arabic',
  primarySwatch: Colors.orange,
  scaffoldBackgroundColor: const Color(0xFFEFF3F8),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      backgroundColor: ColorResources.colorOrange),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorResources.colorOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: TextStyle(
          fontFamily: 'Montserrat-Arabic',
          fontWeight: FontWeight.w700,
          fontSize: 14),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ColorResources.colorOrange,
      side: BorderSide(color: ColorResources.colorOrange, width: 1.5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: TextStyle(
          fontFamily: 'Montserrat-Arabic',
          fontWeight: FontWeight.w600,
          fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFFCCCCCC), width: 1.0)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Color(0xFFDDDDDD), width: 1.0)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: ColorResources.colorOrange, width: 1.8)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.redAccent, width: 1.2)),
    contentPadding:
        EdgeInsetsDirectional.only(top: 14, bottom: 14, start: 16, end: 16),
    hintStyle: TextStyle(color: Color(0xFF999999), fontSize: 13),
    labelStyle: TextStyle(color: Color(0xFF777777), fontSize: 13),
  ),
  cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFFEEEEEE), width: 1.0))),
  cardColor: Colors.white,
  dataTableTheme: DataTableThemeData(
      headingRowColor:
          WidgetStateProperty.all<Color>(ColorResources.lightBlueGreyColor),
      dataRowColor: WidgetStateProperty.all<Color>(Colors.white)),
  drawerTheme: const DrawerThemeData(
      backgroundColor: ColorResources.colorWhite,
      surfaceTintColor: ColorResources.primaryColor),
  textTheme: const TextTheme(
      displaySmall: TextStyle(
          color: ColorResources.colorGrey,
          fontWeight: FontWeight.w400,
          fontSize: 16),
      bodyMedium: TextStyle(
          color: Colors.black, fontWeight: FontWeight.w400, fontSize: 12),
      bodySmall: TextStyle(
          color: Colors.grey, fontWeight: FontWeight.w400, fontSize: 12),
      bodyLarge: TextStyle(
          color: ColorResources.primaryColor,
          fontWeight: FontWeight.w400,
          fontSize: 14)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: ColorResources.colorOrange,
      unselectedItemColor: ColorResources.contentTextColor,
      showUnselectedLabels: true,
      elevation: 5,
      type: BottomNavigationBarType.fixed),
  hintColor: const Color(0xFF999999),
  expansionTileTheme:
      const ExpansionTileThemeData(iconColor: ColorResources.colorGrey),
);

ThemeData dark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: ColorResources.colorOrange,
  secondaryHeaderColor: ColorResources.colorOrange,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF000000),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    actionsIconTheme: IconThemeData(color: Colors.white),
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
      fontFamily: 'Montserrat-Arabic',
    ),
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: Color(0xFF000000),
      statusBarIconBrightness: Brightness.light,
    ),
  ),
  primarySwatch: Colors.orange,
  scaffoldBackgroundColor: const Color(0xFF000000),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
      foregroundColor: Colors.white,
      backgroundColor: ColorResources.colorOrange),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorResources.colorOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: TextStyle(
          fontFamily: 'Montserrat-Arabic',
          fontWeight: FontWeight.w700,
          fontSize: 14),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ColorResources.colorOrange,
      side: BorderSide(color: ColorResources.colorOrange, width: 1.5),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30))),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: TextStyle(
          fontFamily: 'Montserrat-Arabic',
          fontWeight: FontWeight.w600,
          fontSize: 14),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1A1A),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 1.0)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF2A2A2A), width: 1.0)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide:
            const BorderSide(color: ColorResources.colorOrange, width: 1.8)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2)),
    contentPadding: const EdgeInsetsDirectional.only(
        top: 14, bottom: 14, start: 16, end: 16),
    hintStyle: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
    labelStyle: const TextStyle(color: Color(0xFFB5B5B5), fontSize: 13),
  ),
  cardTheme: const CardThemeData(
      color: Color(0xFF343434),
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: Color(0xFF222222), width: 1.0))),
  cardColor: const Color(0xFF343434),
  drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF343434), surfaceTintColor: Color(0xFF343434)),
  textTheme: const TextTheme(
      displaySmall: TextStyle(
          color: Color(0xFFB5B5B5), fontWeight: FontWeight.w400, fontSize: 16),
      bodyMedium: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12),
      bodySmall: TextStyle(
          color: Color(0xFFBDBDBD), fontWeight: FontWeight.w400, fontSize: 12),
      bodyLarge: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14)),
  iconTheme: const IconThemeData(color: Colors.white),
  primaryIconTheme: const IconThemeData(color: Colors.white),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF343434),
      selectedItemColor: ColorResources.colorOrange,
      unselectedItemColor: Color(0xFFAAB2C3),
      showUnselectedLabels: true,
      elevation: 0,
      type: BottomNavigationBarType.fixed),
  hintColor: const Color(0xFF909090),
  expansionTileTheme: const ExpansionTileThemeData(iconColor: Colors.white),
);
