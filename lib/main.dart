import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  
  // Disable fetching fonts from the internet to prevent errors
  GoogleFonts.config.allowRuntimeFetching = false;
  
  // Initialize Firebase in the background without blocking the app launch!
  Firebase.initializeApp().then((_) {
    FirebaseMessagingService.initialize();
  }).catchError((e) {
    debugPrint('Firebase initialization error: $e');
  });

  // Only wait for local storage
  final prefs = await SharedPreferences.getInstance();
  
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
