import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Bike {
  final String id;
  final String name;
  final String manufacturerId;
  final bool isScooter;

  Bike({required this.id, required this.name, required this.manufacturerId, this.isScooter = false});

  factory Bike.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Bike(
      id: doc.id,
      name: data['name'] ?? '',
      manufacturerId: data['manufacturerId'] ?? '',
      isScooter: data['isScooter'] ?? false,
    );
  }
}

class Manufacturer {
  final String id;
  final String name;
  final List<Bike> bikes;
  bool isExpanded;

  Manufacturer({required this.id, required this.name, this.bikes = const [], this.isExpanded = false});

  factory Manufacturer.fromFirestore(DocumentSnapshot doc, List<Bike> bikes) {
    Map data = doc.data() as Map;
    return Manufacturer(
      id: doc.id,
      name: data['name'] ?? '',
      bikes: bikes,
    );
  }
}

class BikeProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Manufacturer> _manufacturers = [];
  bool _isLoading = false;

  List<Manufacturer> get manufacturers => _manufacturers;
  bool get isLoading => _isLoading;

  BikeProvider() {
    fetchData();
  }

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Manufacturers
      QuerySnapshot mSnap = await _db.collection('manufacturers').get();
      
      // If empty, seed the database with initial data
      if (mSnap.docs.isEmpty) {
        await _seedDatabase();
        mSnap = await _db.collection('manufacturers').get();
      }

      // 2. Fetch all Bikes
      QuerySnapshot bSnap = await _db.collection('bikes').get();
      List<Bike> allBikes = bSnap.docs.map((doc) => Bike.fromFirestore(doc)).toList();

      // 3. Map Bikes to Manufacturers
      _manufacturers = mSnap.docs.map((mDoc) {
        List<Bike> manufacturerBikes = allBikes.where((b) => b.manufacturerId == mDoc.id).toList();
        return Manufacturer.fromFirestore(mDoc, manufacturerBikes);
      }).toList();

    } catch (e) {
      debugPrint('Error fetching bikes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _seedDatabase() async {
    debugPrint('Seeding database with initial bike data...');
    final companies = {
      'KTM': ['Duke 200', 'Duke 390', 'RC 200'],
      'Royal Enfield': ['Classic 350', 'Hunter 350', 'Meteor 350'],
      'TVS': ['Apache RTR 160', 'Apache RTR 200', 'Ntorq 125'],
      'Bajaj': ['Pulsar NS200', 'Pulsar RS200', 'Pulsar N160'],
      'BMW Motorrad': ['S1000RR'],
    };

    for (var company in companies.keys) {
      DocumentReference mRef = await _db.collection('manufacturers').add({'name': company});
      for (var bikeName in companies[company]!) {
        await _db.collection('bikes').add({
          'name': bikeName,
          'manufacturerId': mRef.id,
          'isScooter': bikeName.toLowerCase().contains('ntorq'),
        });
      }
    }
  }
}
