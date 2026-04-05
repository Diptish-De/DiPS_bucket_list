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
      child: MaterialApp(
        title: 'Trezo Planner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          primaryColor: const Color(0xFF5C58FF),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF5C58FF),
            secondary: Color(0xFF5C58FF),
            surface: Colors.white,
          ),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF8F9FA),
            elevation: 0,
            iconTheme: IconThemeData(color: Color(0xFF1A1A24)),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF5C58FF),
            foregroundColor: Colors.white,
            elevation: 4,
            shape: CircleBorder(),
          ),
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
