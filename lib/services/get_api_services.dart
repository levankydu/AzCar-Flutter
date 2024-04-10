import 'dart:convert';

import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/data/user_model.dart';
import 'package:http/http.dart' as http;

import '../data/OrderDetails.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.56.1:8081';

  static Future<List<UserModel>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/auth/getUsers'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return data.map((post) => UserModel.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static Future<bool> loginUser(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/signin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> signupUser(
      String username, String email, String password) async {
    if (username == '' || email == '' || password == '') {
      return false;
    } else {
      final response = await http.post(
        Uri.parse('$baseUrl/api/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    if (email.isEmpty) {
      return null;
    } else {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/getUsersByEmail?email=$email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return UserModel.fromJson(data);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  static Future<List<CarModel>?> getAllCars() async {
    final response = await http.get(Uri.parse('$baseUrl/api/cars/getAllCars'),headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {

      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      return responseData.map((json) => CarModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<OrderDetails>?> getOrdersList(String carId) async{
    final response = await http.get(Uri.parse('$baseUrl/api/cars/getOrdersByCarId?carId=$carId'),headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      return responseData.map((json) => OrderDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
