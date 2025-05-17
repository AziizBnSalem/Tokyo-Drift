import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final bool showFilterIcon;
  const SearchBar({super.key, this.onChanged, this.showFilterIcon = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search for a luxury car...',
            hintStyle: GoogleFonts.orbitron(color: Colors.grey[600]),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            suffixIcon:
                showFilterIcon
                    ? const Icon(Icons.filter_list, color: Colors.grey)
                    : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: onChanged,
          onSubmitted: (value) {
            // Implement search functionality
          },
        ),
      ),
    ).animate().slideY(begin: 0.2, end: 0.0, duration: 600.ms);
  }
}
