import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class UserModel {
  final int id;
  late String firstName;
  late String lastName; // lastName may be nullable
  late final String email;
  late String phone; // phone may be nullable
  late String gender; // gender may be nullable
  late DateTime? dob; // dob may be nullable
  final String image;
  final double? balance;
  late String resetPasswordToken;

  UserModel({
    required this.image,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.resetPasswordToken,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      image: json['image'] ?? '',
      balance: json['balance']
      resetPasswordToken: json['resetPasswordToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'dob': dob != null ? DateFormat('yyyy-MM-dd').format(dob!) : null,
      'image': image,
      'balance': balance,
      'resetPasswordToken': resetPasswordToken,
    };
  }
}
