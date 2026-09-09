import 'dart:async';
import 'package:app_links/app_links.dart';
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
import 'screens/deals/group_invite_preview_screen.dart';

class BuySawaApp extends StatefulWidget {
  const BuySawaApp({super.key});

  @override
  State<BuySawaApp> createState() => _BuySawaAppState();
}

class _BuySawaAppState extends State<BuySawaApp> {
  bool _wasLoggedIn = false;
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    
    // Handle link when app is in cold state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {}

    // Handle link when app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.path.contains('/groups/join')) {
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        // Wait for next frame so context is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigatorKey.currentState?.push(
            PageRouteBuilder(
              opaque: false, // For bottom sheet effect over current screen
              pageBuilder: (_, __, ___) => GroupInvitePreviewScreen(groupCode: code),
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncProviders();
    });
  }

  //لما يتغير حالة الـ Auth، ابعت Token للـ Providers
  Future<void> _syncProviders() async {
    final auth = context.read<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    if (isLoggedIn && !_wasLoggedIn) {
      // المستخدم سجل دخول → جيب البيانات
      _wasLoggedIn = true;
      final token = await SecureStorageService.getToken();
      if (!mounted) return;
      context.read<CartProvider>().setToken(token);
      context.read<OrderProvider>().setToken(token);
      context.read<AddressProvider>().setToken(token);
      context.read<NotificationsProvider>().setToken(token);
      context.read<WalletProvider>().setToken(token);
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
      navigatorKey: _navigatorKey,
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
