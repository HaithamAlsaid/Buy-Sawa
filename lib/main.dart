import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/locale_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/group_buy_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/app_settings_provider.dart';
import 'core/services/firebase_messaging_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Keep native splash while initializing, then remove it immediately
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Disable fetching fonts from the internet to prevent errors
  GoogleFonts.config.allowRuntimeFetching = false;
  
  try {
    await Firebase.initializeApp();
    await FirebaseMessagingService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  // Remove native splash ASAP — our Flutter splash takes over
  FlutterNativeSplash.remove();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => GroupBuyProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(
          create: (_) => AppSettingsProvider()..fetchSettings(),
        ),
      ],
      child: const BuySawaApp(),
    ),
  );
}
