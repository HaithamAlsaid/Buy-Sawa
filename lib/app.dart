import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/main/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

class BuySawaApp extends StatelessWidget {
  const BuySawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isGuest = context.watch<AuthProvider>().isGuest;
    final showOnboarding = localeProvider.isFirstLaunch && isGuest;

    if (showOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        localeProvider.markLaunched();
      });
    }

    return MaterialApp(
      title: 'BuySawa',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: localeProvider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: showOnboarding ? const OnboardingScreen() : const MainScreen(),
    );
  }
}
