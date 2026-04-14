class BikeModel {
  final String id;
  final String plateNumber;
  final String model;
  final String make;
  final int year;

  BikeModel({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.make,
    required this.year,
  });

  factory BikeModel.fromJson(Map<String, dynamic> json) {
    return BikeModel(
      id: json['id'],
      plateNumber: json['plateNumber'],
      model: json['model'],
      make: json['make'],
      year: json['year'],
    );
  }
}
