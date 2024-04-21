import 'package:coffee_shop/common/colors.dart';
import 'package:flutter/material.dart';

class Theme {
  static final ThemeData light = ThemeData.light().copyWith(
    primaryColor: AppColors.lightThemePrimaryColor,
    primaryColorLight: AppColors.lightThemePrimaryColorLight,
    primaryColorDark: AppColors.lightThemePrimaryColorDark,
    splashColor: AppColors.lightThemeSplashColor,
    scaffoldBackgroundColor: AppColors.white,
  );
}
