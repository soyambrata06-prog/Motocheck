class ViolationModel {
  final String id;
  final String title;
  final String description;
  final double fineAmount;
  final DateTime date;

  ViolationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fineAmount,
    required this.date,
  });
}

