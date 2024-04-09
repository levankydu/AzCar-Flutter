import 'package:decimal/decimal.dart';

class UserModel {
  final int id;
  final String firstName;
  final String? lastName; // lastName may be nullable
  late final String email;
  final String? phone; // phone may be nullable
  final String? gender; // gender may be nullable
  final DateTime? dob; // dob may be nullable
  final String image;
  final Decimal? balance;

  UserModel({
    required this.image,
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.gender,
    this.dob,
    this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'],
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
      image: json['image'] ?? '',
      balance: json['balance'] != null ? Decimal.parse(json['balance'].toString()) : null,
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
      'dob': dob?.toIso8601String(),
      'image': image,
      'balance': balance?.toString(),
    };
  }
}
