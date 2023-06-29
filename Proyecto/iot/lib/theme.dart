import 'package:flutter/material.dart';

MaterialColor colorFromHex(int hexColor) {
  return MaterialColor(
    hexColor,
    <int, Color>{
      50: Color(hexColor),
      100: Color(hexColor),
      200: Color(hexColor),
      300: Color(hexColor),
      400: Color(hexColor),
      500: Color(hexColor),
      600: Color(hexColor),
      700: Color(hexColor),
      800: Color(hexColor),
      900: Color(hexColor),
    },
  );
}

class BlueTheme {
  static const primary = Color.fromARGB(255, 51, 147, 210);
  static const primaryText = Colors.blue;
  static const primaryButton = Color.fromRGBO(235, 42, 98, 8);
  static const primaryTransparent = Color.fromRGBO(89, 159, 205, 0.5);
  static const correct = Color.fromRGBO(230, 0, 0, 0.1);
  static const already = Color(0xFFF2F19B);
  static const wrong = Color(0xFFEDC997);
  static const notFound = Color(0xFFE68D90);
  static const secondary = Color(0xFF599FCD);
  static const ternary = Color(0xFF808080);
  static const surface = Color(0xFFEDEDED);
  static const background = Color(0xFFFFFFFF);
  static const white = Color(0xFFFFFFFF);
  static const grey = Color.fromRGBO(90, 101, 108, 1);
  static const vigente = Color(0xFF54B096);
  static const vencido = Color(0xFFEDAE67);
  static const notiene = Color(0xFFDC606A);
  static const Color nearlyWhite = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static final MaterialColor primaryAccent = colorFromHex(0xFFBF080C);
  static final MaterialColor textPrimaryColor = colorFromHex(0xFFffffff);
  static final MaterialColor textSecondaryColor = colorFromHex(0xFF666464);
  static final MaterialColor textTertiaryColor = colorFromHex(0xFF888888);
  static final MaterialColor borderColor = colorFromHex(0xFFAAA9A9);
  static final MaterialColor menuButton = colorFromHex(0xFFE5E5E5);
  static final MaterialColor authButton = colorFromHex(0xFFFFFFFF);
  static final MaterialColor backgroundButton = colorFromHex(0xFFFFFFFF);
  static final MaterialColor dividerColor = colorFromHex(0xFFA0A0A0);
  static final MaterialColor warningColor = colorFromHex(0xFFEC1F26);
  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: 'WorkSans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText)
  );
  static const MaterialColor swatch = MaterialColor(
    0xff599FCD,
    <int, Color>{
      50: Color(0xFF9DC8E2), //10%
      100: Color(0xFF84BBDB), //20%
      200: Color(0xFF6BAEDA), //30%
      300: Color(0xFF51A2D3), //40%
      400: Color(0xFF388ACB), //50%
      500: Color(0xFF2062C4), //60%
      600: Color(0xFF1C55B1), //70%
      700: Color(0xFF18489E), //80%
      800: Color(0xFF143B8C), //90%
      900: Color(0xFF0F2E79), //100%
    },
  );
}
