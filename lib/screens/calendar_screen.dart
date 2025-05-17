import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/car.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = prefs.getStringList('bookings') ?? [];
    final Map<DateTime, List<Map<String, dynamic>>> events = {};
    for (var booking in bookings) {
      final parts = booking.split('|');
      if (parts.length >= 5) {
        final carId = parts[0];
        final startDate = DateTime.tryParse(parts[1]);
        final endDate = DateTime.tryParse(parts[2]);
        final userName = parts[3];
        final userEmail = parts[4];
        final car = mockCars.firstWhere(
          (c) => c.id == carId,
          orElse: () => mockCars.first,
        );
        if (startDate != null && endDate != null) {
          for (
            var day = startDate;
            !day.isAfter(endDate);
            day = day.add(const Duration(days: 1))
          ) {
            final date = DateTime(day.year, day.month, day.day);
            events[date] = events[date] ?? [];
            events[date]!.add({
              'car': car,
              'userName': userName,
              'userEmail': userEmail,
              'startDate': startDate,
              'endDate': endDate,
            });
          }
        }
      }
    }
    setState(() {
      _events = events;
    });
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<Car> _getAvailableCarsForRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return [];
    final bookedCarIds = <String>{};
    for (
      var day = start;
      !day.isAfter(end);
      day = day.add(const Duration(days: 1))
    ) {
      final events = _getEventsForDay(day);
      for (var event in events) {
        final Car car = event['car'];
        bookedCarIds.add(car.id);
      }
    }
    return mockCars.where((car) => !bookedCarIds.contains(car.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final availableCars = _getAvailableCarsForRange(
      _rangeStart ?? _selectedDay,
      _rangeEnd ?? _selectedDay,
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(163, 79, 102, 108),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            rangeSelectionMode: _rangeSelectionMode,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _rangeStart = null;
                _rangeEnd = null;
                _rangeSelectionMode = RangeSelectionMode.toggledOff;
              });
            },
            onRangeSelected: (start, end, focusedDay) {
              setState(() {
                _selectedDay = null;
                _focusedDay = focusedDay;
                _rangeStart = start;
                _rangeEnd = end;
                _rangeSelectionMode = RangeSelectionMode.toggledOn;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: const BoxDecoration(
                color: Color.fromARGB(53, 255, 255, 255),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              rangeStartDecoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              rangeEndDecoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              withinRangeDecoration: const BoxDecoration(
                color: Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Color(0xFF003D4C),
                shape: BoxShape.circle,
              ),
              defaultTextStyle: GoogleFonts.montserrat(color: Colors.black),
              weekendTextStyle: GoogleFonts.montserrat(color: Colors.black),
              selectedTextStyle: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              rangeStartTextStyle: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              rangeEndTextStyle: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              withinRangeTextStyle: GoogleFonts.montserrat(color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          if (_rangeStart != null && _rangeEnd != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Cars from '
                    '${_rangeStart!.toString().substring(0, 10)} to '
                    '${_rangeEnd!.toString().substring(0, 10)}:',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (availableCars.isEmpty)
                    Text(
                      'No cars available for the selected dates.',
                      style: GoogleFonts.roboto(color: Colors.white),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: availableCars.length,
                        itemBuilder: (context, index) {
                          final car = availableCars[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    car.imagePath,
                                    width: 60,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${car.make} ${car.model}',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: ListView(
              children:
                  _getEventsForDay(
                    _selectedDay ?? _focusedDay,
                  ).asMap().entries.map((entry) {
                    final idx = entry.key;
                    final event = entry.value;
                    final Car car = event['car'];
                    final userName = event['userName'];
                    final userEmail = event['userEmail'];
                    final startDate = event['startDate'] as DateTime;
                    final endDate = event['endDate'] as DateTime;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          car.imagePath,
                          width: 48,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        '${car.make} ${car.model}',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          color: const Color.fromARGB(255, 117, 139, 159),
                        ),
                      ),
                      subtitle: Text(
                        'Booked by: $userName\nEmail: $userEmail\nFrom: ${startDate.toString().substring(0, 10)} To: ${endDate.toString().substring(0, 10)}',
                        style: GoogleFonts.roboto(color: Colors.black87),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Remove booking',
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Remove Booking'),
                                  content: const Text(
                                    'Are you sure you want to remove this booking?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm == true) {
                            final prefs = await SharedPreferences.getInstance();
                            final bookings =
                                prefs.getStringList('bookings') ?? [];
                            // Find and remove the booking string
                            final bookingString =
                                '${car.id}|${startDate.toIso8601String()}|${endDate.toIso8601String()}|$userName|$userEmail';
                            bookings.remove(bookingString);
                            await prefs.setStringList('bookings', bookings);
                            _loadEvents();
                          }
                        },
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton:
          (_selectedDay != null || (_rangeStart != null && _rangeEnd != null))
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final DateTime start = _rangeStart ?? _selectedDay!;
                  final DateTime end = _rangeEnd ?? _selectedDay!;
                  final List<Car> cars = _getAvailableCarsForRange(start, end);
                  Car? selectedCar;
                  String userName = '';
                  String userEmail = '';
                  await showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: const Text('Book your car'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Select Car:',
                                    style: GoogleFonts.montserrat(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 90,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children:
                                            cars.map((car) {
                                              final isSelected =
                                                  selectedCar?.id == car.id;
                                              return GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    selectedCar = car;
                                                  });
                                                },
                                                child: AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 200,
                                                  ),
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                      ),
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        isSelected
                                                            ? Colors.black
                                                            : Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          isSelected
                                                              ? Colors
                                                                  .blueAccent
                                                              : Colors
                                                                  .grey
                                                                  .shade300,
                                                      width:
                                                          isSelected ? 2.5 : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    boxShadow:
                                                        isSelected
                                                            ? [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .blueAccent
                                                                    .withOpacity(
                                                                      0.2,
                                                                    ),
                                                                blurRadius: 8,
                                                              ),
                                                            ]
                                                            : [],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Image.asset(
                                                        car.imagePath,
                                                        width: 50,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '${car.make} ${car.model}',
                                                            style: GoogleFonts.montserrat(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  isSelected
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Your Name',
                                    ),
                                    onChanged: (value) => userName = value,
                                  ),
                                  TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Your Email',
                                    ),
                                    onChanged: (value) => userEmail = value,
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (selectedCar != null &&
                                      userName.isNotEmpty &&
                                      userEmail.isNotEmpty) {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final bookings =
                                        prefs.getStringList('bookings') ?? [];
                                    bookings.add(
                                      '${selectedCar!.id}|${start.toIso8601String()}|${end.toIso8601String()}|$userName|$userEmail',
                                    );
                                    await prefs.setStringList(
                                      'bookings',
                                      bookings,
                                    );
                                    Navigator.pop(context);
                                    _loadEvents();
                                    setState(() {
                                      _selectedDay = null;
                                      _rangeStart = null;
                                      _rangeEnd = null;
                                      _rangeSelectionMode =
                                          RangeSelectionMode.toggledOff;
                                    });
                                  }
                                },
                                child: const Text('Book'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Book your car'),
              )
              : null,
    );
  }
}
