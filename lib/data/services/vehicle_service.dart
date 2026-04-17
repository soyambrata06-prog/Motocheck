import 'dart:math';
import '../models/bike_model.dart';

class VehicleService {
  final List<String> _models = [
    'Duke 390', 'Classic 350', 'MT-15', 'R15 V4', 'Pulsar NS200', 
    'Apache RTR 200', 'Himalayan 450', 'Ninja 300', 'RC 390', 'Dominar 400'
  ];

  final Map<String, String> _modelToMake = {
    'Duke 390': 'KTM',
    'Classic 350': 'Royal Enfield',
    'MT-15': 'Yamaha',
    'R15 V4': 'Yamaha',
    'Pulsar NS200': 'Bajaj',
    'Apache RTR 200': 'TVS',
    'Himalayan 450': 'Royal Enfield',
    'Ninja 300': 'Kawasaki',
    'RC 390': 'KTM',
    'Dominar 400': 'Bajaj',
  };

  final Map<String, Map<String, dynamic>> _modelSpecs = {
    'Duke 390': {
      'engineSize': '373.2 cc',
      'power': '43.5 PS',
      'weight': '171 kg',
      'topSpeed': '167 km/h',
      'dbLimit': 88.0,
    },
    'Classic 350': {
      'engineSize': '349 cc',
      'power': '20.2 PS',
      'weight': '195 kg',
      'topSpeed': '114 km/h',
      'dbLimit': 82.0,
    },
    'MT-15': {
      'engineSize': '155 cc',
      'power': '18.4 PS',
      'weight': '139 kg',
      'topSpeed': '130 km/h',
      'dbLimit': 80.0,
    },
    'R15 V4': {
      'engineSize': '155 cc',
      'power': '18.4 PS',
      'weight': '142 kg',
      'topSpeed': '140 km/h',
      'dbLimit': 80.0,
    },
    'Pulsar NS200': {
      'engineSize': '199.5 cc',
      'power': '24.5 PS',
      'weight': '158 kg',
      'topSpeed': '136 km/h',
      'dbLimit': 84.0,
    },
  };

  Future<BikeModel?> getVehicleDetails(String plateNumber) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, we return a random bike if the plate is validly formatted
    // In a real app, this would call Vahan API or a backend
    final random = Random();
    final model = _models[random.nextInt(_models.length)];
    final make = _modelToMake[model] ?? 'Unknown';
    final specs = _modelSpecs[model] ?? {
      'engineSize': 'Unknown',
      'power': 'Unknown',
      'weight': 'Unknown',
      'topSpeed': 'Unknown',
      'dbLimit': 85.0,
    };

    return BikeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      plateNumber: plateNumber,
      model: model,
      make: make,
      year: 2020 + random.nextInt(5),
      engineSize: specs['engineSize'],
      power: specs['power'],
      weight: specs['weight'],
      topSpeed: specs['topSpeed'],
      dbLimit: specs['dbLimit'],
      isLegal: random.nextDouble() > 0.2, // 80% chance of being legal
    );
  }
}
