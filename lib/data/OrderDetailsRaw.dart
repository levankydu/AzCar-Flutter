import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'ExtraFee.dart';

class OrderDetailsRaw {
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

  OrderDetailsRaw({
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
    required this.createdAt,
    required this.updatedAt,
    required this.sameDistrict,
    required this.sameProvince,
    required this.statusOnView,
  });

  factory OrderDetailsRaw.fromMap(Map<String, dynamic> map) {
    return OrderDetailsRaw(
      id: map['id'] ?? '',
      carId: map['carId'] ?? '',
      userId: map['userId'] ?? '',
      totalRent: map['totalRent'] ?? 0.0,
      fromDate: parseDateTime(map['fromDate']),
      toDate: parseDateTime(map['toDate']),
      differenceDate: map['differenceDate'] ?? 0,
      deliveryAddress: map['deliveryAddress'] ?? '',
      extraFee: ExtraFee.fromJson(map['extraFee']),
      status: map['status'] ?? '',
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
      sameDistrict: map['sameDistrict'] ?? false,
      sameProvince: map['sameProvince'] ?? false,
      statusOnView: map['statusOnView'] ?? '',
    );
  }
}

String parseDateTime(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
  return formattedDate;
}
