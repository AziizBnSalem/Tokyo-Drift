import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calendar_screen.dart';
import 'multimedia_screen.dart';
import '../models/car.dart';
import '../components/car_card.dart';
import 'car_details_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selfie;
  String _name = 'Loading...';
  String _email = 'Loading...';
  String _phone = 'Loading...';
  bool _isLoading = false;
  List<Map<String, dynamic>> _bookings = [];
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadBookings();
    _loadFavorites();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _phone = prefs.getString('user_phone') ?? '';
      final selfiePath = prefs.getString('profile_selfie');
      _selfie =
          selfiePath != null && File(selfiePath).existsSync()
              ? File(selfiePath)
              : null;
      _isLoading = false;
    });
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = prefs.getStringList('bookings') ?? [];
    setState(() {
      _bookings =
          bookings
              .map((b) {
                final parts = b.split('|');
                if (parts.length < 5) return null;
                final car = mockCars.firstWhere(
                  (c) => c.id == parts[0],
                  orElse: () => mockCars[0],
                );
                return {
                  'car': car,
                  'startDate': parts[1],
                  'endDate': parts[2],
                  'userName': parts[3],
                  'email': parts[4],
                };
              })
              .where((b) => b != null)
              .cast<Map<String, dynamic>>()
              .toList();
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteIds = prefs.getStringList('favorite_car_ids') ?? [];
    });
  }

  Future<void> _toggleFavorite(String carId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favorite_car_ids') ?? [];
    if (favoriteIds.contains(carId)) {
      favoriteIds.remove(carId);
    } else {
      favoriteIds.add(carId);
    }
    await prefs.setStringList('favorite_car_ids', favoriteIds);
    _loadFavorites();
  }

  Future<void> _unbookCar(String carId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = prefs.getStringList('bookings') ?? [];
    bookings.removeWhere((b) => b.split('|').first == carId);
    await prefs.setStringList('bookings', bookings);
    _loadBookings();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Car unbooked!')));
    }
  }

  Future<void> _showProfilePictureOptions() async {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF003D4C),
                  ),
                  title: Text('Take a Selfie', style: GoogleFonts.roboto()),
                  onTap: () {
                    Navigator.pop(context);
                    _updateProfilePicture(fromCamera: true);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF003D4C),
                  ),
                  title: Text('Choose from Files', style: GoogleFonts.roboto()),
                  onTap: () {
                    Navigator.pop(context);
                    _updateProfilePicture(fromCamera: false);
                  },
                ),
                if (_selfie != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: Text(
                      'Remove Current Photo',
                      style: GoogleFonts.roboto(color: Colors.redAccent),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('profile_selfie');
                      setState(() => _selfie = null);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile picture removed.'),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _updateProfilePicture({required bool fromCamera}) async {
    setState(() => _isLoading = true);
    if (kIsWeb) {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          final bytes = await pickedFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profile_selfie_web', base64Image);
          setState(() {
            _selfie = File('');
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image selected.')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile picture: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
      return;
    }
    final permissionType =
        fromCamera
            ? Permission.camera
            : (Platform.isAndroid ? Permission.storage : Permission.photos);
    final permissionName = fromCamera ? 'camera' : 'gallery/files';
    final mediaGranted = await _requestPermission(
      permissionType,
      permissionName,
    );
    if (!mediaGranted) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (pickedFile != null) {
        final dir = await getApplicationDocumentsDirectory();
        final newPath =
            '${dir.path}/profile_selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final copiedFile = await File(pickedFile.path).copy(newPath);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_selfie', newPath);
        setState(() {
          _selfie = File(newPath);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _requestPermission(Permission permission, String feature) async {
    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Permission for $feature denied. Please enable it in settings.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('My Profile')),
        backgroundColor: const Color.fromARGB(163, 79, 102, 108),
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF003D4C)),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Profile',
                          style: GoogleFonts.montserrat(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF5F6F5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildProfileDetail('Name', _name),
                        _buildProfileDetail('Email', _email),
                        _buildProfileDetail('Phone', _phone),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MultimediaScreen(),
                              ),
                            ).then((_) => _loadUserData());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF003D4C),
                            foregroundColor: const Color(0xFFF5F6F5),
                          ),
                          child: Text(
                            'Manage Multimedia',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 24),
                        Text(
                          'My Bookings',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF5F6F5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _bookings.isEmpty
                            ? Center(
                              child: Text(
                                'No bookings yet.',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: const Color(0xFFF5F6F5),
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _bookings.length,
                              itemBuilder: (context, index) {
                                final booking = _bookings[index];
                                final car = booking['car'] as Car;
                                return Column(
                                  children: [
                                    CarCard(
                                      car: car,
                                      isFavorite: _favoriteIds.contains(car.id),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => CarDetailsScreen(
                                                  car: car,
                                                  onSelect: () {},
                                                  isBookedChecker: () {
                                                    final bookings =
                                                        _bookings
                                                            .map(
                                                              (b) =>
                                                                  b['car'].id,
                                                            )
                                                            .toList();
                                                    return bookings.contains(
                                                      car.id,
                                                    );
                                                  },
                                                ),
                                          ),
                                        );
                                      },
                                      onFavorite: () => _toggleFavorite(car.id),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton.icon(
                                          onPressed: () => _unbookCar(car.id),
                                          icon: const Icon(Icons.undo),
                                          label: const Text('Unbook'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red[700],
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF5F6F5),
            ),
          ),
          Text(
            value.isNotEmpty ? value : '-',
            style: GoogleFonts.roboto(fontSize: 16, color: const Color(0xFFF5F6F5)),
          ),
        ],
      ),
    );
  }

  // Add this method to allow parent to reload data
  void reload() {
    _loadUserData();
    _loadBookings();
    _loadFavorites();
  }
}

// Add this typedef to allow access to the state type from outside
typedef ProfileScreenState = _ProfileScreenState;
