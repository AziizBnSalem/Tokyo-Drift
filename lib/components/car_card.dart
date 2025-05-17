import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/car.dart';
import 'package:google_fonts/google_fonts.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const CarCard({
    Key? key,
    required this.car,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0x330097A7), // blue shadow
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x220097A7),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    car.imagePath,
                                    width: 110,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0x330097A7),
                                            Colors.transparent,
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 18.0,
                          right: 12,
                          bottom: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car.make} ${car.model}',
                              style: GoogleFonts.montserrat(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF003D4C),
                                letterSpacing: 0.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                _InfoChip(
                                  icon: Icons.calendar_today,
                                  label: '${car.year}',
                                  color: const Color(0xFF0097A7),
                                ),
                                const SizedBox(width: 6),
                                _InfoChip(
                                  icon: Icons.local_gas_station,
                                  label: car.fuelType,
                                  color: const Color(0xFF0097A7),
                                ),
                                const SizedBox(width: 6),
                                _InfoChip(
                                  icon: Icons.settings,
                                  label: car.transmission,
                                  color: const Color(0xFF0097A7),
                                ),
                              ],
                            ),
                            const SizedBox(height: 13),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF003D4C),
                                        Color(0xFF0097A7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0x220097A7),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '24${car.pricePerDay.toStringAsFixed(0)}/day',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0097A7),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    car.category,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating favorite button
            Positioned(
              top: 8,
              right: 10,
              child: Material(
                color: isFavorite ? const Color(0xFF0097A7) : Colors.white,
                elevation: 3,
                shape: const CircleBorder(),
                shadowColor: const Color(0x330097A7),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: onFavorite,
                  child: Padding(
                    padding: const EdgeInsets.all(7.0),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color:
                          isFavorite ? Colors.white : const Color(0xFF0097A7),
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      margin: const EdgeInsets.only(right: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
