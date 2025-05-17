class Car {
  final String id;
  final String make;
  final String model;
  final int year;
  final double pricePerDay;
  final String fuelType;
  final String transmission;
  final bool isAvailable;
  final String imagePath;
  final String category;

  Car({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.pricePerDay,
    required this.fuelType,
    required this.transmission,
    required this.isAvailable,
    required this.imagePath,
    required this.category,
  });
}

// Expanded car list (merging existing and new cars)
List<Car> mockCars = [
  Car(
    id: '1',
    make: 'Tesla',
    model: 'Model S Plaid',
    year: 2023,
    pricePerDay: 150.0,
    fuelType: 'Electric',
    transmission: 'Automatic',
    isAvailable: true,
    imagePath: 'lib/assets/images/cars/tesla.jpg',
    category: 'Electric',
  ),
  Car(
    id: '2',
    make: 'Porsche',
    model: '911 Turbo S',
    year: 2022,
    pricePerDay: 200.0,
    fuelType: 'Petrol',
    transmission: 'Automatic',
    isAvailable: false,
    imagePath: 'lib/assets/images/cars/porshe.jpg',
    category: 'Luxury',
  ),
  Car(
    id: '3',
    make: 'BMW',
    model: 'X7',
    year: 2018,
    pricePerDay: 120.0,
    fuelType: 'Diesel',
    transmission: 'Automatic',
    isAvailable: true,
    imagePath: 'lib/assets/images/cars/BMW_X7_2018_caff3.jpg',
    category: 'SUV',
  ),
  Car(
    id: '4',
    make: 'Mercedes-Benz',
    model: 'S-Class Sedan',
    year: 2024,
    pricePerDay: 180.0,
    fuelType: 'Petrol',
    transmission: 'Automatic',
    isAvailable: true,
    imagePath: 'lib/assets/images/cars/2024_mercedes-benz_s-class_sedan.png',
    category: 'Luxury',
  ),
];
