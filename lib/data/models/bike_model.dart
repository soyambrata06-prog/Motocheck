class BikeModel {
  final String id;
  final String plateNumber;
  final String model;
  final String make;
  final int year;
  final String? engineSize;
  final String? power;
  final String? weight;
  final String? topSpeed;
  final double? dbLimit;
  final bool isLegal;

  BikeModel({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.make,
    required this.year,
    this.engineSize,
    this.power,
    this.weight,
    this.topSpeed,
    this.dbLimit,
    this.isLegal = true,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'],
      plateNumber: json['plateNumber'],
      model: json['model'],
      make: json['make'],
      year: json['year'],
      engineSize: json['engineSize'],
      power: json['power'],
      weight: json['weight'],
      topSpeed: json['topSpeed'],
      dbLimit: json['dbLimit']?.toDouble(),
      isLegal: json['isLegal'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'model': model,
      'make': make,
      'year': year,
      'engineSize': engineSize,
      'power': power,
      'weight': weight,
      'topSpeed': topSpeed,
      'dbLimit': dbLimit,
      'isLegal': isLegal,
    };
  }
}
