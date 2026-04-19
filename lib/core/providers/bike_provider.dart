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
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  List<Manufacturer> _manufacturers = [];
  bool _isLoading = false;

  List<Manufacturer> get manufacturers => _manufacturers;
  bool get isLoading => _isLoading;

  BikeProvider() {
    _initializeDefaultData();
    fetchData();
  }

  void _initializeDefaultData() {
    final companies = {
      'KTM': ['Duke 200', 'Duke 250', 'Duke 390', 'RC 200', 'RC 390', 'Adventure 390'],
      'Royal Enfield': ['Classic 350', 'Hunter 350', 'Meteor 350', 'Himalayan 450', 'Interceptor 650', 'Continental GT 650'],
      'TVS': ['Apache RTR 160', 'Apache RTR 200', 'Apache RR 310', 'Ntorq 125', 'Jupiter 125', 'iQube'],
      'Bajaj': ['Pulsar NS200', 'Pulsar RS200', 'Pulsar N160', 'Dominar 400', 'Pulsar 220F', 'Chetak'],
      'BMW Motorrad': ['S1000RR', 'G 310 R', 'G 310 GS', 'R 1250 GS', 'M 1000 RR'],
      'Honda': ['CB350', 'Activa 6G', 'CBR650R', 'CB300R', 'Hornet 2.0', 'Dio'],
      'Yamaha': ['R15 V4', 'MT-15', 'Aerox 155', 'FZS-FI', 'R1', 'MT-09'],
      'Kawasaki': ['Ninja 300', 'Ninja 400', 'Z900', 'Ninja ZX-10R', 'Ninja H2'],
      'Suzuki': ['Hayabusa', 'Gixxer SF 250', 'V-Strom SX', 'Access 125', 'Burgman Street'],
      'Ducati': ['Panigale V4', 'Monster', 'Multistrada V4', 'Streetfighter V4', 'Scrambler'],
      'Hero': ['Splendor+', 'Xpulse 200 4V', 'Karizma XMR', 'Destini 125', 'Pleasure+'],
    };

    _manufacturers = companies.entries.map((e) {
      return Manufacturer(
        id: e.key,
        name: e.key,
        bikes: e.value.map((b) => Bike(
          id: b,
          name: b,
          manufacturerId: e.key,
          isScooter: b.toLowerCase().contains('ntorq') || 
                     b.toLowerCase().contains('activa') ||
                     b.toLowerCase().contains('aerox'),
        )).toList(),
      );
    }).toList();
    _manufacturers.sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> fetchData() async {
    if (_manufacturers.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      await _seedDatabase();

      QuerySnapshot mSnap = await _db.collection('manufacturers').orderBy('name').get();

      QuerySnapshot bSnap = await _db.collection('bikes').orderBy('name').get();
      List<Bike> allBikes = bSnap.docs.map((doc) => Bike.fromFirestore(doc)).toList();

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
      'Honda': ['CB350', 'Activa 6G', 'CBR650R'],
      'Yamaha': ['R15 V4', 'MT-15', 'Aerox 155'],
    };

    WriteBatch batch = _db.batch();

    for (var company in companies.keys) {
      QuerySnapshot existing = await _db.collection('manufacturers')
          .where('name', isEqualTo: company)
          .get();
      
      DocumentReference mRef;
      if (existing.docs.isEmpty) {
        mRef = _db.collection('manufacturers').doc();
        batch.set(mRef, {'name': company});
      } else {
        mRef = existing.docs.first.reference;
      }

      for (var bikeName in companies[company]!) {
        QuerySnapshot existingBike = await _db.collection('bikes')
            .where('name', isEqualTo: bikeName)
            .where('manufacturerId', isEqualTo: mRef.id)
            .get();
        
        if (existingBike.docs.isEmpty) {
          DocumentReference bRef = _db.collection('bikes').doc();
          batch.set(bRef, {
            'name': bikeName,
            'manufacturerId': mRef.id,
            'isScooter': bikeName.toLowerCase().contains('ntorq') || 
                         bikeName.toLowerCase().contains('activa') ||
                         bikeName.toLowerCase().contains('aerox'),
          });
        }
      }
    }
    
    await batch.commit();
    debugPrint('Database seeding completed.');
  }
}
