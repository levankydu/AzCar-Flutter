import 'dart:convert';
import 'package:az_car_flutter_app/data/WithdrawDTO.dart';
import 'package:http/http.dart' as http;

import '../data/DepositDTO.dart';

class DepositService {
  static const String baseUrl = 'http://192.168.56.1:8081';

  // Function to create a deposit
  static Future<bool> createDeposit(String referenceID, DepositDTO paymentDetails) async {
    final url = Uri.parse('$baseUrl/home/myplan/createpayments/deposit/$referenceID');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(paymentDetails.toJson()),
    );

    if (response.statusCode == 200) {
      return true;  // Deposit successfully created
    } else {
      // Optionally log or handle the error more robustly
      print('Failed to create deposit: ${response.statusCode} ${response.body}');
      return false;  // Failed to create deposit
    }
  }
  static Future<bool> createWithdraw(String referenceID, WithdrawDTO paymentDetails) async {
    final url = Uri.parse('$baseUrl/getmoneywallet/returnmywallet/$referenceID');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(paymentDetails.toJson()),
    );

    if (response.statusCode == 200) {
      return true;  // Deposit successfully created
    } else {
      // Optionally log or handle the error more robustly
      print('Failed to create deposit: ${response.statusCode} ${response.body}');
      return false;  // Failed to create deposit
    }
  }

  // Function to accept a payment

}
