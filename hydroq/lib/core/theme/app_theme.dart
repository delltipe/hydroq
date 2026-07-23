import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color green50 = Color(0xFFECF9F0);
  static const Color green100 = Color(0xFFD8F3E1);
  static const Color green200 = Color(0xFFB5E7C6);
  static const Color green300 = Color(0xFF7FD49B);
  static const Color green400 = Color(0xFF3DC469);
  static const Color green500 = Color(0xFF12B347);
  static const Color green600 = Color(0xFF0D963B);
  static const Color green700 = Color(0xFF087A32);
  static const Color green800 = Color(0xFF075F2A);
  static const Color green900 = Color(0xFF064921);

  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral25 = Color(0xFFFBFCFB);
  static const Color neutral50 = Color(0xFFF7F9F7);
  static const Color neutral100 = Color(0xFFF0F3F1);
  static const Color neutral200 = Color(0xFFE5EAE7);
  static const Color neutral300 = Color(0xFFD1D8D4);
  static const Color neutral400 = Color(0xFFA6AEA9);
  static const Color neutral500 = Color(0xFF747C77);
  static const Color neutral600 = Color(0xFF5D655F);
  static const Color neutral700 = Color(0xFF414843);
  static const Color neutral800 = Color(0xFF292F2B);
  static const Color neutral900 = Color(0xFF171B18);

  static const Color success = Color(0xFF159447);
  static const Color successSoft = Color(0xFFEAF7EF);
  static const Color warning = Color(0xFFD98200);
  static const Color warningSoft = Color(0xFFFFF4DD);
  static const Color critical = Color(0xFFC9363E);
  static const Color criticalSoft = Color(0xFFFDEBED);
  static const Color information = Color(0xFF2676C9);
  static const Color informationSoft = Color(0xFFEAF3FC);
  static const Color offline = Color(0xFF6F7772);
  static const Color offlineSoft = Color(0xFFEFF1F0);
  static const Color stale = Color(0xFFA26312);
  static const Color staleSoft = Color(0xFFFFF3E3);
}

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double giant = 64;
}

abstract final class AppRadius {
  static const double small = 12;
  static const double medium = 16;
  static const double large = 24;
  static const double pill = 999;
}

abstract final class AppShadows {
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0A171B18),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

abstract final class AppTheme {
  static TextTheme _textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        height: 1.29,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
        fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 24,
        height: 1.33,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 18,
        height: 1.44,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral900,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: AppColors.neutral900,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral700,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        height: 1.57,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral700,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: AppColors.neutral500,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        height: 1.43,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green500,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.green500,
      surface: AppColors.neutral0,
      error: AppColors.critical,
    );
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.neutral50,
    );
    final TextTheme textTheme = _textTheme(base.textTheme);
    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.green500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          borderSide: const BorderSide(color: AppColors.critical),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.neutral400),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(44, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          textStyle: textTheme.labelLarge,
          backgroundColor: AppColors.green500,
          foregroundColor: AppColors.neutral0,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.neutral500,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          textStyle: textTheme.labelLarge,
          foregroundColor: AppColors.green700,
          side: const BorderSide(color: AppColors.neutral300),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.neutral0,
        indicatorColor: AppColors.green50,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
          return textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.green700
                : AppColors.neutral500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.green700
                : AppColors.neutral500,
          );
        }),
      ),
      dividerColor: AppColors.neutral100,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.neutral900,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: AppColors.neutral0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
    );
  }
}
