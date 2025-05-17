import 'package:carrents/interfaces/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tokyo Drift',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF003D4C), // Deep Teal
        scaffoldBackgroundColor: const Color(0xFF121212), // Midnight Black
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003D4C),
          foregroundColor: Color(0xFFF5F6F5),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFFF5F6F5)),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.montserrat(
            fontWeight: FontWeight.w800,
            color: const Color(0xFFF5F6F5),
          ),
          bodyMedium: GoogleFonts.roboto(
            fontWeight: FontWeight.w400,
            color: const Color(0xFFDDE1E4),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003D4C),
          primary: const Color(0xFF003D4C),
          secondary: const Color(0xFFDDE1E4),
          background: const Color(0xFF121212),
          surface: const Color(0xFF1A1A1A),
          onPrimary: const Color(0xFFF5F6F5),
          onSecondary: const Color(0xFF003D4C),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF003D4C),
            foregroundColor: const Color(0xFFF5F6F5),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.2),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF5F6F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF003D4C), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          labelStyle: GoogleFonts.roboto(
            color: const Color(0xFFB0B0B0),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      home: const SplashScreen(), // Set ContinueScreen as the home screen
    );
  }
}
