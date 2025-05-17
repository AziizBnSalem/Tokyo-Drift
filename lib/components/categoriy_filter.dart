import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryFilter extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;
  const CategoryFilter({super.key, required this.onFilterChanged});

  @override
  _CategoryFilterState createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  String _selectedCategory = 'All';
  double _maxPrice = 300.0;
  String _fuelType = 'All';
  String _transmission = 'All';
  bool _onlyAvailable = false;
  String _sortBy = 'None';

  final List<String> categories = ['All', 'Luxury', 'SUV', 'Sedan', 'Electric'];
  final List<String> fuelTypes = ['All', 'Petrol', 'Diesel', 'Electric'];
  final List<String> transmissions = ['All', 'Automatic', 'Manual'];
  final List<String> sortOptions = ['None', 'Price: Low to High', 'Price: High to Low', 'Newest First'];

  void _applyFilters() {
    widget.onFilterChanged({
      'category': _selectedCategory,
      'maxPrice': _maxPrice,
      'fuelType': _fuelType,
      'transmission': _transmission,
      'onlyAvailable': _onlyAvailable,
      'sortBy': _sortBy,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        color: const Color(0xFFF5F6F5),
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Cars',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF121212),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                items: categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category, style: GoogleFonts.roboto(color: const Color(0xFF121212))),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Max Price: \$${_maxPrice.round()}',
                style: GoogleFonts.roboto(fontSize: 16, color: const Color(0xFF121212)),
              ),
              Slider(
                value: _maxPrice,
                min: 50.0,
                max: 300.0,
                divisions: 25,
                label: _maxPrice.round().toString(),
                activeColor: const Color(0xFF003D4C),
                onChanged: (value) {
                  setState(() {
                    _maxPrice = value;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _fuelType,
                isExpanded: true,
                items: fuelTypes
                    .map((fuel) => DropdownMenuItem(
                  value: fuel,
                  child: Text(fuel, style: GoogleFonts.roboto(color: const Color(0xFF121212))),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _fuelType = value!;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _transmission,
                isExpanded: true,
                items: transmissions
                    .map((trans) => DropdownMenuItem(
                  value: trans,
                  child: Text(trans, style: GoogleFonts.roboto(color: const Color(0xFF121212))),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _transmission = value!;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: Text('Only Available', style: GoogleFonts.roboto(color: const Color(0xFF121212))),
                value: _onlyAvailable,
                activeColor: const Color(0xFF003D4C),
                onChanged: (value) {
                  setState(() {
                    _onlyAvailable = value!;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                value: _sortBy,
                isExpanded: true,
                items: sortOptions
                    .map((sort) => DropdownMenuItem(
                  value: sort,
                  child: Text(sort, style: GoogleFonts.roboto(color: const Color(0xFF121212))),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                    _applyFilters();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}