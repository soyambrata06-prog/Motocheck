class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'relationship': relationship,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        id: json['id'],
        name: json['name'],
        phoneNumber: json['phoneNumber'],
        relationship: json['relationship'],
      );
}

