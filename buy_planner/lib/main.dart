import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/buy_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timeline_screen.dart';

void main() {
  runApp(const BuyPlannerApp());
}

class BuyPlannerApp extends StatelessWidget {
  const BuyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BuyProvider())],
      child: Consumer<BuyProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'DiPS Bucket List',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true, brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              primaryColor: const Color(0xFFFF6D3B),
              colorScheme: const ColorScheme.light(primary: Color(0xFFFF6D3B), secondary: Color(0xFFFF6D3B), surface: Colors.white),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            ),
            darkTheme: ThemeData(
              useMaterial3: true, brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: const Color(0xFFFF6D3B),
              colorScheme: const ColorScheme.dark(primary: Color(0xFFFF6D3B), secondary: Color(0xFFFF6D3B), surface: Color(0xFF1E1E1E)),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainNav(),
          );
        },
      ),
    );
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;
  final _screens = const [DashboardScreen(), TimelineScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.timeline_rounded, 'Timeline', 1),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFFF6D3B).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: sel ? const Color(0xFFFF6D3B) : const Color(0xFF8A8A9E), size: 24),
          if (sel) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFFFF6D3B), fontWeight: FontWeight.w800, fontSize: 14)),
          ],
        ]),
      ),
    );
  }
}
