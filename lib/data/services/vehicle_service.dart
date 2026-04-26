import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/bike_model.dart';

class VehicleService {
  final String _rapidApiKey = '469df5d22emsh5d7331908638127p1c5678jsn0850228f4204';
  final String _baseUrl = 'https:

  final List<String> _models = [
    'Duke 390', 'Duke 250', 'Duke 200', 'RC 390', 'RC 200', 'Adventure 390',
    'Classic 350', 'Hunter 350', 'Meteor 350', 'Himalayan 450', 'Bullet 350',
    'MT-15', 'R15 V4', 'FZ-S FI',
    'Pulsar NS200', 'Pulsar RS200', 'Pulsar 150', 'Dominar 400', 'Dominar 250',
    'Apache RTR 200 4V', 'Apache RR 310', 'Apache RTR 160 4V',
    'Speed 400', 'Scrambler 400X', 'CB350 H\'ness', 'CB300R',
    'Splendor Plus', 'Activa 6G', 'Jupiter 125', 'X440'
  ];

  final Map<String, String> _modelToMake = {
    'Duke 390': 'KTM', 'Duke 250': 'KTM', 'Duke 200': 'KTM',
    'RC 390': 'KTM', 'RC 200': 'KTM', 'Adventure 390': 'KTM',
    'Classic 350': 'Royal Enfield', 'Hunter 350': 'Royal Enfield',
    'Meteor 350': 'Royal Enfield', 'Himalayan 450': 'Royal Enfield',
    'Bullet 350': 'Royal Enfield',
    'MT-15': 'Yamaha', 'R15 V4': 'Yamaha', 'FZ-S FI': 'Yamaha',
    'Pulsar NS200': 'Bajaj', 'Pulsar RS200': 'Bajaj', 'Pulsar 150': 'Bajaj',
    'Dominar 400': 'Bajaj', 'Dominar 250': 'Bajaj',
    'Apache RTR 200 4V': 'TVS', 'Apache RR 310': 'TVS', 'Apache RTR 160 4V': 'TVS',
    'Speed 400': 'Triumph', 'Scrambler 400X': 'Triumph',
    'CB350 H\'ness': 'Honda', 'CB300R': 'Honda', 'Activa 6G': 'Honda',
    'Splendor Plus': 'Hero', 'Jupiter 125': 'TVS', 'X440': 'Harley-Davidson',
  };

  final Map<String, Map<String, dynamic>> _modelSpecs = {
    'Duke 390': {
      'engineSize': '373.2 cc', 'power': '43.5 PS', 'weight': '171 kg',
      'topSpeed': '167 km/h', 'dbLimit': 88.0,
    },
    'Duke 250': {
      'engineSize': '248.8 cc', 'power': '30 PS', 'weight': '163 kg',
      'topSpeed': '142 km/h', 'dbLimit': 86.0,
    },
    'Duke 200': {
      'engineSize': '199.5 cc', 'power': '25 PS', 'weight': '159 kg',
      'topSpeed': '142 km/h', 'dbLimit': 86.0,
    },
    'RC 390': {
      'engineSize': '373.2 cc', 'power': '43.5 PS', 'weight': '172 kg',
      'topSpeed': '170 km/h', 'dbLimit': 90.0,
    },
    'Classic 350': {
      'engineSize': '349.3 cc', 'power': '20.2 PS', 'weight': '195 kg',
      'topSpeed': '114 km/h', 'dbLimit': 82.0,
    },
    'Hunter 350': {
      'engineSize': '349.3 cc', 'power': '20.2 PS', 'weight': '181 kg',
      'topSpeed': '114 km/h', 'dbLimit': 82.0,
    },
    'Himalayan 450': {
      'engineSize': '452 cc', 'power': '40 PS', 'weight': '196 kg',
      'topSpeed': '150 km/h', 'dbLimit': 84.0,
    },
    'MT-15': {
      'engineSize': '155 cc', 'power': '18.4 PS', 'weight': '141 kg',
      'topSpeed': '130 km/h', 'dbLimit': 80.0,
    },
    'R15 V4': {
      'engineSize': '155 cc', 'power': '18.4 PS', 'weight': '142 kg',
      'topSpeed': '140 km/h', 'dbLimit': 82.0,
    },
    'Pulsar NS200': {
      'engineSize': '199.5 cc', 'power': '24.5 PS', 'weight': '158 kg',
      'topSpeed': '136 km/h', 'dbLimit': 85.0,
    },
    'Dominar 400': {
      'engineSize': '373.3 cc', 'power': '40 PS', 'weight': '193 kg',
      'topSpeed': '155 km/h', 'dbLimit': 88.0,
    },
    'Speed 400': {
      'engineSize': '398.1 cc', 'power': '40 PS', 'weight': '176 kg',
      'topSpeed': '150 km/h', 'dbLimit': 86.0,
    },
    'CB350 H\'ness': {
      'engineSize': '348.3 cc', 'power': '21 PS', 'weight': '181 kg',
      'topSpeed': '125 km/h', 'dbLimit': 82.0,
    },
    'Splendor Plus': {
      'engineSize': '97.2 cc', 'power': '8 PS', 'weight': '112 kg',
      'topSpeed': '87 km/h', 'dbLimit': 78.0,
    },
    'Activa 6G': {
      'engineSize': '109.5 cc', 'power': '7.8 PS', 'weight': '105 kg',
      'topSpeed': '85 km/h', 'dbLimit': 76.0,
    },
    'Pulsar 150': {
      'engineSize': '149.5 cc', 'power': '14 PS', 'weight': '148 kg',
      'topSpeed': '110 km/h', 'dbLimit': 80.0,
    },
    'X440': {
      'engineSize': '440 cc', 'power': '27 PS', 'weight': '190 kg',
      'topSpeed': '135 km/h', 'dbLimit': 84.0,
    },
  };

