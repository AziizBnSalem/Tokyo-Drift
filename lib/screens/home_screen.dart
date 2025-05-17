import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../components/categoriy_filter.dart';
import '../components/header.dart';
import 'profile_screen.dart';
import 'gps_tracking_screen.dart';
import 'multimedia_screen.dart';
import 'calendar_screen.dart';
import '../components/search_bar.dart' as custom_search;
import '../components/car_card.dart';
import '../models/car.dart';
import 'car_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final GlobalKey<ProfileScreenState> _profileKey;
  late List<Widget> _screens;
  List<Car> _favoriteCars = [];
  List<String> _favoriteIds = [];
  List<String> _bookedIds = [];

  @override
  void initState() {
    super.initState();
    _profileKey = GlobalKey<ProfileScreenState>();
    _loadFavorites();
    _loadBookings();
    _buildScreens();
  }

  void _buildScreens() {
    _screens = [
      HomeContent(
        onFavoriteChanged: _handleFavoriteChanged,
        favoriteIds: _favoriteIds,
        bookedIds: _bookedIds,
        onBook: _handleBookCar,
      ),
      const GpsTrackingScreen(),
      const CalendarScreen(),
      FavoritesScreen(
        favoriteCars: _favoriteCars,
        bookedIds: _bookedIds,
        onFavorite: _handleFavoriteChanged,
        onBook: _handleBookCar,
      ),
      const MultimediaScreen(),
      ProfileScreen(key: _profileKey),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 5) {
        _profileKey.currentState?.reload();
      }
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_car_ids') ?? [];
    setState(() {
      _favoriteIds = ids;
      _favoriteCars = mockCars.where((car) => ids.contains(car.id)).toList();
      _buildScreens();
    });
  }

  Future<void> _handleFavoriteChanged(String carId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorite_car_ids') ?? [];
    if (ids.contains(carId)) {
      ids.remove(carId);
    } else {
      ids.add(carId);
    }
    await prefs.setStringList('favorite_car_ids', ids);
    await _loadFavorites();
    setState(() {});
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookedIds =
          (prefs.getStringList('bookings') ?? [])
              .map((b) => b.split('|').first)
              .toList();
      _buildScreens();
    });
  }

  Future<void> _handleBookCar(BuildContext context, Car car) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = prefs.getStringList('bookings') ?? [];
    if (!_bookedIds.contains(car.id)) {
      bookings.add('${car.id}|demoStart|demoEnd|demoUser|demoEmail');
      await prefs.setStringList('bookings', bookings);
      await _loadBookings();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car booked! Check your profile.')),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Car already booked.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(163, 79, 102, 108),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF4F666C),
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Track'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.perm_media),
            label: 'Multimedia',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  final void Function(String) onFavoriteChanged;
  final List<String> favoriteIds;
  final List<String> bookedIds;
  final void Function(BuildContext, Car) onBook;
  const HomeContent({
    Key? key,
    required this.onFavoriteChanged,
    required this.favoriteIds,
    required this.bookedIds,
    required this.onBook,
  }) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Map<String, dynamic> _filters = {
    'category': 'All',
    'maxPrice': 300.0,
    'fuelType': 'All',
    'transmission': 'All',
    'onlyAvailable': false,
    'sortBy': 'None',
  };
  String _searchQuery = '';
  bool _isFilterOpen = false;

  void _toggleFilter() {
    setState(() {
      _isFilterOpen = !_isFilterOpen;
    });
  }

  List<Car> get _filteredCars {
    List<Car> cars = List.from(mockCars);
    // Apply filters
    if (_filters['category'] != 'All') {
      cars = cars.where((c) => c.category == _filters['category']).toList();
    }
    cars = cars.where((c) => c.pricePerDay <= _filters['maxPrice']).toList();
    if (_filters['fuelType'] != 'All') {
      cars = cars.where((c) => c.fuelType == _filters['fuelType']).toList();
    }
    if (_filters['transmission'] != 'All') {
      cars =
          cars
              .where((c) => c.transmission == _filters['transmission'])
              .toList();
    }
    if (_filters['onlyAvailable'] == true) {
      cars = cars.where((c) => c.isAvailable).toList();
    }
    // Search
    if (_searchQuery.isNotEmpty) {
      cars =
          cars
              .where(
                (c) =>
                    c.make.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    c.model.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();
    }
    // Sort
    switch (_filters['sortBy']) {
      case 'Price: Low to High':
        cars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'Price: High to Low':
        cars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'Newest First':
        cars.sort((a, b) => b.year.compareTo(a.year));
        break;
    }
    return cars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(163, 79, 102, 108),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Header(),
              // Hero Carousel
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF003D4C), // fallback color
                ),
                child: Center(
                  child: Text(
                    'Rent Your Dream Car Today!',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF5F6F5),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: custom_search.SearchBar(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Filter Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF5F6F5),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isFilterOpen ? Icons.close : Icons.filter_list,
                        color: const Color(0xFF003D4C),
                      ),
                      onPressed: _toggleFilter,
                    ),
                  ],
                ),
              ),
              // Collapsible Filter Panel
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isFilterOpen ? 350 : 0,
                child:
                    _isFilterOpen
                        ? CategoryFilter(
                          onFilterChanged: (filters) {
                            setState(() {
                              _filters = filters;
                            });
                          },
                        ).animate().slideY(
                          begin: -0.5,
                          end: 0,
                          duration: 300.ms,
                        )
                        : null,
              ),
              const SizedBox(height: 16),
              // Show all cars below featured
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All Cars',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF003D4C),
                    ),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredCars.length,
                itemBuilder: (context, index) {
                  final car = _filteredCars[index];
                  return CarCard(
                    car: car,
                    isFavorite: widget.favoriteIds.contains(car.id),
                    onFavorite: () => widget.onFavoriteChanged(car.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CarDetailsScreen(
                                car: car,
                                onSelect: () {
                                  Navigator.pop(context);
                                  widget.onBook(context, car);
                                },
                                isBookedChecker:
                                    () => widget.bookedIds.contains(car.id),
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Car> favoriteCars;
  final List<String> bookedIds;
  final Function(String) onFavorite;
  final void Function(BuildContext, Car) onBook;

  const FavoritesScreen({
    Key? key,
    required this.favoriteCars,
    required this.bookedIds,
    required this.onFavorite,
    required this.onBook,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(163, 79, 102, 108),
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: const Color(0xFF003D4C),
      ),
      body:
          favoriteCars.isEmpty
              ? const Center(child: Text('No favorite cars yet.'))
              : ListView.builder(
                itemCount: favoriteCars.length,
                itemBuilder: (context, index) {
                  final car = favoriteCars[index];
                  return CarCard(
                    car: car,
                    isFavorite: true,
                    onFavorite: () => onFavorite(car.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CarDetailsScreen(
                                car: car,
                                onSelect: () {
                                  Navigator.pop(context);
                                  onBook(context, car);
                                },
                                isBookedChecker:
                                    () => bookedIds.contains(car.id),
                              ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
