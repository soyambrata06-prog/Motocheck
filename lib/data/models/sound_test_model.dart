class SoundTestModel {
  final String id;
  final String bikeName;
  final String manufacturer;
  final double peakDb;
  final double avgDb;
  final double limitDb;
  final bool isPass;
  final DateTime timestamp;
  final String mode;

  SoundTestModel({
    required this.id,
    required this.bikeName,
    required this.manufacturer,
    required this.peakDb,
    required this.avgDb,
    required this.limitDb,
    required this.isPass,
    required this.timestamp,
    required this.mode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bikeName': bikeName,
      'manufacturer': manufacturer,
      'peakDb': peakDb,
      'avgDb': avgDb,
      'limitDb': limitDb,
      'isPass': isPass,
      'timestamp': timestamp.toIso8601String(),
      'mode': mode,
    };
  }

  factory SoundTestModel.fromJson(Map<String, dynamic> json) {
    return SoundTestModel(
      id: json['id'],
      bikeName: json['bikeName'],
      manufacturer: json['manufacturer'],
      peakDb: json['peakDb'],
      avgDb: json['avgDb'],
      limitDb: json['limitDb'],
      isPass: json['isPass'],
      timestamp: DateTime.parse(json['timestamp']),
      mode: json['mode'],
    );
  }
}