  Future<BikeModel?> getVehicleDetails(String plateNumber) async {
    final cleanPlate = plateNumber.toUpperCase().replaceAll(' ', '');

    if (cleanPlate == 'MH12AB1234') {
      return BikeModel(
        id: 'DUMMY-1234',
        plateNumber: 'MH 12 AB 1234',
        model: 'Hunter 350',
        make: 'Royal Enfield',
        year: 2023,
        engineSize: '349.3 cc',
        power: '20.2 PS',
        weight: '181 kg',
        topSpeed: '114 km/h',
        dbLimit: 82.0,
        isLegal: true,
        ownerName: 'SOYAMBRATA PRADHAN',
        regDate: '15-Mar-2023',
        fuelType: 'PETROL',
        vehicleClass: 'MOTOR CYCLE',
        insuranceStatus: 'Active',
        pucStatus: 'Valid',
        fitnessStatus: 'Active',
      );
    }

    if (_rapidApiKey != 'YOUR_RAPIDAPI_KEY') {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/get-details?registration_number=$cleanPlate'),
          headers: {
            'X-RapidAPI-Key': _rapidApiKey,
            'X-RapidAPI-Host': 'vahan-vehicle-registration-details-india.p.rapidapi.com',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['status'] == 'success' && data['data'] != null) {
            final result = data['data'];
            return _mapApiToModel(result, cleanPlate);
          }
        }
      } catch (e) {
        debugPrint('RapidAPI Error: $e');
      }
    }

    return _getMockData(cleanPlate);
  }

  BikeModel _mapApiToModel(Map<String, dynamic> apiData, String plate) {
    final modelName = apiData['model'] ?? apiData['vehicle_model'] ?? 'Unknown Model';
    final makeName = apiData['maker'] ?? apiData['manufacturer'] ?? 'Unknown Make';
    
    return BikeModel(
      id: apiData['chassis_number'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      plateNumber: plate,
      model: modelName,
      make: makeName,
      year: int.tryParse(apiData['registration_date']?.split('-')?.last ?? '') ?? 2022,
      engineSize: apiData['engine_capacity'] ?? '-',
      power: '-',
      weight: '-',
      topSpeed: '-',
      dbLimit: _estimateDbLimit(modelName),
      isLegal: true,
      ownerName: apiData['owner_name'] ?? 'N/A',
      regDate: apiData['registration_date'] ?? 'N/A',
      fuelType: apiData['fuel_type'] ?? 'N/A',
      vehicleClass: apiData['vehicle_class'] ?? 'N/A',
      insuranceStatus: 'Active',
      pucStatus: 'Valid',
      fitnessStatus: 'Active',
    );
  }

  Future<BikeModel> _getMockData(String plate) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    final random = Random();
    final model = _models[random.nextInt(_models.length)];
    final make = _modelToMake[model] ?? 'Unknown';
    final specs = _modelSpecs[model] ?? {
      'engineSize': '-',
      'power': '-',
      'weight': '-',
      'topSpeed': '-',
      'dbLimit': 85.0,
    };

    return BikeModel(
      id: 'MOCK-${DateTime.now().millisecondsSinceEpoch}',
      plateNumber: plate,
      model: model,
      make: make,
      year: 2020 + random.nextInt(5),
      engineSize: specs['engineSize'],
      power: specs['power'],
      weight: specs['weight'],
      topSpeed: specs['topSpeed'],
      dbLimit: specs['dbLimit'],
      isLegal: random.nextDouble() > 0.1,
      ownerName: 'JOHN DOE',
      regDate: '10-Jan-2022',
      fuelType: 'PETROL',
      vehicleClass: 'MOTOR CYCLE',
      insuranceStatus: 'Active',
      pucStatus: 'Valid',
      fitnessStatus: 'Active',
    );
  }

  double _estimateDbLimit(String model) {
    String m = model.toUpperCase();
    if (m.contains('CLASSIC') || m.contains('BULLET') || m.contains('METEOR') || m.contains('HUNTER')) return 82.0;
    if (m.contains('DUKE') || m.contains('RC')) {
      if (m.contains('390')) return 88.0;
      return 86.0;
    }
    if (m.contains('R15') || m.contains('MT15') || m.contains('MT-15')) return 80.0;
    if (m.contains('DOMINAR') || m.contains('SPEED 400')) return 86.0;
    return 84.0;
  }

  Future<bool> validatePlate(String plateNumber) async {
    final regExp = RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,3}[0-9]{4}$');
    return regExp.hasMatch(plateNumber.toUpperCase().replaceAll(' ', ''));
  }
}

