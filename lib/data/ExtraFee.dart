import 'package:flutter/material.dart';

class ExtraFee {
  final double deliveryFee;
  final double cleanFee;
  final double smellFee;
  final double insurance;

  ExtraFee({
    required this.deliveryFee,
    required this.cleanFee,
    required this.smellFee,
    required this.insurance,
  });

  factory ExtraFee.fromJson(Map<String, dynamic> json) {
    return ExtraFee(
      deliveryFee: json['deliveryFee'],
      cleanFee: json['cleanFee'],
      smellFee: json['smellFee'],
      insurance: json['insurance'],
    );
  }
}