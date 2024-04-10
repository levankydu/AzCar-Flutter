import 'package:az_car_flutter_app/data/carModel.dart';

import 'ExtraFee.dart';

class OrderDetails {
  final int id;
  final String carId;
  final CarModel car;
  final int userId;
  final double totalRent;
  final DateTime fromDate;
  final DateTime toDate;
  final int differenceDate;
  final String deliveryAddress;
  final ExtraFee extraFee;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool sameDistrict;
  final bool sameProvince;

  OrderDetails({
    required this.id,
    required this.carId,
    required this.car,
    required this.userId,
    required this.totalRent,
    required this.fromDate,
    required this.toDate,
    required this.differenceDate,
    required this.deliveryAddress,
    required this.extraFee,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.sameDistrict,
    required this.sameProvince,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'],
      carId: json['carId'],
      car: CarModel.fromJson(json['car']),
      userId: json['userId'],
      totalRent: json['totalRent'],
      fromDate: DateTime.parse(json['fromDate']),
      toDate: DateTime.parse(json['toDate']),
      differenceDate: json['differenceDate'],
      deliveryAddress: json['deliveryAddress'],
      extraFee: ExtraFee.fromJson(json['extraFee']),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sameDistrict: json['sameDistrict'],
      sameProvince: json['sameProvince'],
    );
  }
}