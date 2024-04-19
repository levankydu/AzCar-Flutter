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
        Uri.parse('$baseUrl/cardBank/admin'), // Adjust API endpoint if necessary
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
}
