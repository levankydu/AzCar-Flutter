import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'ExtraFee.dart';

class OrderDetails {
  final int id;
  final String carId;
  final int userId;
  final double totalRent;
  final String fromDate;
  final String toDate;
  final int differenceDate;
  final String deliveryAddress;
  final ExtraFee extraFee;
  final String status;
  final String createdAt;
  final String updatedAt;
  final bool sameDistrict;
  final bool sameProvince;
  final String statusOnView;
  final CarModel car;

  OrderDetails({
    required this.id,
    required this.carId,
    required this.userId,
    required this.totalRent,
    required this.fromDate,
    required this.toDate,
    required this.differenceDate,
    required this.deliveryAddress,
    required this.extraFee,
    required this.status,
    required this.statusOnView,
    required this.createdAt,
    required this.updatedAt,
    required this.sameDistrict,
    required this.sameProvince,
    required this.car,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id']??0,
      carId: json['carId']??'',
      userId: json['userId']??0,
      totalRent: json['totalRent']??0,
      fromDate: parseDateTime(json['fromDate']),
      toDate: parseDateTime(json['toDate']),
      differenceDate: json['differenceDate'],
      deliveryAddress: json['deliveryAddress'],
      extraFee: ExtraFee.fromJson(json['extraFee']),
      status: json['status'],
      statusOnView: json['statusOnView'],
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
      sameDistrict: json['sameDistrict'],
      sameProvince: json['sameProvince'],
      car: CarModel.fromJson(json['car']),
    );
  }
}

String parseDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
  return formattedDate;
}