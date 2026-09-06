import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/secure_storage_service.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/address_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/wallet_provider.dart';
import 'screens/main/main_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';

class BuySawaApp extends StatefulWidget {
  const BuySawaApp({super.key});

  @override
  State<BuySawaApp> createState() => _BuySawaAppState();
}

class _BuySawaAppState extends State<BuySawaApp> {
  bool _wasLoggedIn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncProviders();
  }

  // ─── لما يتغير حالة الـ Auth، ابعت Token للـ Providers ──────
  Future<void> _syncProviders() async {
    final auth = context.read<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    if (isLoggedIn && !_wasLoggedIn) {
      // المستخدم سجل دخول → جيب البيانات
      _wasLoggedIn = true;
      if (auth.isAuthenticated) {
        final token = auth.token;
        context.read<CartProvider>().setToken(token);
        context.read<OrderProvider>().setToken(token);
        context.read<AddressProvider>().setToken(token);
        context.read<NotificationsProvider>().setToken(token);
        context.read<WalletProvider>().setToken(token);
      }
    } else if (!isLoggedIn && _wasLoggedIn) {
      // المستخدم طلع → امسح البيانات
      _wasLoggedIn = false;
      if (!mounted) return;
      context.read<CartProvider>().setToken(null);
      context.read<OrderProvider>().setToken(null);
      context.read<AddressProvider>().setToken(null);
      context.read<NotificationsProvider>().setToken(null);
      context.read<WalletProvider>().setToken(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();
    final isGuest = auth.isGuest;
    final showOnboarding = localeProvider.isFirstLaunch && isGuest;

    // مزامنة الـ Providers لما يتغير حالة الـ Auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncProviders();
    });

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
