import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as lat_lng;
import 'package:permission_handler/permission_handler.dart';
import '../models/car.dart';

class GpsTrackingScreen extends StatefulWidget {
  const GpsTrackingScreen({super.key});

  @override
  _GpsTrackingScreenState createState() => _GpsTrackingScreenState();
}

class _GpsTrackingScreenState extends State<GpsTrackingScreen> {
  static const lat_lng.LatLng _center = lat_lng.LatLng(
    37.7749,
    -122.4194,
  ); // San Francisco

  // Example locations for each car (should match mockCars length)
  final List<lat_lng.LatLng> _carLocations = [
    lat_lng.LatLng(37.7749, -122.4194), // Tesla Model S Plaid
    lat_lng.LatLng(37.7849, -122.4294), // Porsche 911 Turbo S
    lat_lng.LatLng(37.7649, -122.4094), // BMW X7
    lat_lng.LatLng(37.7549, -122.4394), // Mercedes-Benz S-Class Sedan
  ];

  List<Marker> get _markers {
    return List.generate(mockCars.length, (index) {
      final car = mockCars[index];
      final location =
          _carLocations.length > index
              ? _carLocations[index]
              : _center; // fallback if not enough locations
      return Marker(
        point: location,
        width: 80,
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_pin, color: Colors.red, size: 40),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.white.withOpacity(0.8),
              child: Text(
                '${car.make} ${car.model}',
                style: const TextStyle(fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
      );
    });
  }


  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      setState(() {
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location permission denied. Map functionality limited.',
            style: GoogleFonts.roboto(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Your Car', style: GoogleFonts.montserrat()),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _center,
          initialZoom: 12,
          maxZoom: 18,
          minZoom: 3,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.carrents',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}
