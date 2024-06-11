import 'package:az_car_flutter_app/data/user_model.dart';

import 'CarImage.dart';
import 'CarModelType.dart';

class CarModel {
  int seatQty;
  String fuelType;
  bool engineInformationTranmission;
  String services;
  String licensePlates;
  int carOwnerId;
  String status;
  double price;
  String description;
  int discount;
  String rules;
  String address;
  List<CarImage> images;
  CarModelType carmodel;
  UserModel owner;
  int id;
  bool carPlus;
  bool extraFee;
  bool availabled;
  int? deliveryFee;
  int? cleaningFee;
  int? smellFee;
  bool isFavorite;
  int violationAmount;
  int finishedOrders;

  CarModel({
    required this.seatQty,
    required this.fuelType,
    required this.engineInformationTranmission,
    required this.services,
    required this.licensePlates,
    required this.carOwnerId,
    required this.status,
    required this.price,
    required this.description,
    required this.discount,
    required this.rules,
    required this.address,
    required this.images,
    required this.carmodel,
    required this.owner,
    required this.id,
    required this.carPlus,
    required this.extraFee,
    required this.availabled,
    required this.deliveryFee,
    required this.cleaningFee,
    required this.smellFee,
    required this.isFavorite,
    required this.finishedOrders,
    required this.violationAmount,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      seatQty: json['seatQty'],
      fuelType: json['fuelType'],
      engineInformationTranmission: json['engineInformationTranmission'],
      services: json['services'],
      licensePlates: json['licensePlates'],
      carOwnerId: json['carOwnerId'],
      status: json['status'],
      price: json['price'].toDouble(),
      description: json['description'],
      discount: json['discount'] ??0,
      rules: json['rules'],
      address: json['address'],
      images: (json['images'] as List)
          .map((imageJson) => CarImage.fromJson(imageJson))
          .toList(),
      carmodel: CarModelType.fromJson(json['carmodel']),
      owner: UserModel.fromJson(json['owner']),
      id: json['id'],
      carPlus: json['carPlus'],
      extraFee: json['extraFee'],
      availabled: json['availabled'],
      deliveryFee: json['carPlusModel'] != null ? json['carPlusModel']['fee'] : 0,
      cleaningFee: json['extraFeeModel'] != null ? json['extraFeeModel']['cleanningFee'] : 0,
      smellFee: json['extraFeeModel'] != null ? json['extraFeeModel']['decorationFee'] : 0,
      isFavorite: json['favorite'] ?? false,
      violationAmount: json['activeViolationAmount'] ?? 0,
      finishedOrders: json['finishedOrders'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seatQty': seatQty,
      'fuelType': fuelType,
      'engineInformationTranmission': engineInformationTranmission,
      'services': services,
      'licensePlates': licensePlates,
      'carOwnerId': carOwnerId,
      'status': status,
      'price': price,
      'description': description,
      'discount': discount,
      'rules': rules,
      'address': address,
      'images': images.map((image) => image.toJson()).toList(),
      'carmodel': carmodel.toJson(),
      'owner': owner.toJson(),
      'id': id,
      'carPlus': carPlus,
      'extraFee': extraFee,
      'availabled': availabled,
    };
  }
}
