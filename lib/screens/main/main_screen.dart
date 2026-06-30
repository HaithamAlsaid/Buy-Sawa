import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/auth_bottom_sheet.dart';
import '../home/home_screen.dart';
import '../categories/categories_screen.dart';
import '../deals/deals_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/account_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    DealsScreen(),
    WalletScreen(),
    AccountScreen(),
  ];

  void _onNavTap(int index) async {
    final auth = context.read<AuthProvider>();
    // Deals (2) and Wallet (3) require login — Profile (4) handles guest state internally
    if ((index == 2 || index == 3) && auth.isGuest) {
      await AuthBottomSheet.show(context);
      if (!mounted) return;
      if (!context.read<AuthProvider>().isGuest) {
        setState(() => _currentIndex = index);
      }
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
