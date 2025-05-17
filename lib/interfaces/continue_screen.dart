import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import 'login.dart';
import 'signup.dart';

class ContinueScreen extends StatefulWidget {
  const ContinueScreen({super.key});

  @override
  State<ContinueScreen> createState() => _ContinueScreenState();
}

class _ContinueScreenState extends State<ContinueScreen> {
  int _currentPage = 0;
  bool shownbtn = false;
  @override
  void initState() {
    // TODO: implement initState
    shownbtn = _currentPage == 0 ? false : true;
    super.initState();
  }

  // List of introduction pages' content
  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Tokyo Drift',
      'description':
          'Discover the easiest way to rent a car for your next adventure. With Tokyo Drift, you get access to a wide range of vehicles at your fingertips.',
      'image': 'lib/assets/images/background5.jpg',
    },
    {
      'title': 'Choose Your Ride',
      'description':
          'From compact cars to luxury SUVs, select the perfect vehicle that suits your style and budget. Book in just a few clicks!',
      'image': 'lib/assets/images/background7.jpg',
    },
    {
      'title': 'Drive with Confidence',
      'description':
          'Enjoy peace of mind with our 24/7 support, flexible rentals, and top-notch vehicle maintenance.',
      'image': 'lib/assets/images/background6.jpg',
    },
  ];
  void _previousPage() {
    setState(() {
      if (_currentPage <= _pages.length - 1) {
        _currentPage--;
      } else {
        // Navigate to Login/Signup page

        print(_currentPage);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        //  Navigator.pop(context);
      }
      shownbtn = _currentPage == 0 ? false : true;
    });
  }

  void _nextPage() {
    setState(() {
      if (_currentPage < _pages.length - 1) {
        _currentPage++;
      } else {
        // Show modal bottom sheet with Login and Signup buttons
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Container(
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'START YOUR ENGINES',
                      style: GoogleFonts.orbitron(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 36),
                    _buildAuthButton(
                      context,
                      'LOGIN',
                      kPrimaryColor,
                      const LoginScreen(),
                      Icons.login,
                    ),
                    const SizedBox(height: 16),
                    _buildAuthButton(
                      context,
                      'SIGN UP',
                      kPrimaryColor,
                      const SignupScreen(),
                      Icons.person_add,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
        );
      }
      shownbtn = _currentPage == 0 ? false : true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_pages[_currentPage]['image']!),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xAD000000),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title and Description
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _pages[_currentPage]['title']!,
                          style: GoogleFonts.orbitron(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFF5F6F5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[_currentPage]['description']!,
                          style: GoogleFonts.orbitron(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFDDE1E4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                // Continue Button and Page Indicator
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Page Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: _currentPage == index ? 12.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color:
                                  _currentPage == index
                                      ? const Color(0xFF003D4C)
                                      : Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Continue Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          shownbtn == true
                              ? ElevatedButton(
                                onPressed: _previousPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Previous',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF000000),
                                  ),
                                ),
                              )
                              : Container(),
                          ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF003D4C),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Continue',
                              style: GoogleFonts.orbitron(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFF5F6F5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButton(
    BuildContext context,
    String text,
    Color color,
    Widget destination,
    IconData icon,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: color.withOpacity(0.5),
        ),
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 14),
            Text(
              text,
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
