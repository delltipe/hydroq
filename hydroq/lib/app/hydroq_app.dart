import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/state/hydroq_controller.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/login_screen.dart';

class HydroQApp extends StatefulWidget {
  const HydroQApp({super.key, required this.controller});

  final HydroQController controller;

  @override
  State<HydroQApp> createState() => _HydroQAppState();
}

class _HydroQAppState extends State<HydroQApp> {
  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HydroQScope(
      controller: widget.controller,
      child: MaterialApp(
        title: 'HydroQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: const Locale('id'),
        supportedLocales: const <Locale>[Locale('id'), Locale('en')],
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const LoginScreen(),
      ),
    );
  }
}
