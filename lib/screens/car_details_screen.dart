import 'package:flutter/material.dart';
import '../models/car.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;
  final VoidCallback onSelect;
  final bool Function()? isBookedChecker;

  const CarDetailsScreen({
    Key? key,
    required this.car,
    required this.onSelect,
    this.isBookedChecker,
  }) : super(key: key);

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // Force rebuild to check booking state
  }

  bool get isBooked => widget.isBookedChecker?.call() ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F666C),
      appBar: AppBar(
        title: Text('${widget.car.make} ${widget.car.model}'),
                        backgroundColor: const Color(0xFF003D4C),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Hero(
                tag: 'carImage_${widget.car.imagePath}',
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    widget.car.imagePath,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.car.make} ${widget.car.model}',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: const Color(0xFF003D4C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.car.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.local_gas_station,
                        size: 18,
                        color: const Color(0xFF003D4C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.car.fuelType,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.settings, size: 18,
                      color: const Color(0xFF003D4C),),
                      const SizedBox(width: 4),
                      Text(
                        widget.car.transmission,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey[300], thickness: 1),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.category, size: 20, color: Color(0xFF003D4C)),
                      const SizedBox(width: 8),
                      Text(
                        'Category: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFA7A7A7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        widget.car.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: 20,
                        color: const Color(0xFF003D4C),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Price per day: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFFA7A7A7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '\$24${widget.car.pricePerDay}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        widget.car.isAvailable
                            ? Icons.check_circle
                            : Icons.cancel,
                        color:
                            widget.car.isAvailable ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.car.isAvailable ? 'Available' : 'Not Available',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              widget.car.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isBooked ? null : widget.onSelect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003D4C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(isBooked ? 'Already Booked' : 'Select Car'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
