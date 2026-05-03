import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/buy_provider.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const BuyPlannerApp());
}

class BuyPlannerApp extends StatelessWidget {
  const BuyPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BuyProvider()),
      ],
      child: Consumer<BuyProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'DiPS Bucket List',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF5F5F5),
              primaryColor: const Color(0xFFFF6D3B),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFF6D3B),
                secondary: Color(0xFFFF6D3B),
                surface: Colors.white,
              ),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              primaryColor: const Color(0xFFFF6D3B),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFFFF6D3B),
                secondary: Color(0xFFFF6D3B),
                surface: Color(0xFF1E1E1E),
              ),
              textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            ),
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
