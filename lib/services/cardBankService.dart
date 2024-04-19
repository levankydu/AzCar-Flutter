import 'package:az_car_flutter_app/data/CardBankDTO.dart'; // Ensure this DTO is correctly defined
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardBankService {
  static const String baseUrl = 'http://192.168.56.1:8081';

  static Future<CardBankDTO?> getCardBankByUserId(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardBank/user/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return CardBankDTO.fromJson(data);
        } else {
          return null;
        }
      } else {
        // Consider logging the error or handling different status codes differently
        return null;
      }
    } catch (e) {
      // Consider logging the error or handling the exception according to your app's needs
      print('Failed to fetch card bank data: $e');
      return null;
    }
  }

  static Future<List<CardBankDTO>> getListCardBank() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cardBank/admin'),
        // Adjust API endpoint if necessary
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return CardBankDTO.fromJsonList(jsonData);
      } else {
        print('Failed to load card banks: HTTP status ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching card banks: $e');
      return [];
    }
  }

  static Future<bool> createNewCardBank(String bankName, String bankNumber,
      String beneficiaryName, String addressBank, String userId) async {
    try {
      // Construct the URL with query parameters
      final queryParameters = {
        'bankName': bankName,
        'bankNumber': bankNumber,
        'beneficiaryName': beneficiaryName,
        'addressbank': addressBank,
        'userId': userId,
      };
      final uri = Uri.parse('$baseUrl/cardBank/create').replace(queryParameters: queryParameters);

      // Make the HTTP POST request
      final response = await http.post(
        uri,
        // Omitting Content-Type since no JSON body is being sent, unless required by the server
      );

      if (response.statusCode == 200) {
        print('Card bank created successfully');
        return true; // Return true if the creation was successful
      } else {
        print('Failed to create card bank: HTTP status ${response.statusCode}');
        return false; // Return false if the server responded with an error
      }
    } catch (e) {
      print('Error creating card bank: $e');
      return false; // Return false on exception
    }
  }

}
