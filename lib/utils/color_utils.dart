import 'package:flutter/material.dart';

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF225EA9),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD6E3FF),
  onPrimaryContainer: Color(0xFF001B3C),
  secondary: Color(0xFF0A61A4),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFFD2E4FF),
  onSecondaryContainer: Color(0xFF001C37),
  tertiary: Color(0xFF944A00),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFFFFDCC6),
  onTertiaryContainer: Color(0xFF301400),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  errorContainer: Color(0xFFFFDAD6),
  onErrorContainer: Color(0xFF410002),
  outline: Color(0xFF6F797A),
  background: Color(0xFFFAFDFD),
  onBackground: Color(0xFF191C1D),
  surface: Color(0xFFF8FAFA),
  onSurface: Color(0xFF191C1D),
  surfaceVariant: Color(0xFFDBE4E6),
  onSurfaceVariant: Color(0xFF3F484A),
  inverseSurface: Color(0xFF2E3132),
  onInverseSurface: Color(0xFFEFF1F1),
  inversePrimary: Color(0xFFA8C8FF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF225EA9),
  outlineVariant: Color(0xFFBFC8CA),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA8C8FF),
  onPrimary: Color(0xFF003062),
  primaryContainer: Color(0xFF00468A),
  onPrimaryContainer: Color(0xFFD6E3FF),
  secondary: Color(0xFFA0CAFF),
  onSecondary: Color(0xFF003259),
  secondaryContainer: Color(0xFF00497E),
  onSecondaryContainer: Color(0xFFD2E4FF),
  tertiary: Color(0xFFFFB784),
  onTertiary: Color(0xFF4F2500),
  tertiaryContainer: Color(0xFF713700),
  onTertiaryContainer: Color(0xFFFFDCC6),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  outline: Color(0xFF899294),
  background: Color(0xFF191C1D),
  onBackground: Color(0xFFE1E3E3),
  surface: Color(0xFF101415),
  onSurface: Color(0xFFC4C7C7),
  surfaceVariant: Color(0xFF3F484A),
  onSurfaceVariant: Color(0xFFBFC8CA),
  inverseSurface: Color(0xFFE1E3E3),
  onInverseSurface: Color(0xFF191C1D),
  inversePrimary: Color(0xFF225EA9),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFFA8C8FF),
  outlineVariant: Color(0xFF3F484A),
  scrim: Color(0xFF000000),
);