import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interfaces/login.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tokyo Drift',
            style: GoogleFonts.orbitron(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFFF5F6F5),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003D4C),
              foregroundColor: const Color(0xFFF5F6F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
            ),
            icon: const Icon(Icons.logout, size: 20),
            label: Text(
              'Logout',
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('user_name');
              await prefs.remove('user_email');
              await prefs.remove('user_phone');
              // Optionally clear other user-related data
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
