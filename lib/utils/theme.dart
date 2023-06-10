import 'package:flutter/material.dart';

var cetalksTheme = ThemeData(
  //
  buttonColor: Colors.white,
  buttonTheme: ButtonThemeData(
      buttonColor: Colors.white, textTheme: ButtonTextTheme.accent),
  primaryColor: Color.fromRGBO(15, 15, 15, 1),
  canvasColor: Colors.blueGrey[400],
  //Color.fromRGBO(34, 40, 45, 1),
  //Color.fromRGBO(167, 170, 177, 1)
  accentColor: Colors.white,

  //,
  textTheme: ThemeData.light().textTheme.copyWith(
      headline6: TextStyle(
          fontFamily: 'BalooChettan2', fontSize: 18, color: Colors.white),
      button: TextStyle(
        color: Colors.black,
      )),
  appBarTheme: AppBarTheme(
    //color: Color.fromRGBO(34, 40, 45, 1),
    textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
          fontFamily: 'BalooChettan2',
          fontSize: 25,
        )),
    elevation: 15,
  ),
);
