import 'dart:convert';

import 'package:az_car_flutter_app/data/carModel.dart';
import 'package:az_car_flutter_app/data/user_model.dart';

import 'package:az_car_flutter_app/data/ReviewModel.dart';
import 'package:http/http.dart' as http;
import '../data/CommentModel.dart';
import '../data/OrderDetails.dart';

class ApiService {
// 'http://192.168.1.9:8081'
  static const String baseUrl = 'http://192.168.1.5:8081';

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
        Uri.parse('$baseUrl/api/auth/signup'),
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
    final response = await http.get(Uri.parse('$baseUrl/api/cars/getAllCars'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      return responseData.map((json) => CarModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<CarModel>?> getAllCarsByUser(String emailLogin) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/cars/getCarsByUser?emailLogin=$emailLogin'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      return responseData.map((json) => CarModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<CarModel>?> getCarsExceptUserCar(String emailLogin) async {
    final response = await http.get(
        Uri.parse(
            '$baseUrl/api/cars/getCarsExceptUserCar?emailLogin=$emailLogin'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      return responseData.map((json) {
        var car = CarModel.fromJson(json);
        return car;
      }).toList();
    } else {
      throw Exception('Failed to load cars');
    }
  }

  static Future<List<OrderDetails>?> getOrdersList(String carId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/api/cars/getOrdersByCarId?carId=$carId'),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      final List<dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));
      print(responseData);
      return responseData.map((json) => OrderDetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<UserModel?> editUser(UserModel userModel) async {
    final response = await http.post(Uri.parse('$baseUrl/api/auth/editUser'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userModel.toJson()));
    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return UserModel.fromJson(data);
        } else {
          return null;
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        return null;
      }
    } else {
      print('HTTP Error: ${response.statusCode}');
      return null;
    }
  }

  static Future<bool> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/forgot_password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> tokenProcess(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/tokenProcess'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
  static Future<String> changePassword(String email, String oldPassword, String newPassword, String confirmPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/changePassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword
      }),
    );
    print(response.body.toString());
    return response.body.toString();
  }
  static Future<bool> resetPassword(String token, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/resetPassword'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'token': token, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }





  //Review " 16/6
  static Future<List<CommentModel>> getCommentsByCarId(String carId) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/car/$carId'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((comment) => CommentModel.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }  //Review " 15/6
  static Future<List<ReviewModel>?> getReviewsByCarId(String carId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/car/$carId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<ReviewModel> reviews = data.map((review) => ReviewModel.fromJson(review)).toList();
      return reviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }
}
