import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/buy_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/timeline_screen.dart';

void main() { runApp(const BuyPlannerApp()); }

class BuyPlannerApp extends StatelessWidget {
  const BuyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BuyProvider())],
      child: Consumer<BuyProvider>(builder: (context, provider, _) => MaterialApp(
        title: "DiPS' bucket",
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
        home: const SplashWrapper(),
      )),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});
  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> with SingleTickerProviderStateMixin {
  bool _showSplash = true;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut);
    _scaleCtrl.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() { _scaleCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              width: 90, height: 90,
              decoration: BoxDecoration(color: const Color(0xFFFF6D3B), borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.savings, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          const Text('DiPS Bucket List', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          const Text('Save smart. Buy happy.', style: TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500)),
        ])),
      );
    }

    return const MainNav();
  }
}

class MainNav extends StatefulWidget {
  const MainNav({super.key});
  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _idx = 0;
  final _screens = const [DashboardScreen(), TimelineScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4))]),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.timeline_rounded, 'Timeline', 1),
          ]),
        )),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final s = _idx == index;
    return GestureDetector(onTap: () => setState(() => _idx = index), child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: s ? const Color(0xFFFF6D3B).withValues(alpha: 0.1) : Colors.transparent, borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: s ? const Color(0xFFFF6D3B) : const Color(0xFF8A8A9E), size: 24),
        if (s) ...[const SizedBox(width: 8), Text(label, style: const TextStyle(color: Color(0xFFFF6D3B), fontWeight: FontWeight.w800, fontSize: 14))],
      ]),
    ));
  }
}
