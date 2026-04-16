import '../../core/constants/enums.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String dob;
  final String address;
  final String profileImageUrl;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.dob,
    required this.address,
    required this.profileImageUrl,
    required this.role,
  });
}
